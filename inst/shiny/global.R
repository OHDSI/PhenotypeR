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
           concept_id,
           table_name,
           percentage) |>
    pivot_wider(names_from = cohort_name,
                values_from = percentage)
  
  plot <- plot_data |>
    ggplot(aes(text = paste("Concept:", variable_name,
                            "<br>Concept ID:", concept_id,
                            "<br>Time window:", variable_level,
                            "<br>Table:", table_name, 
                            "<br>Cohorts: "))) +
    geom_point(aes(x = !!sym(cohorts[1]),
                   y = !!sym(cohorts[2]))) +
    geom_abline(slope = 1, intercept = 0,
                color = "red", linetype = "dashed") +
    theme_bw()

  ggplotly(plot)

}
