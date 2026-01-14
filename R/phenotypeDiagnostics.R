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
#' @inheritParams measurementSampleDoc
#' @inheritParams survivalDoc
#' @inheritParams cohortSampleDoc
#' @inheritParams matchedDoc
#' @inheritParams populationSampleDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(omock)
#' library(CohortConstructor)
#' library(PhenotypeR)
#'
#' cdm <- mockCdmFromDataset(source = "duckdb")
#' cdm$warfarin <- conceptCohort(cdm,
#'                               conceptSet =  list(warfarin = c(1310149L,
#'                                                               40163554L)),
#'                               name = "warfarin")
#'
#' result <- phenotypeDiagnostics(cdm$warfarin)
#' }
phenotypeDiagnostics <- function(cohort,
                                 diagnostics = c("databaseDiagnostics", "codelistDiagnostics",
                                                 "cohortDiagnostics", "populationDiagnostics"),
                                 measurementSample = 20000,
                                 survival = FALSE,
                                 cohortSample = 20000,
                                 matchedSample = 1000,
                                 populationSample = 1000000,
                                 populationDateRange = as.Date(c(NA, NA))) {

  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)

  # Setup omopgenerics logging
  log_file <- tempfile(pattern = "phenotypeDiagnostics_log_{date}_{time}", fileext = ".txt")
  omopgenerics::createLogFile(logFile = log_file)
  omopgenerics::logMessage("Phenotype diagnostics - input validation")

  omopgenerics::assertChoice(diagnostics,
                             c("databaseDiagnostics", "codelistDiagnostics",
                               "cohortDiagnostics", "populationDiagnostics"),
                             unique = TRUE)
  checksCohortDiagnostics(survival, cohortSample, matchedSample)
  checksPopulationDiagnostics(populationSample, populationDateRange)

  incrementalResultPath <- getOption(x = "PhenotypeR.incremenatl_save_path")

  # Run phenotypeR diagnostics
  cdm <- omopgenerics::cdmReference(cohort)
  results <- list()
  if ("databaseDiagnostics" %in% diagnostics) {
    results[["db_diag"]] <- databaseDiagnostics(cohort)
    if(!is.null(incrementalResultPath)){
      if (dir.exists(incrementalResultPath)) {
      exportSummarisedResult(results[["db_diag"]] ,
                             fileName = "incremental_database_diagnostics.csv",
                             path = incrementalResultPath)
      }
      }
  }

  if ("codelistDiagnostics" %in% diagnostics) {
    results[["code_diag"]] <- codelistDiagnostics(cohort,
                                                  measurementSample = measurementSample)
    if(!is.null(incrementalResultPath)){
      if (dir.exists(incrementalResultPath)) {
        exportSummarisedResult(results[["code_diag"]],
                               fileName = "incremental_codelist_diagnostics.csv",
                               path = incrementalResultPath)
      }
    }
}

  if ("cohortDiagnostics" %in% diagnostics) {
    results[["cohort_diag"]] <- cohortDiagnostics(cohort,
                                                  survival = survival,
                                                  cohortSample  = cohortSample,
                                                  matchedSample = matchedSample)
    if(!is.null(incrementalResultPath)){
      if (dir.exists(incrementalResultPath)) {
        exportSummarisedResult(results[["cohort_diag"]] ,
                               fileName = "incremental_cohort_diagnostics.csv",
                               path = incrementalResultPath)
      }
    }
  }
  if ("populationDiagnostics" %in% diagnostics) {
    results[["pop_diag"]] <- populationDiagnostics(cohort,
                                                   populationSample = populationSample,
                                                   populationDateRange = populationDateRange)
    if(!is.null(incrementalResultPath)){
      if (dir.exists(incrementalResultPath)) {
        exportSummarisedResult(results[["pop_diag"]] ,
                               fileName = "incremental_population_diagnostics.csv",
                               path = incrementalResultPath)
      }
    }
  }

  omopgenerics::logMessage("Phenotype diagnostics - exporting results")
  results[["log"]] <- omopgenerics::summariseLogFile(
    cdmName = omopgenerics::cdmName(cdm)
  )
  newSettings <- results[["log"]]  |>
    omopgenerics::settings() |>
    dplyr::mutate("phenotyper_version" = as.character(utils::packageVersion(pkg = "PhenotypeR")),
                  "diagnostic" = "Logging")
  results[["log"]] <- results[["log"]] |>
    omopgenerics::newSummarisedResult(settings = newSettings)

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind()

  if (is.null(results)) {
    results <- omopgenerics::emptySummarisedResult()
  }

  unlink(log_file)
  options("omopgenerics.logFile" = NULL)

  results
}
