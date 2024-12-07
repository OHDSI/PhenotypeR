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

# ensure minimum versions
rlang::check_installed("omopgenerics", version = "0.4")
rlang::check_installed("visOmopResults", version = "0.5.0")
rlang::check_installed("CodelistGenerator", version = "3.3.1")
rlang::check_installed("CohortCharacteristics", version = "0.4.0")
rlang::check_installed("IncidencePrevalence", version = "0.9.0")
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
    filter(group_level %in% c(cohorts
    )) |>
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
    ggplot(aes(text = paste("<br>Database:", database,
                            "<br>Concept:", variable_name,
                            "<br>Concept ID:", concept_id,
                            "<br>Time window:", time_window,
                            "<br>Table:", table,
                            "<br>Cohorts: "))) +
    geom_point(aes(x = !!sym(cohorts[1]),
                   y = !!sym(cohorts[2]),
                   colour = !!sym(colour))
               ) +
    geom_abline(slope = 1, intercept = 0,
                color = "red", linetype = "dashed") +
    theme_bw()

  if(!is.null(facet)){
    plot <- plot +
      ggplot2::facet_wrap(facet)
  }
  ggplotly(plot)

}
