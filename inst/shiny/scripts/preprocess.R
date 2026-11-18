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
library(visOmopResults)
library(shinycssloaders)
library(stringr)
library(CohortSurvival)
library(tidyr)
library(qs2)

source(here::here("scripts", "functions.R"))

# Background descriptions
cli::cli_inform("Importing descriptions")
clinical_descriptions <- PhenotypeR::importClinicalDescription(here::here("data", "raw", "clinical_descriptions"))
database_descriptions <- PhenotypeR::importDatabaseDescription(here::here("data", "raw", "database_descriptions"))

# Create results list
cli::cli_inform("Importing results")
result <- omopgenerics::importSummarisedResult(file.path(getwd(),"data", "raw"), recursive = FALSE)
cli::cli_alert_success("Results imported")

if(nrow(result) == 0){
  cli::cli_warn("No data found in data/raw")
  result <- omopgenerics::emptySummarisedResult()
} else{
  if(any(grepl("^matched_to", result$group_level))){
    result <- result |>
      mutate(group_level = gsub("_matched$","_sampled",group_level)) |>
      mutate(group_level = if_else(grepl("matched_to", group_level), paste0(gsub("^matched_to_","",group_level),"_matched"), group_level))
  }
}

data <- result |>
  settings() |>
  dplyr::select(result_type) |>
  dplyr::distinct() |>
  pull(result_type)

# Convert to named list of character vectors
resultList <- setNames(lapply(data, function(x) list(result_type = x)), data)

# Prepare
dataFiltered <- prepareResult(result, resultList)
values <- getValues(result, resultList)
settingsFiltered <- getSettingsResult(result, resultList)

if(length(dataFiltered) > 0){
  diagnostics <- omopgenerics::settings(result) |> dplyr::pull("diagnostic") |> unique()
  values$shared_cdm_names <- result |>
    dplyr::select("cdm_name") |>
    dplyr::distinct() |>
    dplyr::pull("cdm_name") |>
    sort()

  if((length(diagnostics) >= 1 || diagnostics != "databaseDiagnostics")) {
    # Common variables
    if(length(diagnostics) == 1 && diagnostics == "populationDiagnostics"){
      values$shared_cohort_names <- result |>
        visOmopResults::splitGroup() |>
        dplyr::pull("outcome_cohort_name") |>
        unique() |>
        sort()
    }else{
      values$shared_cohort_names <- result |>
        visOmopResults::splitGroup() |>
        dplyr::select(dplyr::any_of(c("cohort_name", "outcome_cohort_name"))) |>
        dplyr::distinct() |>
        dplyr::filter(!grepl("_sampled|_matched", cohort_name),
                      cohort_name != "overall")
      values$shared_cohort_names  <- c(values$shared_cohort_names$cohort_name,
                                       values$shared_cohort_names$outcome_cohort_name) |>
        unique() |>
        sort()
    }
    values$shared_cohort_names <- values$shared_cohort_names[values$shared_cohort_names != "overall"]
  }
}else{
  diagnostics <- character()
}

# Filter not needed values
values <- filterValues(values, prefix = "summarise_omop_snapshot", sufix_to_include = "cdm_name")
values <- filterValues(values, prefix = "summarise_observation_period", sufix_to_include = "cdm_name")
values <- filterValues(values, prefix = "achilles_code_use", sufix_to_include = c("cdm_name", "codelist_name"))
values <- filterValues(values, prefix = "orphan_code_use", sufix_to_include = c("cdm_name", "codelist_name"))
values <- filterValues(values, prefix = "cohort_code_use", sufix_to_include = c("cdm_name", "cohort_name", "domain"))
values <- filterValues(values, prefix = "summarise_cohort_count", sufix_to_include = c("cdm_name", "cohort_name"))
values <- values[!stringr::str_detect(names(values), "summarise_cohort_attrition")]
values <- filterValues(values, prefix = "summarise_characteristics", sufix_to_include = c("cdm_name", "cohort_name"))
values <- filterValues(values, prefix = "summarise_large_scale_characteristics", sufix_to_include = c("cdm_name", "cohort_name", "table_name", "variable_level", "analysis"))
values <- filterValues(values, prefix = "summarise_cohort_overlap", sufix_to_include = c("cdm_name", "cohort_name", "cohort_name_reference", "cohort_name_comparator", "variable_name", "estimate_name"))
values <- filterValues(values, prefix = "summarise_cohort_timing", sufix_to_include = c("cdm_name", "cohort_name", "cohort_name_reference", "cohort_name_comparator"))
values <- values[!stringr::str_detect(names(values), "incidence_attrition")]
values <- filterValues(values, prefix = "incidence",  sufix_to_include = c("cdm_name", "outcome_cohort_name", "interval", "denominator_age_group", "denominator_sex", "denominator_days_prior_observation"))
values <- values[!stringr::str_detect(names(values), "prevalence_attrition")]
values <- filterValues(values, prefix = "prevalence", sufix_to_include = c("cdm_name", "outcome_cohort_name", "interval", "denominator_age_group", "denominator_sex", "denominator_days_prior_observation"))
values <- filterValues(values, prefix = "survival_probability", sufix_to_include = c("cdm_name", "target_cohort"))
values <- values[!stringr::str_detect(names(values), "survival_events")]
values <- values[!stringr::str_detect(names(values), "survival_summary")]
values <- values[!stringr::str_detect(names(values), "survival_attrition")]

getDateRange <- function(x) {
  x <- as.Date(x)
  x <- x[!is.na(x)]
  if (length(x) == 0) {
    return(c(as.Date("1900-01-01"), Sys.Date()))
  }

  dateRange <- as.Date(c(
    clock::date_start(min(x), precision = "year"),
    clock::date_end(max(x),  precision = "year")
  ))
  if (dateRange[[1]] >= dateRange[[2]]) {
    dateRange[[2]] <- dateRange[[1]] + lubridate::years(1)
  }
  dateRange
}

# Keep slider ranges valid even when a result is absent or has no dates.
if ("summarise_dob_density" %in% names(dataFiltered)) {
  dobRange <- dataFiltered$summarise_dob_density |>
    omopgenerics::tidy() |>
    dplyr::pull("density_x") |>
    getDateRange()
} else {
  dobRange <- c(as.Date("1900-01-01"), Sys.Date())
}
if ("summarise_obs_density" %in% names(dataFiltered)) {
  obsRange <- dataFiltered$summarise_obs_density |>
    omopgenerics::tidy() |>
    dplyr::pull("density_x") |>
    getDateRange()
} else {
  obsRange <- c(as.Date("1900-01-01"), Sys.Date())
}
if ("summarise_trend" %in% names(dataFiltered)) {
  recordRange <- dataFiltered$summarise_trend |>
    omopgenerics::tidy() |>
    dplyr::mutate(time = as.Date(stringr::str_split_i(time_interval, " to", 1))) |>
    dplyr::pull("time") |>
    getDateRange()
} else {
  recordRange <- c(as.Date("1900-01-01"), Sys.Date())
}

minDob <- dobRange[[1]]
maxDob <- dobRange[[2]]
minObs <- obsRange[[1]]
maxObs <- obsRange[[2]]
minRecords <- recordRange[[1]]
maxRecords <- recordRange[[2]]

if("codelistDiagnostics" %in% diagnostics){
  values$achilles_code_use_codelist_name <- values$achilles_code_use_codelist_name |> sort()
  values$orphan_code_use_codelist_name   <- values$orphan_code_use_codelist_name |> sort()
}

if("cohortDiagnostics" %in% diagnostics){
  # Add compare large scale characteristics
  values_subset <- values[stringr::str_detect(names(values), "large_scale")]
  names(values_subset) <- stringr::str_replace(string = names(values_subset), pattern = "summarise", replacement = "compare")
  values_subset$compare_large_scale_characteristics_cohort_1 <- c("original", "sampled", "matched")
  values_subset$compare_large_scale_characteristics_cohort_2 <- c("original", "sampled", "matched")
  values_subset$compare_large_scale_characteristics_cohort_name <- values$shared_cohort_names
  values_subset$compare_large_scale_characteristics_cohort_compare <- values$shared_cohort_names
  values_subset$compare_large_scale_characteristics_variable_level <-values_subset$compare_large_scale_characteristics_variable_level[order(as.numeric(sub(" .*$", "", values_subset$compare_large_scale_characteristics_variable_level)))]
  values <- append(values, values_subset)

  values$summarise_large_scale_characteristics_variable_level <- values_subset$compare_large_scale_characteristics_variable_level

  if("summarise_cohort_overlap" %in% names(dataFiltered)){
    values$summarise_cohort_overlap_cohort_comparator <- values$summarise_cohort_overlap_cohort_name_comparator
    values <- values[!stringr::str_detect(names(values), "summarise_cohort_overlap_cohort_name_comparator")]
  }

  if("survival_probability" %in% names(dataFiltered)){
    # survival
    values$survival_probability_cohort_name <- values$survival_probability_target_cohort
    values <- values[!stringr::str_detect(names(values), "survival_probability_target_cohort")]
  }

}

choices <- values
selected <- choices

msgMatchedSample <- ""
msgCohortSample  <- ""

if("summarise_drug_use" %in% names(dataFiltered)){
  choices$summarise_drug_use_drug_type <- choices$summarise_drug_use_drug_type[order(
    choices$summarise_drug_use_drug_type != "overall",
    choices$summarise_drug_use_drug_type)]
  choices$summarise_drug_use_route <- choices$summarise_drug_use_route[order(
    choices$summarise_drug_use_route != "overall",
    choices$summarise_drug_use_route)]

  selected$summarise_drug_use_drug_type <- "overall"
  selected$summarise_drug_use_route <- "overall"
}

if("cohortDiagnostics" %in% diagnostics){
  settings_cohort_diagnostics <- omopgenerics::settings(result) |>
    dplyr::filter(diagnostic == "cohortDiagnostics")

  typeCohort <- "original"
  if("cohort_sample" %in% colnames(settings_cohort_diagnostics)) {
    cohort_sample <- unique(settings_cohort_diagnostics$cohort_sample)
    cohort_sample <- formatC(cohort_sample, format = "f", digits = 0, big.mark = ",")
    msgCohortSample <- glue::glue("Cohorts were jointly sampled to up to {cohort_sample} participants")
    typeCohort <- "sampled"
  }

  if("matched_sample" %in% colnames(settings_cohort_diagnostics)){
    matched_sample <-  unique(settings_cohort_diagnostics$matched_sample)
    if(all(matched_sample != 0)){
      matched_sample <- formatC(matched_sample, format = "f", digits = 0, big.mark = ",")
      msgMatchedSample <- glue::glue("Matched cohorts were created based on a subsample of ", paste(matched_sample, collapse = " and ")," participants from the {typeCohort} cohorts.")
    }
  }

  if("summarise_large_scale_characteristics" %in% settings_cohort_diagnostics$result_type) {
    selected$summarise_large_scale_characteristics_variable_level <- selected$summarise_large_scale_characteristics_variable_level[1]
    selected$compare_large_scale_characteristics_variable_level <- selected$compare_large_scale_characteristics_variable_level[1]
    selected$compare_large_scale_characteristics_table_name     <- "condition_occurrence"
    selected$compare_large_scale_characteristics_cohort_1  <- "sampled"
    selected$compare_large_scale_characteristics_cohort_2  <- "matched"
    selected$compare_large_scale_characteristics_cohort_compare <- values$compare_large_scale_characteristics_cohort_compare[1]
  }

  if("survival_probability" %in% settings_cohort_diagnostics$result_type){
    selected$survival_probability_cohort_name <- c(paste0(gsub("_matched|sampled", "", selected$survival_probability_cohort_name[1]),"_sampled"),
                                                   paste0(gsub("_matched|sampled", "", selected$survival_probability_cohort_name[1]),"_matched"))

  }
}

min_incidence_start <- as.Date(NA)
max_incidence_end   <- as.Date(NA)
msgPopulationDiag <- ""
if("populationDiagnostics" %in% diagnostics){
  selected$incidence_analysis_interval  <- "years"
  selected$incidence_denominator_age_group <- "0 to 150"
  selected$incidence_denominator_sex <- "Both"
  selected$incidence_denominator_days_prior_observation <- "0"

  selected$prevalence_analysis_interval <- "years"
  selected$prevalence_denominator_age_group <- "0 to 150"
  selected$prevalence_denominator_sex <- "Both"
  selected$prevalence_denominator_days_prior_observation <- "0"

  if("populationDateStart" %in% (omopgenerics::settings(dataFiltered$incidence) |> colnames())){
    min_incidence_start <- as.Date(omopgenerics::settings(dataFiltered$incidence) |> tidyr::drop_na() |> dplyr::pull("populationDateStart") |> unique()) |> na.omit()
    msgPopulationDiag <- paste0("Incidence is calculated using data from ", format(as.Date(min_incidence_start), "%B %d, %Y")," onwards. ")
  }else{
    min_incidence_start <- as.Date(NA)
  }

  if("populationDateEnd" %in% (omopgenerics::settings(dataFiltered$incidence) |> colnames())){
    max_incidence_end <- as.Date(omopgenerics::settings(dataFiltered$incidence) |> tidyr::drop_na() |> dplyr::pull("populationDateEnd") |> unique()) |> na.omit()
    msgPopulationDiag <- paste0("Incidence is calculated up to ", format(as.Date(max_incidence_end), "%B %d, %Y"),". ")
  }else{
    max_incidence_end <- as.Date(NA)
  }

  if(!is.na(min_incidence_start) && !is.na(max_incidence_end)){
    msgPopulationDiag <- paste0("Incidence is calculated from ", format(as.Date(min_incidence_start), "%B %d, %Y"), " until ", format(as.Date(max_incidence_end), "%B %d, %Y"),". ")
  }

  if("populationSample" %in% (omopgenerics::settings(dataFiltered$incidence) |> colnames())){
    populationSample <- as.numeric(omopgenerics::settings(dataFiltered$incidence) |> dplyr::pull("populationSample")) |> unique()
    populationSample <- formatC(populationSample, format = "f", digits = 0, big.mark = ",") |> unique()
    msgPopulationDiag  <- paste0(msgPopulationDiag, "Population diagnostics was performed within a subsample of ", populationSample, " individuals.")
  }
}

# Load expectations results
list_exp <- list.files(path = file.path("data","raw","expectations"), full.names = TRUE)
expectations <- dplyr::bind_rows(purrr:::map(.f = ~readr::read_csv(.), .x = list_exp))  |>
  dplyr::filter(!is.na(.data$cohort_name))
all_diag <- c("cohort_count", "cohort_characteristics", "large_scale_characteristics", "compare_large_scale_characteristics",
              "compare_cohorts", "cohort_survival")
if("diagnostic" %in% colnames(expectations)){
  expectations <- expectations |>
    dplyr::mutate("diagnostic" = if_else(is.na(diagnostic),
                                         paste(all_diag, collapse = ", "),
                                         diagnostic))
}else{
  expectations <- expectations |>
    dplyr::mutate("diagnostic" = paste(all_diag, collapse = ", "))
}

# Panels shown in the app, keyed by the result types that populate them.
panelResultTypes <- list(
  summarise_omop_snapshot = "Snapshot",
  summarise_person = "Person",
  summarise_observation_period = "Observation periods",
  summarise_clinical_records = "Clinical Records",
  cohort_code_use = "Cohort code use",
  achilles_code_use = "Achilles code use",
  orphan_code_use = "Orphan codes",
  measurement_summary = "Measurement Diagnostics",
  summarise_drug_use = "Drug diagnostics",
  summarise_cohort_count = "Cohort count",
  summarise_characteristics = "Cohort characteristics",
  summarise_large_scale_characteristics = c(
    "Large scale characteristics", "Compare large scale characteristics" # TODO add diferentiation
  ),
  summarise_cohort_overlap = "Compare cohorts",
  survival_estimates = "Cohort survival",
  incidence = "Incidence",
  prevalence = "Prevalence"
)
diagnosticsPanels <- unname(unlist(panelResultTypes[names(panelResultTypes) %in% data]))

expectationPanelResults <- c(
  cohort_count_expectations = "summarise_cohort_count",
  cohort_characteristics_expectations = "summarise_characteristics",
  large_scale_characteristics_expectations = "summarise_large_scale_characteristics",
  compare_large_scale_characteristics_expectations = "summarise_large_scale_characteristics",
  compare_cohorts_expectations = "summarise_cohort_overlap",
  cohort_survival_expectations = "survival_estimates"
)
expectationPanelDiagnostics <- c(
  cohort_count_expectations = "cohort_count",
  cohort_characteristics_expectations = "cohort_characteristics",
  large_scale_characteristics_expectations = "large_scale_characteristics",
  compare_large_scale_characteristics_expectations = "compare_large_scale_characteristics",
  compare_cohorts_expectations = "compare_cohorts",
  cohort_survival_expectations = "cohort_survival"
)
availableExpectationDiagnostics <- expectations$diagnostics |>
  as.character() |>
  strsplit(",[[:space:]]*") |>
  unlist(use.names = FALSE) |>
  unique()
expectationsPanels <- names(expectationPanelResults)[
  unname(expectationPanelResults) %in% data &
    unname(expectationPanelDiagnostics) %in% availableExpectationDiagnostics
]

phenotyper_version <- omopgenerics::settings(result) |>
  dplyr::filter(!is.na(phenotyper_version)) |>
  dplyr::pull("phenotyper_version") |>
  unique()

if(length(phenotyper_version)>1){
  cli::cli_warn("Multiple PhenotypeR versions detected in results")
  phenotyper_version <- paste0(phenotyper_version, collapse = "; ")
}

selected$summarise_clinical_description_cohort_name <- selected$shared_cohort_names
choices$summarise_clinical_description_cohort_name <- choices$shared_cohort_names
selected$summarise_database_description_cdm_name <- selected$shared_cdm_names
choices$summarise_database_description_cdm_name <- choices$shared_cdm_names

# Settings pop out----
settingsFiltered <- purrr::map(names(settingsFiltered),
                               \(x) tidySettings(settingsFiltered, x)) |>
  stats::setNames(names(settingsFiltered))

cli::cli_inform("Saving data for shiny")
qs2::qs_savem(dataFiltered,
              selected,
              choices,
              minDob,
              maxDob,
              minObs,
              maxObs,
              minRecords,
              maxRecords,
              min_incidence_start,
              max_incidence_end,
              msgCohortSample,
              msgMatchedSample,
              msgPopulationDiag,
              phenotyper_version,
              expectations,
              clinical_descriptions,
              database_descriptions,
              settingsFiltered,
              diagnostics,
              diagnosticsPanels,
              expectationsPanels,
              file = here::here("data", "appData.qs"))

rm(result, data, expectations, dataFiltered, choices, selected, values, values_subset,
   clinical_descriptions, database_descriptions)
