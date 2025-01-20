library(bslib)
library(omopgenerics)
library(CodelistGenerator)
library(CohortCharacteristics)
library(DiagrammeR)
library(dplyr)
library(DT)
library(ggplot2)
library(gt)
library(here)
library(IncidencePrevalence)
library(OmopSketch)
library(readr)
library(shiny)
library(sortable)
library(visOmopResults)
library(shinycssloaders)
library(shinyWidgets)
library(plotly)
library(tidyr)
library(patchwork)

# ensure minimum versions
rlang::check_installed("omopgenerics", version = "0.4")
rlang::check_installed("visOmopResults", version = "0.5.0")
rlang::check_installed("CodelistGenerator", version = "3.3.1")
rlang::check_installed("CohortCharacteristics", version = "0.4.0")
rlang::check_installed("IncidencePrevalence", version = "1.0.0")
rlang::check_installed("OmopSketch", version = "0.1.2")

source(here::here("scripts", "functions.R"))

if(file.exists(here::here("data", "appData.RData"))){
  cli::cli_inform("Loading existing processed data")
  load(here::here("data", "appData.RData"))
  cli::cli_alert_success("Data loaded")
} else {
  cli::cli_inform("Preprocessing data from data/raw")
  source(here::here("scripts", "preprocess.R"))
  cli::cli_alert_success("Data processed")
}

plotComparedLsc <- function(lsc, cohorts, imputeMissings, colour = NULL, facet = NULL){

  plot_data <- lsc |>
    filter(group_level %in% c(cohorts)) |>
    filter(estimate_name == "percentage") |>
    omopgenerics::addSettings() |>
    select(database = cdm_name,
           cohort_name = group_level,
           variable_name,
           time_window = variable_level,
           concept_id = additional_level,
           table = table_name,
           percentage = estimate_value) |>
    mutate(percentage = if_else(percentage == "-",
                                NA, percentage)) |>
    mutate(percentage = as.numeric(percentage)) |>
    pivot_wider(names_from = cohort_name,
                values_from = percentage)

  if(isTRUE(imputeMissings)){
    plot_data <- plot_data |>
      mutate(across(c(cohorts[1], cohorts[2]), ~if_else(is.na(.x), 0, .x)))
  }
  
  plot <- plot_data |>
    mutate("Details" = paste("<br>Database:", database,
                             "<br>Concept:", variable_name,
                             "<br>Concept ID:", concept_id,
                             "<br>Time window:", time_window,
                             "<br>Table:", table,
                             "<br>Cohorts: ",
                             "<br> - ", cohorts[1],": ", !!sym(cohorts[1]),
                             "<br> - ", cohorts[2],": ", !!sym(cohorts[2]))) |>
    visOmopResults::scatterPlot(x = cohorts[1],
                                y = cohorts[2],
                                colour = colour,
                                facet  = facet,
                                ribbon = FALSE,
                                line   = FALSE,
                                point  = TRUE, 
                                label  = "Details") +
    geom_abline(slope = 1, intercept = 0,
                color = "red", linetype = "dashed") +
    theme_bw()
    
  ggplotly(plot, tooltip = "Details")

}

plotAgeDistribution <- function(summarise_table, summarise_characteristics){
  
  data <- summarise_table |>
    filter(variable_name == "age") |>
    pivot_wider(names_from = "estimate_name", values_from = "estimate_value") |>
    mutate(density_x = as.numeric(density_x),
           density_y = as.numeric(density_y)) |>
    splitStrata() |>
    mutate(density_y = if_else(sex == "Female", -density_y, density_y)) 
  
  max_density <- max(data$density_y, na.rm = TRUE)
  min_age <- (floor((data$density_x |> min())/5))*5
  max_age <- (ceiling((data$density_x |> max())/5))*5
  
  iqr <- dataFiltered$summarise_characteristics |>
    filter(variable_name == "Age",
           strata_level %in% c("Female","Male"),
           estimate_name %in% c("q25", "median", "q75")) |>
    mutate(estimate_value = as.numeric(estimate_value)) |>
    left_join(
      data |> 
        select("cdm_name", "strata_level" = "sex", "estimate_value" = "density_x", "density_y") |>
        arrange(strata_level, estimate_value, density_y) |>
        mutate(estimate_value_round = round(estimate_value)) |>
        mutate(estimate_value_diff = estimate_value - estimate_value_round) |>
        group_by(strata_level, estimate_value_round) |>
        filter(estimate_value_diff == min(estimate_value_diff)) |>
        select("cdm_name", "estimate_value" = "estimate_value_round", "density_y", "strata_level"),
      by = c("estimate_value", "strata_level", "cdm_name")
    ) |> 
    rename("sex" = "strata_level")
  
  ggplot(data, aes(x = density_x, y = density_y, fill = sex)) +
    geom_polygon() +
    geom_segment(data = iqr[iqr$estimate_name == "median", ], 
                 aes(x = estimate_value, y = 0, xend = estimate_value, yend = density_y),
                 linewidth = 1) +
    geom_segment(data = iqr[iqr$estimate_name != "median", ], 
                 aes(x = estimate_value, y = 0, xend = estimate_value, yend = density_y), 
                 linetype = 2, 
                 linewidth = 1) +
    scale_y_continuous(labels = function(x) scales::label_percent()(abs(x)),
                       limits = c(-max_percentage*1.1, max_percentage*1.1)) +
    theme_bw() +
    theme(
      axis.text.x = element_text(),
      axis.title.x = ggplot2::element_blank(),
      panel.grid.major.x = element_line(color = "grey90"),
      panel.grid.major.y = element_line(color = "grey90"),
      legend.box = "horizontal",
      axis.title.y = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank()
    ) +
    scale_x_continuous(labels = c(as.character(seq(min_age,max_age-5,5)), paste0(max_age,"+")),
                       breaks = c(seq(min_age,max_age-5,5), max_age)) +
    scale_fill_manual(values = list("Male" = "#4682B4","Female" = "#003153")) +
    facet_wrap(c("cdm_name", "group_level")) +
    coord_flip(clip = "off") +
    labs(subtitle = "The solid line represents the median, while the dotted lines indicate the interquartile range.")
}

