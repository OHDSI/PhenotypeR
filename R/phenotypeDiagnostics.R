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
#'
#' @inheritParams cohortDoc
#' @param diagnostics Vector indicating which diagnostics to perform. Options
#' include: `databaseDiagnostics`, `codelistDiagnostics`, `cohortDiagnostics`,
#' and `populationDiagnostics`.
#' @inheritParams survivalDoc
#' @inheritParams matchedDoc
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
                                 diagnostics = c("databaseDiagnostics", "codelistDiagnostics",
                                                 "cohortDiagnostics", "populationDiagnostics"),
                                 survival = FALSE,
                                 matchedSample = 1000,
                                 populationSample = 1000000,
                                 populationDateRange = as.Date(c(NA, NA))) {

  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  omopgenerics::assertChoice(diagnostics,
                             c("databaseDiagnostics", "codelistDiagnostics",
                               "cohortDiagnostics", "populationDiagnostics"),
                             unique = TRUE)
  checksCohortDiagnostics(survival, matchedSample)
  checksPopulationDiagnostics(populationSample, populationDateRange)

  cdm <- omopgenerics::cdmReference(cohort)
  results <- list()
  if ("databaseDiagnostics" %in% diagnostics) {
    cli::cli("Running database diagnostics")
    results[["db_diag"]] <- databaseDiagnostics(cdm)
  }
  if ("codelistDiagnostics" %in% diagnostics) {
    cli::cli("Running codelist diagnostics")
    results[["code_diag"]] <- codelistDiagnostics(cohort)
  }
  if ("cohortDiagnostics" %in% diagnostics) {
    cli::cli("Running cohort diagnostics")
    results[["cohort_diag"]] <- cohortDiagnostics(cohort,
                                                  survival = survival,
                                                  matchedSample = matchedSample)
  }
  if ("populationDiagnostics" %in% diagnostics) {
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



