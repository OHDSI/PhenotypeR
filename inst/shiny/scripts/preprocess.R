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
library(stringr)

cli::cli_inform("Importing results")
data <- omopgenerics::importSummarisedResult(file.path(getwd(),"data", "raw"))
cli::cli_alert_success("Results imported")

if(nrow(data) == 0){
  cli::cli_warn("No data found in data/raw")
  choices <- list()
} else{
  cli::cli_inform("Getting input choices for shiny UI")
  choices <- getChoices(data, flatten = TRUE)
}

cli::cli_inform("Customising shiny app inputs")

# remove matched cohorts from choices
choices$summarise_characteristics_grouping_cohort_name <- choices$summarise_characteristics_grouping_cohort_name[
  !stringr::str_detect(choices$summarise_characteristics_grouping_cohort_name, "matched|sampled")]

settingsUsed <- unique(settings(data) |> pull("result_type"))
dataFiltered <- list()
for(i in seq_along(settingsUsed)){
  workingSetting <- settingsUsed[[i]]
  dataFiltered[[workingSetting]] <- visOmopResults::filterSettings(data, result_type ==
                                                                     workingSetting)
}

selected <- choices

choices$cohort_code_use_grouping_source_concept_value <- NULL
selected$cohort_code_use_grouping_source_concept_value <- NULL

if(!is.null(dataFiltered$cohort_code_use)){
  if(nrow(dataFiltered$cohort_code_use)>0){
    codeUseCohorts <- unique(dataFiltered$cohort_code_use |>
                               visOmopResults::splitAll() |> pull("cohort_name"))
    codeUseCodelist <- unique(dataFiltered$cohort_code_use |>
                                visOmopResults::splitAll() |> pull("codelist_name"))

    choices$cohort_code_use_grouping_cohort_name <- codeUseCohorts
    selected$cohort_code_use_grouping_cohort_name <- codeUseCohorts[1]
  }
}

selected$achilles_code_use_grouping_codelist_name <- selected$achilles_code_use_grouping_codelist_name[1]

selected$summarise_characteristics_grouping_cohort_name <- selected$summarise_characteristics_grouping_cohort_name[1]
selected$summarise_large_scale_characteristics_grouping_cohort_name <- c(gsub("_matched","_sampled",selected$summarise_large_scale_characteristics_grouping_cohort_name[1]),
                                                                         gsub("_sampled","_matched",selected$summarise_large_scale_characteristics_grouping_cohort_name[1]))

choices$compare_large_scale_characteristics_grouping_cdm_name <- choices$summarise_large_scale_characteristics_grouping_cdm_name
choices$compare_large_scale_characteristics_grouping_cohort <- choices$summarise_large_scale_characteristics_grouping_cohort_name
choices$compare_large_scale_characteristics_grouping_cohort <- choices$compare_large_scale_characteristics_grouping_cohort[str_detect(choices$compare_large_scale_characteristics_grouping_cohort,
                                                                                                                                      "matched|sampled", negate= TRUE)]
choices$compare_large_scale_characteristics_grouping_cohort_1 <- choices$summarise_large_scale_characteristics_grouping_cohort_name
choices$compare_large_scale_characteristics_grouping_cohort_2 <- choices$summarise_large_scale_characteristics_grouping_cohort_name
choices$compare_large_scale_characteristics_grouping_domain <- choices$summarise_large_scale_characteristics_grouping_domain
# choices$compare_large_scale_characteristics_grouping_time_window <- choices$summarise_large_scale_characteristics_grouping_time_window

selected$summarise_large_scale_characteristics_grouping_cohort_name <- selected$summarise_large_scale_characteristics_grouping_cohort_name[1]
selected$compare_large_scale_characteristics_grouping_cdm_name <- choices$compare_large_scale_characteristics_grouping_cdm_name
selected$compare_large_scale_characteristics_grouping_cohort <- choices$compare_large_scale_characteristics_grouping_cohort[1]
selected$compare_large_scale_characteristics_grouping_cohort_1 <- gsub("_matched", "_sampled",choices$compare_large_scale_characteristics_grouping_cohort_1[1])
selected$compare_large_scale_characteristics_grouping_cohort_2 <- gsub("_sampled", "_matched",choices$compare_large_scale_characteristics_grouping_cohort_1[2])
selected$compare_large_scale_characteristics_grouping_domain <- choices$compare_large_scale_characteristics_grouping_domain[1]
# selected$compare_large_scale_characteristics_grouping_time_window <- choices$compare_large_scale_characteristics_grouping_time_window[1]

if(!is.null(dataFiltered$summarise_large_scale_characteristics)){
  if(nrow(dataFiltered$summarise_large_scale_characteristics)>0){
    dataFiltered$summarise_large_scale_characteristics <- dataFiltered$summarise_large_scale_characteristics |>
      mutate(variable_name = iconv(variable_name, from = "latin1", to = "UTF-8"))
    choices$summarise_large_scale_characteristics_grouping_domain <- unique(settings(dataFiltered$summarise_large_scale_characteristics) |>
      pull("table_name"))
    selected$summarise_large_scale_characteristics_grouping_domain <- choices$summarise_large_scale_characteristics_grouping_domain
  }}

if(!is.null(dataFiltered$orphan_code_use)){
  orphanCodelist <- unique(dataFiltered$orphan_code_use |>
                             visOmopResults::splitAll() |> pull("codelist_name"))
  orphanCdm <- unique(dataFiltered$orphan_code_use |>
                        visOmopResults::addSettings() |> pull("cdm_name"))

  choices$orphan_grouping_cdm_name <- orphanCdm
  choices$orphan_grouping_codelist_name <- orphanCodelist
  selected$orphan_grouping_cdm_name <- orphanCdm
  selected$orphan_grouping_cohort_name <- orphanCodelist[1]
}

if(!is.null(dataFiltered$unmapped_codes)){
  if(nrow(dataFiltered$unmapped_codes)>0){
    unmappedCodelist <- unique(dataFiltered$unmapped_codes |>
                                 visOmopResults::splitAll() |> pull("codelist_name"))
    unmappedCdm <- unique(dataFiltered$unmapped_codes |>
                            visOmopResults::addSettings() |> pull("cdm_name"))

    choices$unmapped_grouping_cdm_name <- unmappedCdm
    selected$unmapped_grouping_cdm_name <- unmappedCdm

    choices$unmapped_grouping_codelist_name <- unmappedCodelist
    selected$unmapped_grouping_codelist_name <- unmappedCodelist[1]
  }}

selected$incidence_grouping_outcome_cohort_name <- selected$incidence_grouping_outcome_cohort_name[1]

selected$incidence_settings_analysis_interval <- "overall"
selected$incidence_settings_denominator_age_group <- selected$incidence_settings_denominator_age_group[1]
selected$incidence_settings_denominator_sex <- "Both"
selected$incidence_settings_denominator_days_prior_observation <-  selected$incidence_settings_denominator_days_prior_observation[1]

choices$incidence_settings_denominator_age_group <- c(
  "0 to 150",
  "0 to 17",
  "18 to 64",
  "65 to 150"
)
selected$incidence_settings_denominator_age_group <- c("0 to 150")

min_incidence_start <- min(as.Date(selected$incidence_grouping_incidence_start_date))
max_incidence_end <- max(as.Date(selected$incidence_grouping_incidence_end_date))

choices$incidence_settings_analysis_interval <- c("overall", "years")
selected$incidence_settings_analysis_interval <- "years"

choices$prevalence_settings_analysis_interval <- c("overall", "years")
selected$prevalence_settings_analysis_interval <- "years"
selected$prevalence_settings_denominator_days_prior_observation <-  selected$prevalence_settings_denominator_days_prior_observation[1]

selected$prevalence_grouping_outcome_cohort_name <- selected$prevalence_grouping_outcome_cohort_name[1]

choices$prevalence_settings_denominator_age_group <- c(
  "0 to 150",
  "0 to 17",
  "18 to 64",
  "65 to 150"
)
selected$prevalence_settings_denominator_age_group <- c("0 to 150")
selected$prevalence_settings_denominator_sex <- "Both"

selected$summarise_cohort_overlap_grouping_cohort_name_reference <- selected$summarise_cohort_overlap_grouping_cohort_name_reference[1:2]
selected$summarise_cohort_overlap_grouping_cohort_name_comparator <- selected$summarise_cohort_overlap_grouping_cohort_name_comparator[1:2]
choices$compare_large_scale_characteristics_grouping_domain <- choices$summarise_large_scale_characteristics_grouping_domain
selected$compare_large_scale_characteristics_grouping_domain <- choices$compare_large_scale_characteristics_grouping_domain

choices$compare_large_scale_characteristics_settings_analysis <- choices$summarise_large_scale_characteristics_settings_analysis
selected$compare_large_scale_characteristics_settings_analysis <- "standard"

selected$summarise_large_scale_characteristics_settings_analysis <-"standard"

choices <- choices[!grepl("concept_id", names(choices))]
selected <- selected[!grepl("concept_id", names(selected))]
choices <- choices[!grepl("concept_name", names(choices))]
selected <- selected[!grepl("concept_name", names(selected))]

choices <- choices[grepl("summarise_cohort_overlap_variable_name", names(choices)) |
                     !grepl("variable_name", names(choices))]
selected <- selected[grepl("summarise_cohort_overlap_variable_name", names(selected)) |
                       !grepl("variable_name", names(selected))]

# sort everything alphabetically
choices <- purrr::map(choices, sort)
selected <- purrr::map(selected, sort)

choices$summarise_large_scale_characteristics_grouping_time_window <- c(
  "-inf to -1",
  "-inf to -366",
  "-365 to -31",
  "-30 to -1",
  "0 to 0",
  "1 to 30",
  "1 to inf",
  "31 to 365",
  "366 to inf"
)
selected$summarise_large_scale_characteristics_grouping_time_window <-choices$summarise_large_scale_characteristics_grouping_time_window[1]

choices$compare_large_scale_characteristics_grouping_time_window <- c(
  "-inf to -1",
  "-inf to -366",
  "-365 to -31",
  "-30 to -1",
  "0 to 0",
  "1 to 30",
  "1 to inf",
  "31 to 365",
  "366 to inf"
)
selected$compare_large_scale_characteristics_grouping_time_window <- choices$compare_large_scale_characteristics_grouping_time_window[1]


cli::cli_inform("Saving data for shiny")
save(dataFiltered,
     selected,
     choices,
     min_incidence_start,
     max_incidence_end,
     file = here::here("data", "appData.RData"))
rm(data)

