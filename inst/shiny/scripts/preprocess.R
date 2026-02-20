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

if(length(dataFiltered) > 0){
  diagnostics <- omopgenerics::settings(result) |> dplyr::pull("diagnostic") |> unique()
  values$shared_cdm_names <- rbind(dataFiltered$summarise_omop_snapshot,
                                   dataFiltered$cohort_code_use,
                                   dataFiltered$summarise_cohort_count,
                                   dataFiltered$incidence) |>
    dplyr::select("cdm_name") |>
    dplyr::distinct() |>
    dplyr::pull("cdm_name") |>
    sort()
  if((length(diagnostics) > 1 || diagnostics != "databaseDiagnostics")) {
    # Common variables
    if(length(diagnostics) == 1 && diagnostics == "populationDiagnostics"){
      values$shared_cohort_names <- dataFiltered$incidence |>
        visOmopResults::splitGroup() |>
        dplyr::pull("outcome_cohort_name") |>
        unique() |>
        sort()
    }else{
      values$shared_cohort_names <- rbind(dataFiltered$cohort_code_use, dataFiltered$summarise_cohort_count, dataFiltered$incidence) |>
        dplyr::mutate(group_name = gsub("outcome_cohort_name", "cohort_name", group_name)) |>
        visOmopResults::splitGroup() |>
        dplyr::select("cohort_name") |>
        dplyr::distinct() |>
        dplyr::filter(cohort_name != "overall") |>
        dplyr::pull("cohort_name") |>
        sort()
    }
  }
}else{
  diagnostics <- ""
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

# Pre-define some selected
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
  values_subset$compare_large_scale_characteristics_variable_level <- c("-inf to -366", "-365 to -31", "-30 to -1", "0 to 0", "1 to 30", "31 to 365", "366 to inf")
  values <- append(values, values_subset)

  values$summarise_large_scale_characteristics_variable_level <-c("-inf to -366", "-365 to -31", "-30 to -1", "0 to 0", "1 to 30", "31 to 365", "366 to inf")

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
  selected$summarise_large_scale_characteristics_variable_level <- "-inf to -366"
  selected$compare_large_scale_characteristics_variable_level <- "-inf to -366"
  selected$compare_large_scale_characteristics_table_name     <- "condition_occurrence"
  selected$compare_large_scale_characteristics_cohort_1  <- "sampled"
  selected$compare_large_scale_characteristics_cohort_2  <- "matched"
  selected$compare_large_scale_characteristics_compare_cohort <- values$compare_large_scale_characteristics_compare_cohort[1]

  if("survival_probability" %in% names(dataFiltered)){
    selected$survival_probability_cohort_name <- c(paste0(gsub("_matched|sampled", "", selected$survival_probability_cohort_name[1]),"_sampled"),
                                                   paste0(gsub("_matched|sampled", "", selected$survival_probability_cohort_name[1]),"_matched"))

  }

  typeCohort <- "original"
  if("cohort_sample" %in% (omopgenerics::settings(result) |> colnames())){
    cohort_sample <- as.numeric(omopgenerics::settings(dataFiltered$summarise_large_scale_characteristics) |> dplyr::pull("cohort_sample") |> unique())
    cohort_sample <- formatC(cohort_sample, format = "f", digits = 0, big.mark = ",")
    msgCohortSample <- glue::glue("Cohorts were sampled to up to {cohort_sample} participants")
    typeCohort <- "sampled"
  }

  if("matched_sample" %in% (omopgenerics::settings(result) |> colnames())){
    matched_sample <- as.numeric(omopgenerics::settings(dataFiltered$summarise_large_scale_characteristics) |> dplyr::pull("matched_sample") |> unique())
    if(all(matched_sample != 0)){
      matched_sample <- formatC(matched_sample, format = "f", digits = 0, big.mark = ",")
      msgMatchedSample <- glue::glue("Matched cohorts were created based on a subsample of ", paste(matched_sample, collapse = " and ")," participants from the {typeCohort} cohorts.")
    }
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
    min_incidence_start <- as.Date(omopgenerics::settings(dataFiltered$incidence) |> tidyr::drop_na() |> dplyr::pull("populationDateStart") |> unique())
    msgPopulationDiag <- paste0("Incidence is calculated using data from ", format(as.Date(min_incidence_start), "%B %d, %Y")," onwards. ")
  }else{
    min_incidence_start <- as.Date(NA)
  }

  if("populationDateEnd" %in% (omopgenerics::settings(dataFiltered$incidence) |> colnames())){
    max_incidence_end <- as.Date(omopgenerics::settings(dataFiltered$incidence) |> tidyr::drop_na() |> dplyr::pull("populationDateEnd") |> unique())
    msgPopulationDiag <- paste0("Incidence is calculated up to ", format(as.Date(max_incidence_end), "%B %d, %Y"),". ")
  }else{
    max_incidence_end <- as.Date(NA)
  }

  if(!is.na(min_incidence_start) && !is.na(max_incidence_end)){
    msgPopulationDiag <- paste0("Incidence is calculated from ", format(as.Date(min_incidence_start), "%B %d, %Y"), " until ", format(as.Date(max_incidence_end), "%B %d, %Y"),". ")
  }

  if("populationSample" %in% (omopgenerics::settings(dataFiltered$incidence) |> colnames())){
    populationSample <- as.numeric(omopgenerics::settings(dataFiltered$incidence) |> dplyr::pull("populationSample") |> unique())
    populationSample <- formatC(populationSample, format = "f", digits = 0, big.mark = ",")
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
phenotyper_version <- omopgenerics::settings(result) |>
  dplyr::filter(!is.na(phenotyper_version)) |>
  dplyr::pull("phenotyper_version") |>
  unique()
if(length(phenotyper_version)>1){
cli::cli_warn("Multiple PhenotypeR versions detected in results")
phenotyper_version <- paste0(phenotyper_version, collapse = "; ")
}
cli::cli_inform("Saving data for shiny")
qs2::qs_savem(dataFiltered,
     selected,
     choices,
     min_incidence_start,
     max_incidence_end,
     msgCohortSample,
     msgMatchedSample,
     msgPopulationDiag,
     phenotyper_version,
     expectations,
     file = here::here("data", "appData.qs"))

rm(result, data, expectations, dataFiltered, choices, selected, values, values_subset)

