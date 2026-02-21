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

  # Initial checks
  omopgenerics::validateCohortArgument(cohort)

  # Variables
  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  # Snapshot
  if (!is.null(getOption("omopgenerics.logFile"))) {
    omopgenerics::logMessage("Database diagnostics - getting CDM Snapshot")
  }
  results <- list()
  results[["snap"]] <- OmopSketch::summariseOmopSnapshot(cdm)

  # Person table
  if (!is.null(getOption("omopgenerics.logFile"))) {
    omopgenerics::logMessage("Database diagnostics - summarising person table")
  }
  results[["person"]] <- OmopSketch::summarisePerson(cdm)
  results[["dob_density"]] <- cdm$person |>
    PatientProfiles::addDemographics(age = FALSE,
                                     sex = TRUE,
                                     dateOfBirth = TRUE,
                                     priorObservation = FALSE,
                                     futureObservation = FALSE) |>
    PatientProfiles::summariseResult(
      counts = FALSE,
      variables = "date_of_birth",
      estimates = "density")
  results[["dob_density"]] <- results[["dob_density"]] |>
    omopgenerics::newSummarisedResult(
      settings = attr(results[["dob_density"]],
                      "settings") |>
        dplyr::mutate(result_type = "summarise_dob_density"))

  # Observation period
  if (!is.null(getOption("omopgenerics.logFile"))) {
    omopgenerics::logMessage("Database diagnostics - summarising observation period")
  }
  results[["obs_period"]] <- OmopSketch::summariseObservationPeriod(cdm$observation_period)
  results[["obs_density"]] <- cdm$observation_period |>
    PatientProfiles::summariseResult(
      counts = FALSE,
      variables = c("observation_period_start_date",
                    "observation_period_end_date"),
      estimates = "density")
  results[["obs_density"]] <- results[["obs_density"]] |>
    omopgenerics::newSummarisedResult(
      settings = attr(results[["obs_density"]],
                      "settings") |>
        dplyr::mutate(result_type = "summarise_obs_density"))

  # Summarising omop tables - Empty cohort codelist
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
            unique() |>
            sort()
          workingOmopTables <- getTableFromDomain(domains) |>
            stringr::str_split(pattern = ";") |>
            purrr::flatten_chr() |>
            sort()
          workingOmopTables <- intersect(workingOmopTables, names(cdm))
          if(length(workingOmopTables) >= 1) {
            if (!is.null(getOption("omopgenerics.logFile"))) {
              omopgenerics::logMessage("Database diagnostics - summarising clinical tables - summary")
            }
          results[["omop_tabs"]] <- OmopSketch::summariseClinicalRecords(cdm,
                                                                         omopTableName = workingOmopTables)
          if (!is.null(getOption("omopgenerics.logFile"))) {
            omopgenerics::logMessage("Database diagnostics - summarising clinical tables - trends")
          }
          results[["omop_tab_trends"]] <- OmopSketch::summariseTrend(cdm = cdm,
                                            event = workingOmopTables,
                                            output = "record",
                                            interval = "years")
          }
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
                          stringr::str_detect(domain_id,"visit") ~ "visit_occurrence;visit_detail",
                          stringr::str_detect(domain_id,"procedure") ~ "procedure_occurrence",
                          stringr::str_detect(domain_id,"device") ~ "device_exposure"
                        )
        ),
      by = "domain_id"
    ) |>
    dplyr::pull("table") |>
    unique()
}

