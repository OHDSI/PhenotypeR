#' Phenotype a cohort
#'
#' @description
#' This comprises all the diagnostics that are being offered in this package,
#' this includes:
#'
#' * A diagnostics on the database via `databaseDiagnostics`.
#' * A diagnostics on the cohort_codelist attribute of the cohort via `codelistDiagnostics`.
#' * A diagnostics on the cohort via `cohortDiagnostics`.
#' * A diagnostics on the population via `populationDiagnostics`.
#' * A diagnostics on the matched cohort via `matchedDiagnostics`.
#'
#' @inheritParams cohortDoc
#' @param databaseDiagnostics If TRUE, database diagnostics will be run.
#' @param codelistDiagnostics If TRUE, codelist diagnostics will be run.
#' @param cohortDiagnostics If TRUE, cohort diagnostics will be run.
#' @param populationDiagnostics If TRUE, population diagnostics will be run.
#' @inheritParams populationSampleDoc
#' @param matchedDiagnostics If TRUE, cohort to population
#' diagnostics will be run.
#' @inheritParams matchedSampleDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#'   cdm_local <- omock::mockCdmReference() |>
#'     omock::mockPerson(nPerson = 100) |>
#'     omock::mockObservationPeriod() |>
#'     omock::mockConditionOccurrence() |>
#'     omock::mockDrugExposure() |>
#'     omock::mockObservation() |>
#'     omock::mockMeasurement() |>
#'     omock::mockCohort(name = "my_cohort",
#'                       numberCohorts = 2)
#'   cdm_local$visit_occurrence <- dplyr::tibble(
#'     person_id = 1L,
#'     visit_occurrence_id = 1L,
#'     visit_concept_id = 1L,
#'     visit_start_date = as.Date("2000-01-01"),
#'     visit_end_date = as.Date("2000-01-01"),
#'     visit_type_concept_id = 1L)
#'   cdm_local$procedure_occurrence <- dplyr::tibble(
#'     person_id = 1L,
#'     procedure_occurrence_id = 1L,
#'     procedure_concept_id = 1L,
#'     procedure_date = as.Date("2000-01-01"),
#'     procedure_type_concept_id = 1L)
#'
#'   db <- DBI::dbConnect(duckdb::duckdb())
#'   cdm <- CDMConnector::copyCdmTo(con = db,
#'                                  cdm = cdm_local,
#'                                  schema ="main",
#'                                  overwrite = TRUE)
#'   phenotypeDiagnostics(cdm$my_cohort)
#'   CDMConnector::cdm_disconnect(cdm)
#' }
phenotypeDiagnostics <- function(cohort,
                                 databaseDiagnostics = TRUE,
                                 codelistDiagnostics = TRUE,
                                 cohortDiagnostics = TRUE,
                                 populationDiagnostics = TRUE,
                                 populationSample = 1000000,
                                 populationDateRange = as.Date(c(NA, NA)),
                                 matchedDiagnostics = TRUE,
                                 matchedSample = 1000) {

  cdm <- omopgenerics::cdmReference(cohort)

  results <- list()
  if (isTRUE(databaseDiagnostics)) {
    cli::cli("Running database diagnostics")
    results[["db_diag"]] <- databaseDiagnostics(cdm)
  }
  if (isTRUE(codelistDiagnostics)) {
    cli::cli("Running codelist diagnostics")
    results[["code_diag"]] <- codelistDiagnostics(cohort)
  }
  if (isTRUE(cohortDiagnostics)) {
    cli::cli("Running cohort diagnostics")
    results[["cohort_diag"]] <- cohortDiagnostics(cohort)
  }
  if (isTRUE(populationDiagnostics)) {
    cli::cli("Running population diagnostics")
    results[["pop_diag"]] <- populationDiagnostics(cohort,
                                                   populationSample = populationSample,
                                                   populationDateRange = populationDateRange)
  }
  if (isTRUE(matchedDiagnostics)) {
    cli::cli("Running matched diagnostics")
    results[["matched_diag"]] <- matchedDiagnostics(cohort,
                                                    matchedSample  = matchedSample
    )
  }

  cli::cli("Combining results")
  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind()

  if (is.null(results)) {
    results <- omopgenerics::emptySummarisedResult()
  }

  results
}
