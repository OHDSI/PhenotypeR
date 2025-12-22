#' Database diagnostics
#'
#' @description
#' phenotypeR diagnostics on the cdm object.
#'
#' Diagnostics include:
#' * Summarise a cdm_reference object, creating a snapshot with the metadata of the cdm_reference object.
#' * Summarise the observation period table getting some overall statistics in a summarised_result object.
#' * Summarise the person table including demographics (sex, race, ethnicity, year of birth) and related statistics.
#'
#' @inheritParams cohortDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(omock)
#' library(PhenotypeR)
#' library(CohortConstructor)
#'
#' cdm <- mockCdmFromDataset(source = "duckdb")
#'
#' cdm$new_cohort <- conceptCohort(cdm,
#'                                 conceptSet = list("codes" = c(40213201L, 4336464L)),
#'                                 name = "new_cohort")
#'
# result <- databaseDiagnostics(cohort = cdm$new_cohort)
#
# CDMConnector::cdmDisconnect(cdm = cdm)
#' }
databaseDiagnostics <- function(cohort){

  cli::cli_bullets(c("*" = "Starting Database Diagnostics"))
  # Initial checks
  omopgenerics::validateCohortArgument(cohort)

  # Variables
  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  # Snapshot
  cli::cli_bullets(c(">" = "Getting CDM Snapshot"))
  results <- list()
  results[["snap"]] <- OmopSketch::summariseOmopSnapshot(cdm)

  # Observation period
  cli::cli_bullets(c(">" = "Summarising Observation Period"))
  results[["obs_period"]] <- OmopSketch::summariseObservationPeriod(cdm$observation_period)

  # Person table
  cli::cli_bullets(c(">" = "Summarising Person Table"))
  results[["person"]] <- OmopSketch::summarisePerson(cdm)

  # Summarising omop tables - Empty cohort codelist
  cli::cli_bullets(c(">" = "Summarising OMOP tables"))
  emptyCodelist <- checkEmptyCodelists(cdm = cdm, cohortName = cohortName)

  if(isFALSE(emptyCodelist)){
    # Get all cohorts with codelists
    cohortId <- dplyr::pull(attr(cdm[[cohortName]], "cohort_codelist"), "cohort_definition_id") |> unique()
    cohortIds <- cohortIds[cohortIds %in% cohortId]

    # get all cohort codelists
    all_codelists <- purrr::map(cohortIds, \(x) {
      omopgenerics::cohortCodelist(cohort = cdm[[cohortName]], cohortId = x)
    }) |>
      duplicatedCodelists()

    if(length(all_codelists) == 0){
      cli::cli_warn(message = c("!" = "Cohort has no codelist available."))
    }else{
      # Check empty cohorts
      ids <- omopgenerics::cohortCount(cdm[[cohortName]]) |>
        dplyr::filter(.data$number_subjects == 0) |>
        dplyr::pull("cohort_definition_id")
      cohortIds <- cohortIds[!cohortIds %in% ids]
      if(length(cohortIds) != 0){
        codes <- omopgenerics::cohortCodelist(cohort = cdm[[cohortName]], cohortId = cohortIds)

        if(inherits(codes, "concept_set_expression")){
          cli::cli_warn(message = c("!" = "Concept_set_expression codelists are not supported by PhenotypeR yet.
                                      OMOP tables related to the cohort codelists will not be summarised."))

        }else{
          domains <- CodelistGenerator::associatedDomains(codes, cdm) |>
            purrr::flatten_chr() |>
            unique()
          results[["omop_tabs"]] <- OmopSketch::summariseClinicalRecords(cdm,
                                                                         omopTableName = getTableFromDomain(domains))
        }
      }
    }
  }

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind()

  newSettings <- results |>
    omopgenerics::settings() |>
    dplyr::mutate("phenotyper_version" = as.character(utils::packageVersion(pkg = "PhenotypeR")),
                  "diagnostic" = "databaseDiagnostics")

  results <- results |>
    omopgenerics::newSummarisedResult(settings = newSettings)

  return(results)
}

checkEmptyCodelists <- function(cdm, cohortName, call = parent.frame()){
  if(is.null(attr(cdm[[cohortName]], "cohort_codelist")) ||
     omopgenerics::isTableEmpty(attr(cdm[[cohortName]], "cohort_codelist"))){
    cli::cli_warn(message = c(
      "!" = "cohort_codelist attribute for cohort is empty",
      "i" = "A summary of the OMOP tables related to the codelist in your cohort will not be returned.",
      "i" = "You can add a codelist to a cohort with `addCodelistAttribute()`.",
      call = call
    ))
    return(TRUE)
  }else{
    return(FALSE)
  }
}



getTableFromDomain <- function(domains) {
  dplyr::tibble("domain_id" = tolower(domains)) |>
    dplyr::inner_join(
      dplyr::tibble("domain_id" = c("drug","condition",
                                    "procedure",  "observation",
                                    "measurement", "visit",
                                    "device")) |>
        dplyr::mutate("table" =
                        dplyr::case_when(
                          stringr::str_detect(domain_id,"condition") ~ "condition_occurrence",
                          stringr::str_detect(domain_id,"drug") ~ "drug_exposure",
                          stringr::str_detect(domain_id,"observation") ~ "observation",
                          stringr::str_detect(domain_id,"measurement") ~ "measurement",
                          stringr::str_detect(domain_id,"visit") ~ "visit_occurrence",
                          stringr::str_detect(domain_id,"procedure") ~ "procedure_occurrence",
                          stringr::str_detect(domain_id,"device") ~ "device_exposure"
                        )
        ),
      by = "domain_id"
    ) |>
    dplyr::pull("table") |>
    unique()
}

