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

data <- omopgenerics::importSummarisedResult(file.path(getwd(),"data", "raw"))
if(nrow(data) == 0){
  cli::cli_warn("No data found in data/raw")
  choices <- list()
} else{
  choices <- getChoices(data, flatten = TRUE)
}
data <- data |>
  correctSettings()

# cohort_name_ref <- readr::read_csv(here::here("cohort_name_ref.csv"),
#                                    col_types = "c")
#
# for(i in 1:nrow(cohort_name_ref)){
#   data$group_level <- stringr::str_replace(
#     data$group_level ,
#     cohort_name_ref$cohort_name[i],
#     cohort_name_ref$tidy_cohort_name[i]
#   )
# }
#
#
# remove matched cohorts from choices
choices$summarise_characteristics_grouping_cohort_name <- choices$summarise_characteristics_grouping_cohort_name[
  !stringr::str_detect(choices$summarise_characteristics_grouping_cohort_name, "matched")]
#
settingsUsed <- unique(settings(data) |> pull("result_type"))
dataFiltered <- list()
for(i in seq_along(settingsUsed)){
  workingSetting <- settingsUsed[[i]]
  dataFiltered[[workingSetting]] <- visOmopResults::filterSettings(data, result_type ==
                                                                     workingSetting)
}

if(!is.null(dataFiltered$cohort_code_use)){
  codeUseCohorts <- unique(dataFiltered$cohort_code_use |>
                             visOmopResults::splitAll() |> pull("cohort_name"))
  codeUseCodelist <- unique(dataFiltered$cohort_code_use |>
                              visOmopResults::splitAll() |> pull("codelist_name"))

  choices$cohort_code_use_grouping_cohort_name <- codeUseCohorts
  selected$cohort_code_use_grouping_cohort_name <- codeUseCohorts[1]

}
selected <- choices

selected$summarise_characteristics_grouping_cohort_name <- selected$summarise_characteristics_grouping_cohort_name[1]
selected$summarise_large_scale_characteristics_grouping_cohort_name <- selected$summarise_large_scale_characteristics_grouping_cohort_name[1]


choices$compare_large_scale_characteristics_grouping_cdm_name <- choices$summarise_large_scale_characteristics_grouping_cdm_name
choices$compare_large_scale_characteristics_grouping_cohort_1 <- choices$summarise_large_scale_characteristics_grouping_cohort_name
choices$compare_large_scale_characteristics_grouping_cohort_2 <- choices$summarise_large_scale_characteristics_grouping_cohort_name
selected$compare_large_scale_characteristics_grouping_cdm_name <- choices$compare_large_scale_characteristics_grouping_cdm_name
selected$compare_large_scale_characteristics_grouping_cohort_1 <- choices$compare_large_scale_characteristics_grouping_cohort_1[1]
selected$compare_large_scale_characteristics_grouping_cohort_2 <- choices$compare_large_scale_characteristics_grouping_cohort_1[2]

if(!is.null(dataFiltered$summarise_large_scale_characteristics)){
choices$summarise_large_scale_characteristics_grouping_domain <- settings(dataFiltered$summarise_large_scale_characteristics) |>
  pull("table_name")
choices$summarise_large_scale_characteristics_grouping_time_window <- unique(dataFiltered$summarise_large_scale_characteristics |>
                                                                               pull("variable_level"))
}
selected$summarise_large_scale_characteristics_grouping_domain <- choices$summarise_large_scale_characteristics_grouping_domain
selected$summarise_large_scale_characteristics_grouping_time_window <-choices$summarise_large_scale_characteristics_grouping_time_window

choices$compare_large_scale_characteristics_grouping_time_window <- choices$summarise_large_scale_characteristics_grouping_time_window
choices$compare_large_scale_characteristics_grouping_table <- choices$summarise_large_scale_characteristics_grouping_domain
selected$compare_large_scale_characteristics_grouping_time_window <- selected$summarise_large_scale_characteristics_grouping_time_window
selected$compare_large_scale_characteristics_grouping_table <- selected$summarise_large_scale_characteristics_grouping_domain

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

#
# unmappedCodelist <- unique(dataFiltered$unmapped_codes |>
#                            visOmopResults::splitAll() |> pull("codelist_name"))
# unmappedCdm <- unique(dataFiltered$unmapped_codes |>
#                       visOmopResults::addSettings() |> pull("cdm_name"))
#
# choices$unmapped_grouping_cdm_name <- unmappedCdm
# selected$unmapped_grouping_cdm_name <- unmappedCdm
#
# choices$unmapped_grouping_codelist_name <- unmappedCodelist
# selected$unmapped_grouping_codelist_name <- unmappedCodelist[1]
#
#
selected$incidence_settings_outcome_cohort_name <- selected$incidence_settings_outcome_cohort_name[1]

selected$incidence_settings_analysis_interval <- selected$incidence_settings_analysis_interval[1]
selected$incidence_settings_denominator_age_group <- selected$incidence_settings_denominator_age_group[1]
selected$incidence_settings_denominator_sex <- selected$incidence_settings_denominator_sex[1]
selected$incidence_grouping_incidence_start_date
#
# min_incidence_start <- min(as.Date(selected$incidence_grouping_incidence_start_date))
# max_incidence_end <- max(as.Date(selected$incidence_grouping_incidence_end_date))
if(!is.null(dataFiltered$prevalence)){
prevalence_cohorts <- unique(dataFiltered$prevalence |> pull("variable_level"))
choices$prevalence_settings_outcome_cohort_name <- prevalence_cohorts
selected$prevalence_settings_outcome_cohort_name <- prevalence_cohorts[1]
}

selected$prevalence_settings_analysis_interval <- selected$prevalence_settings_analysis_interval[1]
selected$prevalence_settings_denominator_age_group <- selected$prevalence_settings_denominator_age_group[1]
selected$prevalence_settings_denominator_sex <- selected$prevalence_settings_denominator_sex[1]

save(data, dataFiltered, selected, choices,
     file = here::here("data", "appData.RData"))

