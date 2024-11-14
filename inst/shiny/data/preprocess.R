# shiny is prepared to work with this panelDetails, please do not change them
panelDetails <- list(
  "summarise_omop_snapshot" = list(
    "result_type" = "summarise_omop_snapshot",
    "result_id" = c(1),
    "output_id" = c(17),
    "icon" = "clipboard-list",
    "title" = "Snapshot",
    "information" = ""
  ),
  "summarise_observation_period" = list(
    "result_type" = "summarise_observation_period",
    "result_id" = c(2),
    "output_id" = c(15, 16),
    "icon" = "eye",
    "title" = "Observation period",
    "information" = ""
  ),
  "cohort_code_use" = list(
    "result_type" = "cohort_code_use",
    "result_id" = c(3),
    "output_id" = c(12),
    "icon" = "chart-column",
    "title" = "Cohort code use",
    "information" = ""
  ),
  "achilles_code_use" = list(
    "result_type" = "achilles_code_use",
    "result_id" = c(4),
    "output_id" = c(14),
    "icon" = "chart-column",
    "title" = "Achilles code use",
    "information" = ""
  ),
  "orphan_code_use" = list(
    "result_type" = "orphan_code_use",
    "result_id" = c(5),
    "output_id" = c(11),
    "icon" = "magnifying-glass-arrow-right",
    "title" = "Orphan codes",
    "information" = ""
  ),
  "summarise_characteristics" = list(
    "result_type" = "summarise_characteristics",
    "result_id" = c(6, 93),
    "output_id" = c(7, 8),
    "icon" = "users-gear",
    "title" = "Cohort characteristics",
    "information" = ""
  ),
  "summarise_table" = list(
    "result_type" = "summarise_table",
    "result_id" = c(7),
    "output_id" = c(0),
    "icon" = character(),
    "title" = "Summarise table",
    "information" = character()
  ),
  "summarise_cohort_attrition" = list(
    "result_type" = "summarise_cohort_attrition",
    "result_id" = c(8, 9, 10),
    "output_id" = c(3, 4),
    "icon" = "layer-group",
    "title" = "Cohort Attrition",
    "information" = ""
  ),
  "summarise_cohort_overlap" = list(
    "result_type" = "summarise_cohort_overlap",
    "result_id" = c(11),
    "output_id" = c(1, 2),
    "icon" = "circle-half-stroke",
    "title" = "Cohort overlap",
    "information" = "Cohort overlap shows the number of subjects that contribute to a pair of cohorts."
  ),
  "summarise_cohort_timing" = list(
    "result_type" = "summarise_cohort_timing",
    "result_id" = c(12),
    "output_id" = c(5, 6),
    "icon" = "chart-simple",
    "title" = "Cohort timing",
    "information" = ""
  ),
  "incidence" = list(
    "result_type" = "incidence",
    "result_id" = c(13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42),
    "output_id" = c(18, 19),
    "icon" = "chart-line",
    "title" = "Incidence",
    "information" = ""
  ),
  "incidence_attrition" = list(
    "result_type" = "incidence_attrition",
    "result_id" = c(43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72),
    "output_id" = c(22),
    "icon" = "layer-group",
    "title" = "Incidence attrition",
    "information" = ""
  ),
  "prevalence" = list(
    "result_type" = "prevalence",
    "result_id" = c(73, 74, 75, 76, 77),
    "output_id" = c(20, 21),
    "icon" = "chart-line",
    "title" = "Prevalence",
    "information" = ""
  ),
  "prevalence_attrition" = list(
    "result_type" = "prevalence_attrition",
    "result_id" = c(78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92),
    "output_id" = c(23),
    "icon" = "layer-group",
    "title" = "Prevalence attrition",
    "information" = ""
  ),
  "summarise_large_scale_characteristics" = list(
    "result_type" = "summarise_large_scale_characteristics",
    "result_id" = c(94, 95, 96, 97, 98, 99),
    "output_id" = c(0),
    "icon" = "arrow-up-right-dots",
    "title" = "Large Scale Characteristics",
    "information" = ""
  )
)

result <- omopgenerics::importSummarisedResult(file.path(getwd(), "data"))
data <- OmopViewer::prepareShinyData(result, panelDetails)
filterValues <- OmopViewer::filterValues(result, panelDetails)

save(data, filterValues, file = file.path(getwd(), "data", "shinyData.RData"))

rm(result, filterValues, panelDetails, data)
