library(bslib)
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

source(file.path(getwd(),"scripts", "functions.R"))

if(file.exists(file.path(getwd(), "data", "appData.RData"))){
  load(file.path(getwd(),"data", "appData.RData"))
} else {
  source(file.path(getwd(),"scripts", "preprocess.R"))
}

plotComparedLsc <- function(lsc, cohorts){
  lsc <- lsc |>  tidy()
  plot_data <- lsc |>
    filter(cohort_name %in% c(cohorts
    )) |>
    select(cohort_name,
           variable_name,
           variable_level,
           percentage) |>
    pivot_wider(names_from = cohort_name,
                       values_from = percentage)

  plot <- plot_data |>
    ggplot(aes(text = paste("Label:", variable_name,
                            "<br>Group:", variable_level))) +
    geom_point(aes(x = !!sym(cohorts[1]),
                   y = !!sym(cohorts[2]))) +
    geom_abline(slope = 1, intercept = 0,
                color = "red", linetype = "dashed") +
    theme_bw()

  ggplotly(plot)

}
