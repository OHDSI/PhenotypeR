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
#' @inheritParams matchedDoc
#' @param populationDiagnostics If TRUE, population diagnostics will be run.
#' @inheritParams populationSampleDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#'
#' cdm <- mockPhenotypeR()
#'
#' result <- phenotypeDiagnostics(cdm$my_cohort)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
phenotypeDiagnostics <- function(cohort,
                                 databaseDiagnostics = TRUE,
                                 codelistDiagnostics = TRUE,
                                 cohortDiagnostics = TRUE,
                                 match = TRUE,
                                 matchedSample = 1000,
                                 populationDiagnostics = TRUE,
                                 populationSample = 1000000,
                                 populationDateRange = as.Date(c(NA, NA))) {
  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  cdm <- omopgenerics::cdmReference(cohort)

  omopgenerics::assertLogical(databaseDiagnostics)
  omopgenerics::assertLogical(codelistDiagnostics)
  omopgenerics::assertLogical(cohortDiagnostics)
  omopgenerics::assertLogical(populationDiagnostics)

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
    results[["cohort_diag"]] <- cohortDiagnostics(cohort, match = match, matchedSample = matchedSample)
  }
  if (isTRUE(populationDiagnostics)) {
    cli::cli("Running population diagnostics")
    results[["pop_diag"]] <- populationDiagnostics(cohort,
                                                   populationSample = populationSample,
                                                   populationDateRange = populationDateRange)
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
