#' Run cohort-level diagnostics
#'
#' @description
#' Runs phenotypeR diagnostics on the cohort.
#' The diganotics include:
#' * Age groups and sex summarised.
#' * A summary of visits of everyone in the cohort using visit_occurrence table.
#' * A summary of age and sex density of the cohort.
#' * Attritions of the cohorts.
#' * Overlap between cohorts (if more than one cohort is being used).
#'
#' @inheritParams cohortDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#'   cdm_local <- omock::mockCdmReference() |>
#'    omock::mockPerson(nPerson = 100) |>
#'    omock::mockObservationPeriod() |>
#'    omock::mockConditionOccurrence() |>
#'    omock::mockDrugExposure() |>
#'    omock::mockObservation() |>
#'    omock::mockMeasurement() |>
#'    omock::mockCohort(name = "my_cohort")
#'    cdm_local$visit_occurrence <- dplyr::tibble(
#'     person_id = 1L,
#'     visit_occurrence_id = 1L,
#'     visit_concept_id = 1L,
#'     visit_start_date = as.Date("2000-01-01"),
#'     visit_end_date = as.Date("2000-01-01"),
#'     visit_type_concept_id = 1L
#'     )
#'     cdm_local$procedure_occurrence <- dplyr::tibble(
#'       person_id = 1L,
#'       procedure_occurrence_id = 1L,
#'       procedure_concept_id = 1L,
#'       procedure_date = as.Date("2000-01-01"),
#'       procedure_type_concept_id = 1L
#'       )
#'  db <- DBI::dbConnect(duckdb::duckdb())
#'  cdm <- CDMConnector::copyCdmTo(con = db,
#'                                 cdm = cdm_local,
#'                                 schema ="main",
#'                                 overwrite = TRUE)
#'
#'  cdm$my_cohort |> cohortDiagnostics()
#'  CDMConnector::cdmDisconnect(cdm = cdm)
#' }

cohortDiagnostics <- function(cohort){

  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  prefix <- omopgenerics::tmpPrefix()
  tempCohortName  <- paste0(prefix, cohortName)
  results <- list()

  cdm[[tempCohortName]]  <- cdm[[cohortName]] |>
    PatientProfiles::addAge(ageGroup = list(c(0, 17), c(18, 64), c(65, 150))) |>
    PatientProfiles::addSex() |>
    CDMConnector::compute(name = tempCohortName, temporary = FALSE)

  cli::cli_bullets(c("*" = "Getting cohort summary"))
  results[["cohort_summary"]] <- cdm[[tempCohortName]] |>
    CohortCharacteristics::summariseCharacteristics(
      strata = list("age_group", "sex"),
      tableIntersectCount = list(
        "Number visits prior year" = list(
          tableName = "visit_occurrence",
          window = c(-365, -1)
        )
      )
    )

  cli::cli_bullets(c("*" = "Getting age density"))
  results[["cohort_density"]] <- cdm[[tempCohortName]] |>
    PatientProfiles::summariseResult(
      strata    = "sex",
      includeOverallStrata = FALSE,
      variables = "age",
      estimates = "density") |>
    suppressMessages()

  omopgenerics::dropTable(cdm, dplyr::starts_with(prefix))

  cli::cli_bullets(c("*" = "Getting cohort attrition"))
  results[["cohort_attrition"]] <- cdm[[cohortName]] |>
    CohortCharacteristics::summariseCohortAttrition()

  if(length(cohortIds) > 1){
    cli::cli_bullets(c("*" = "Getting cohort overlap"))
    results[["cohort_overlap"]] <-  cdm[[cohortName]] |>
      CohortCharacteristics::summariseCohortOverlap()

    cli::cli_bullets(c("*" = "Getting cohort timing"))
    results[["cohort_timing"]] <- cdm[[cohortName]] |>
      CohortCharacteristics::summariseCohortTiming(estimates = "density")
    }

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind() |>
    omopgenerics::newSummarisedResult()

  results
}
