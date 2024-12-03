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

  # data <- data |>
  #   mutate(group_level = if_else(str_starts(group_level, "matched_to_"),
  #                                str_replace(group_level, "^matched_to_", "") %>%
  #                                  paste0("_m1"),
  #                                group_level)) |>
  #   mutate(group_level = if_else(str_detect(group_level, "_matched"),
  #                                str_replace(group_level, "_matched", "") %>%
  #                                  paste0("_sample"),
  #                                group_level))|>
  #   mutate(group_level = if_else(str_detect(group_level, "_m1"),
  #                                str_replace(group_level, "_m1", "") %>%
  #                                  paste0("_matched"),
  #                                group_level))


  # cli::cli_inform("Correcting settings")
  # data <- data |> correctSettings()
  cli::cli_inform("Getting input choices for shiny UI")
  choices <- getChoices(data, flatten = TRUE)
}

cli::cli_inform("Customising shiny app inputs")
# remove matched cohorts from choices
choices$summarise_characteristics_grouping_cohort_name <- choices$summarise_characteristics_grouping_cohort_name[
  !stringr::str_detect(choices$summarise_characteristics_grouping_cohort_name, "matched")]

settingsUsed <- unique(settings(data) |> pull("result_type"))
dataFiltered <- list()
for(i in seq_along(settingsUsed)){
  workingSetting <- settingsUsed[[i]]
  dataFiltered[[workingSetting]] <- visOmopResults::filterSettings(data, result_type ==
                                                                     workingSetting)
}

selected <- choices

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

choices$cohort_code_use_grouping_cohort_name <- codeUseCohorts
selected$cohort_code_use_grouping_cohort_name <- codeUseCohorts[1]

selected$summarise_characteristics_grouping_cohort_name <- selected$summarise_characteristics_grouping_cohort_name[1]
selected$summarise_large_scale_characteristics_grouping_cohort_name <- selected$summarise_large_scale_characteristics_grouping_cohort_name[1]

choices$compare_large_scale_characteristics_grouping_cdm_name <- choices$summarise_large_scale_characteristics_grouping_cdm_name
choices$compare_large_scale_characteristics_grouping_cohort <- choices$summarise_large_scale_characteristics_grouping_cohort_name
choices$compare_large_scale_characteristics_grouping_cohort <- choices$compare_large_scale_characteristics_grouping_cohort[str_detect(choices$compare_large_scale_characteristics_grouping_cohort,
                                                                                                                                      "matched|sample", negate= TRUE)]
choices$compare_large_scale_characteristics_grouping_cohort_1 <- choices$summarise_large_scale_characteristics_grouping_cohort_name
choices$compare_large_scale_characteristics_grouping_cohort_2 <- choices$summarise_large_scale_characteristics_grouping_cohort_name
choices$compare_large_scale_characteristics_grouping_domain <- choices$summarise_large_scale_characteristics_grouping_domain
choices$compare_large_scale_characteristics_grouping_time_window <- choices$summarise_large_scale_characteristics_grouping_time_window

selected$compare_large_scale_characteristics_grouping_cdm_name <- choices$compare_large_scale_characteristics_grouping_cdm_name
selected$compare_large_scale_characteristics_grouping_cohort <- choices$compare_large_scale_characteristics_grouping_cohort[1]
selected$compare_large_scale_characteristics_grouping_cohort_1 <- choices$compare_large_scale_characteristics_grouping_cohort_1[1]
selected$compare_large_scale_characteristics_grouping_cohort_2 <- choices$compare_large_scale_characteristics_grouping_cohort_1[2]
selected$compare_large_scale_characteristics_grouping_domain <- choices$compare_large_scale_characteristics_grouping_domain[1]
selected$compare_large_scale_characteristics_grouping_time_window <- choices$compare_large_scale_characteristics_grouping_time_window[1]

if(!is.null(dataFiltered$summarise_large_scale_characteristics)){
  if(nrow(dataFiltered$summarise_large_scale_characteristics)>0){
    choices$summarise_large_scale_characteristics_grouping_domain <- settings(dataFiltered$summarise_large_scale_characteristics) |>
      pull("table_name")
    selected$summarise_large_scale_characteristics_grouping_domain <- choices$summarise_large_scale_characteristics_grouping_domain

    choices$summarise_large_scale_characteristics_grouping_time_window <- unique(dataFiltered$summarise_large_scale_characteristics |>
                                                                                   pull("variable_level"))
    selected$summarise_large_scale_characteristics_grouping_time_window <-choices$summarise_large_scale_characteristics_grouping_time_window
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

selected$incidence_settings_outcome_cohort_name <- selected$incidence_settings_outcome_cohort_name[1]

selected$incidence_settings_analysis_interval <- "overall"
selected$incidence_settings_denominator_age_group <- selected$incidence_settings_denominator_age_group[1]
selected$incidence_settings_denominator_sex <- selected$incidence_settings_denominator_sex[1]

choices$incidence_settings_denominator_age_group <- c(
  "0 to 150",
  "0 to 19", "20 to 64", "65 to 150",
  "0 to 4", "5 to 9",
  "10 to 19", "20 to 29",
  "30 to 39", "40 to 49",
  "50 to 59", "60 to 69",
  "70 to 79",  "80 to 150"
)

selected$incidence_settings_denominator_age_group <- c("0 to 19",
                                                       "20 to 64",
                                                       "65 to 150")

min_incidence_start <- min(as.Date(selected$incidence_grouping_incidence_start_date))
max_incidence_end <- max(as.Date(selected$incidence_grouping_incidence_end_date))

selected$summarise_cohort_overlap_grouping_cohort_name_reference <- selected$summarise_cohort_overlap_grouping_cohort_name_reference[1:2]
selected$summarise_cohort_overlap_grouping_cohort_name_comparator <- selected$summarise_cohort_overlap_grouping_cohort_name_comparator[1:2]
choices$compare_large_scale_characteristics_grouping_domain <- choices$summarise_large_scale_characteristics_grouping_domain
choices$compare_large_scale_characteristics_grouping_time_window <- choices$summarise_large_scale_characteristics_grouping_time_window
selected$compare_large_scale_characteristics_grouping_domain <- selected$summarise_large_scale_characteristics_grouping_domain
selected$compare_large_scale_characteristics_grouping_time_window <- selected$summarise_large_scale_characteristics_grouping_time_window


choices <- choices[!grepl("concept_id", names(choices))]
selected <- selected[!grepl("concept_id", names(selected))]
choices <- choices[!grepl("concept_name", names(choices))]
selected <- selected[!grepl("concept_name", names(selected))]

choices <- choices[grepl("summarise_cohort_overlap_variable_name", names(choices)) |
                     !grepl("variable_name", names(choices))]
selected <- selected[grepl("summarise_cohort_overlap_variable_name", names(selected)) |
                       !grepl("variable_name", names(selected))]
# choices <- choices[!grepl("variable_name", names(choices))]
# selected <- selected[!grepl("variable_name", names(selected))]

# sort everything alphabetically
choices <- purrr::map(choices, sort)
selected <- purrr::map(selected, sort)


cli::cli_inform("Saving data for shiny")
save(dataFiltered,
     selected,
     choices,
     min_incidence_start,
     max_incidence_end,
     file = here::here("data", "appData.RData"))
rm(data)
