# ensure minimum versions
rlang::check_installed("omopgenerics", version = "1.2.0")
rlang::check_installed("visOmopResults", version = "0.5.0")
rlang::check_installed("CodelistGenerator", version = "3.4.0")
rlang::check_installed("CohortCharacteristics", version = "1.0.0")
rlang::check_installed("IncidencePrevalence", version = "1.2.0")
rlang::check_installed("OmopSketch", version = "0.3.1")
rlang::check_installed("CohortSurvival", version = "1.0.2")

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
library(reactable)
source(here::here("scripts", "functions.R"))

if(file.exists(here::here("data", "appData.RData"))){
  if (rlang::is_interactive()) {
    cli::cli_inform(c(
      "!" = "Would you like to preprocess the data again? Enter choice 1 or 2",
      " " = "1) Yes",
      " " = "2) No"
    ))
    preprocess <- readline()
    omopgenerics::assertChoice(preprocess, c(1, 2), length = 1)
  }
}

if(preprocess == "1" | !file.exists(here::here("data", "appData.RData"))){
  cli::cli_inform("Preprocessing data from data/raw")
  source(here::here("scripts", "preprocess.R"))
  load(here::here("data", "appData.RData"))
  cli::cli_alert_success("Data processed")
} else {
  cli::cli_inform("Loading existing processed data")
  load(here::here("data", "appData.RData"))
  cli::cli_alert_success("Data loaded")
}

plotComparedLsc <- function(lsc, cohorts, imputeMissings, colour = NULL, facet = NULL){
  plot_data <- lsc |>
    filter(group_level %in% c(cohorts)) |>
    filter(estimate_name == "percentage") |>
    tidy() |>
    select(dplyr::any_of(c(
      "database" = "cdm_name",
      "cohort_name",
      "variable_name",
      "time_window" = "variable_level",
      "concept_id",
      "source_concept_name",
      "source_concept_id",
      "table" = "table_name",
      "percentage"))) |>
    mutate(percentage = if_else(percentage == "-",
                                NA, percentage)) |>
    mutate(percentage = as.numeric(percentage)/100) |>
    pivot_wider(names_from = cohort_name,
                values_from = percentage)

  if(isTRUE(imputeMissings)){
    plot_data <- plot_data |>
      mutate(across(c(cohorts[1], cohorts[2]), ~if_else(is.na(.x), 0, .x)))
  }

  plot_data <- plot_data |>
    mutate(smd = (!!sym(cohorts[1]) - !!sym(cohorts[2]))/sqrt((!!sym(cohorts[1])*(1-!!sym(cohorts[1])) + !!sym(cohorts[2])*(1-!!sym(cohorts[2])))/2)) |>
    mutate(smd = round(smd, 2))
  if("source_concept_id" %in% colnames(plot_data)){
    plot_data <- plot_data |>
      mutate("Details" = paste("<br>Database:", database,
                               "<br>Concept:", variable_name,
                               "<br>Concept ID:", concept_id,
                               "<br>Source concept:", source_concept_name,
                               "<br>Source concept ID:", source_concept_id,
                               "<br>Time window:", time_window,
                               "<br>Table:", table,
                               "<br>SMD:", smd,
                               "<br>Cohorts: ",
                               "<br> - ", cohorts[1],": ", !!sym(cohorts[1]),
                               "<br> - ", cohorts[2],": ", !!sym(cohorts[2])))
  } else {
    plot_data <- plot_data |>
      mutate("Details" = paste("<br>Database:", database,
                               "<br>Concept:", variable_name,
                               "<br>Concept ID:", concept_id,
                               "<br>Time window:", time_window,
                               "<br>Table:", table,
                               "<br>SMD:", smd,
                               "<br>Cohorts: ",
                               "<br> - ", cohorts[1],": ", !!sym(cohorts[1]),
                               "<br> - ", cohorts[2],": ", !!sym(cohorts[2])))
  }


  plot <- plot_data |>
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
    theme_bw() +
    xlab(paste0(stringr::str_to_sentence(gsub("_"," ", cohorts[1])), " (%)")) +
    ylab(paste0(stringr::str_to_sentence(gsub("_"," ", cohorts[2])), " (%)"))

  return(plot)
}


plotAgeDensity <- function(summarise_table, summarise_characteristics, show_interquantile_range){

  data <- summarise_table |>
    filter(variable_name == "age") |>
    pivot_wider(names_from = "estimate_name", values_from = "estimate_value") |>
    mutate(density_x = as.numeric(density_x),
           density_y = as.numeric(density_y)) |>
    splitStrata() |>
    mutate(density_y = if_else(sex == "Female", -density_y, density_y)) |>
    filter(!is.na(density_x),
           !is.na(density_y))

  if (nrow(data) == 0) {
    validate("No results found for age density")
  }

  max_density <- max(data$density_y, na.rm = TRUE)
  min_age <- (floor((data$density_x |> min(na.rm = TRUE))/5))*5
  max_age <- (ceiling((data$density_x |> max(na.rm = TRUE))/5))*5

  iqr <- summarise_characteristics |>
    filter(variable_name == "Age",
           strata_level %in% c("Female","Male"),
           estimate_name %in% c("q25", "median", "q75")) |>
    mutate(estimate_value_round = as.numeric(estimate_value)) |>
    select(-"estimate_value") |>
    left_join(
      data |>
        select("cdm_name", "group_level", "strata_level" = "sex", "estimate_value" = "density_x", "density_y") |>
        arrange(cdm_name, strata_level, estimate_value, density_y) |>
        mutate(estimate_value_round = round(estimate_value)) |>
        mutate(estimate_value_diff = estimate_value - estimate_value_round) |>
        group_by(cdm_name, group_level, strata_level, estimate_value_round) |>
        filter(estimate_value_diff == min(estimate_value_diff)) |>
        ungroup(),
      by = c("cdm_name", "group_level", "strata_level", "estimate_value_round")
    ) |>
    rename("sex" = "strata_level")

  # keep only estimates for cohorts with density
  iqr <- iqr |>
    inner_join(data |>
                 select(group_level) |> distinct())

  plot <- ggplot2::ggplot(data, ggplot2::aes(x = density_x, y = density_y, fill = sex)) +
    geom_polygon() +
    scale_y_continuous(labels = function(x) scales::label_percent()(abs(x)),
                       limits = c(-max_density*1.2, max_density*1.2)) +
    themeVisOmop() +
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
                       breaks = c(seq(min_age, max_age-5,5), max_age)) +
    scale_fill_manual(values = list("Male" = "#77A9B4","Female" = "#E1B12D")) +
    facet_wrap(c("cdm_name", "group_level")) +
    coord_flip(clip = "off")

  if(show_interquantile_range){
    plot <- plot +
      geom_segment(data = iqr[iqr$estimate_name == "median", ],
                   aes(x = estimate_value, y = 0, xend = estimate_value, yend = density_y),
                   linewidth = 0.75) +
      geom_segment(data = iqr[iqr$estimate_name != "median", ],
                   aes(x = estimate_value, y = 0, xend = estimate_value, yend = density_y),
                   linetype = 2,
                   linewidth = 0.75) +
      labs(subtitle = "The solid line represents the median, while the dotted lines indicate the interquartile range. Notice that these may not appear if in the cohort there are less than the minimum cell count specified. Please be aware that statistics are calculated by record, not by subject.") +
      facet_wrap(c("cdm_name", "group_level"))
  }else{
    plot <- plot +
      labs(subtitle = "Please be aware that statistics are calculated by record, not by subject.")
  }

  return(plot)
}

getColsForTbl <- function(tbl, sortNALast = TRUE, names = c("Standard concept ID")){

  cols <- list()
  for(i in seq_along(names(tbl))){
    working_col <- names(tbl)[i]

    if(working_col %in% c(names)){

      cols[[working_col]] <- colDef(name = working_col,
                                    sortNALast = sortNALast,
                                    cell = function(value){
                                      if(!is.na(value) && !grepl("^NA$", value)) {
                                        url <- sprintf("https://athena.ohdsi.org/search-terms/terms/%s", value)
                                        htmltools::tags$a(href = url, target = "_blank", as.character(value))
                                      }else{
                                        "-"
                                      }
                                    }
      )

    }else{
      cols[[working_col]] <- colDef(name = working_col,
                                    sortNALast = sortNALast,
                                    format = colFormat(separators = TRUE))
    }
  }

  return(cols)
}

validateFilteredResult <- function(result){
  if (nrow(result) == 0) {
    validate("No results found for selected inputs")
  }
}
