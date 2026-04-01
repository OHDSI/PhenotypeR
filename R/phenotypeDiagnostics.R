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
#' @param databaseDiagnostics A list of arguments that uses `databaseDiagnostics`. If the list is empty,
#'        the default values will be used.
#'        Example:
#'        *databaseDiagnostics = list(
#'                                "diagnostics" = c("snapshot", "person", "observationPeriods", "clinicalRecords")
#'                                )*
#' @param codelistDiagnostics A list of arguments that uses `codelistDiagnostics`. If the list is empty,
#'        the default values will be used.
#'        Example:
#'        *codelistDiagnostics = list(
#'                                  "diagnostics" = c("achillesCodeUse", "orphanCodeUse", "cohortCodeUse", "drugDiagnostics",
#'                                                    "measurementDiagnostics"),
#'                                  "measurementDiagnosticsSample" = 20000,
#'                                  "drugDiagnosticsSample" = 20000
#'                                )*
#' @param cohortDiagnostics A list of arguments that uses `cohortDiagnostics`. If the list is empty,
#'        the default values will be used.
#'        Example:
#'        *cohortDiagnostics = list(
#'                               "diagnostics" = c("cohortCount", "cohortCharacteristics", "largeScaleCharacteristics",
#'                                                "compareCohorts", "cohortSurvival),
#'                               "cohortSample" = 20000,
#'                               "matchedSample" = 1000
#'                                 )*
#' @param populationDiagnostics A list of arguments that uses `populationDiagnostics`. If the list is empty,
#'        the default values will be used.
#'        Example:
#'        *populationDiagnostics = list(
#'                                  "diagnostics" = c("incidence", "periodPrevalence"),
#'                                  "populationSample" = 1000000,
#'                                  "populationDateRange" = as.Date(c(NA,NA))
#'                                )*
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
#' # Run PhenotypeR with the default values. If you want to check which are the
#' # default values, use:
#' # `formals(populationDiagnostics)`
#' result <- phenotypeDiagnostics(cdm$warfarin)
#'
#' # Notice that the previous line of code will give the same results as typing manually
#' # all the default values:
#' result <- phenotypeDiagnostics(cdm$warfarin,
#'                                databaseDiagnostics = list(
#'                                  "diagnostics" = c("snapshot", "person", "observationPeriods", "clinicalRecords"),
#'                                ),
#'                                codelistDiagnostics = list(
#'                                  "diagnostics" = c("achillesCodeUse", "orphanCodeUse", "cohortCodeUse", "drugDiagnostics",
#'                                                    "measurementDiagnostics"),
#'                                  "measurementDiagnosticsSample" = 20000,
#'                                  "drugDiagnosticsSample" = 20000
#'                                ),
#'                                cohortDiagnostics = list(
#'                                  "diagnostics" = c("cohortCount", "cohortCharacteristics", "largeScaleCharacteristics",
#'                                                    "compareCohorts"),
#'                                  "cohortSample" = 20000,
#'                                  "matchedSample" = 1000
#'                                ),
#'                                populationDiagnostics = list(
#'                                  "diagnostics" = c("incidence", "periodPrevalence"),
#'                                  "populationSample" = 1000000,
#'                                  "populationDateRange" = as.Date(c(NA,NA))
#'                                ))
#'
#' By default, cohortSurvival analysis will not be run. If you want to run it, please use:
#' #' result <- phenotypeDiagnostics(cdm$warfarin,
#'                                cohortDiagnostics = list(
#'                                  "diagnostics" = c("cohortCount", "cohortCharacteristics", "largeScaleCharacteristics",
#'                                                    "compareCohorts", "cohortSurvival")))
#'
#'
#' # Run PhenotypeR with the default values, except for populationSample:
#' result <- phenotypeDiagnostics(cdm$warfarin,
#'                                populationDiagnostics = list("populationSample" = 1000))
#' }
phenotypeDiagnostics <- function(cohort,
                                 databaseDiagnostics = list(),
                                 codelistDiagnostics = list(),
                                 cohortDiagnostics = list(),
                                 populationDiagnostics = list()) {

  # Get arguments
  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  databaseDiagnostics <- checkDatabaseDiagnosticsInput(databaseDiagnostics)
  codelistDiagnostics <- checkCodelistDiagnosticsInput(codelistDiagnostics)
  cohortDiagnostics   <- checkCohortDiagnosticsInput(cohortDiagnostics)
  populationDiagnostics <- checkPopulationDiagnosticsInput(populationDiagnostics)

  # Check if a log file exists
  oldLogFile <- getOption(x = "omopgenerics.logFile", default = NULL)

  if (is.null(oldLogFile)) {
    # If no log file exists, create a new temporary one
    log_file <- tempfile(pattern = "phenotypeDiagnostics_log_{date}_{time}", fileext = ".txt")
    omopgenerics::createLogFile(logFile = log_file)
    on.exit(options("omopgenerics.logFile" = NULL))
  }

  incrementalResultPath <- getOption(x = "PhenotypeR.incremenatl_save_path")

  # Run phenotypeR diagnostics
  cdm <- omopgenerics::cdmReference(cohort)
  results <- list()

  if (!is.null(databaseDiagnostics)) {
    results[["db_diag"]] <- databaseDiagnostics(cohort,
                                                snapshot = databaseDiagnostics$snapshot,
                                                person = databaseDiagnostics$person,
                                                observationPeriods = databaseDiagnostics$observationPeriods,
                                                clinicalRecords = databaseDiagnostics$clinicalRecords)
    if(!is.null(incrementalResultPath)){
      if (dir.exists(incrementalResultPath)) {
        exportSummarisedResult(results[["db_diag"]] ,
                               fileName = "incremental_database_diagnostics.csv",
                               path = incrementalResultPath)
      }
    }
  }

  if (!is.null(codelistDiagnostics)) {
    results[["code_diag"]] <- codelistDiagnostics(cohort,
                                                  achillesCodeUse = codelistDiagnostics$achillesCodeUse,
                                                  orphanCodeUse = codelistDiagnostics$orphanCodeUse,
                                                  cohortCodeUse = codelistDiagnostics$cohortCodeUse,
                                                  drugDiagnostics = codelistDiagnostics$drugDiagnostics,
                                                  measurementDiagnostics = codelistDiagnostics$measurementDiagnostics,
                                                  measurementDiagnosticsSample = codelistDiagnostics$measurementDiagnosticsSample,
                                                  drugDiagnosticsSample = codelistDiagnostics$drugDiagnosticsSample)
    if(!is.null(incrementalResultPath)){
      if (dir.exists(incrementalResultPath)) {
        exportSummarisedResult(results[["code_diag"]],
                               fileName = "incremental_codelist_diagnostics.csv",
                               path = incrementalResultPath)
      }
    }
  }

  if (!is.null(cohortDiagnostics)) {
    results[["cohort_diag"]] <- cohortDiagnostics(cohort,
                                                  cohortCount = cohortDiagnostics$cohortCount,
                                                  cohortCharacteristics = cohortDiagnostics$cohortCharacteristics,
                                                  largeScaleCharacteristics = cohortDiagnostics$largeScaleCharacteristics,
                                                  compareCohorts = cohortDiagnostics$compareCohorts,
                                                  cohortSurvival = cohortDiagnostics$cohortSurvival,
                                                  cohortSample = cohortDiagnostics$cohortSample,
                                                  matchedSample = cohortDiagnostics$matchedSample)
    if(!is.null(incrementalResultPath)){
      if (dir.exists(incrementalResultPath)) {
        exportSummarisedResult(results[["cohort_diag"]] ,
                               fileName = "incremental_cohort_diagnostics.csv",
                               path = incrementalResultPath)
      }
    }
  }
  if (!is.null(populationDiagnostics)) {
    results[["pop_diag"]] <- populationDiagnostics(cohort,
                                                   incidence = populationDiagnostics$incidence,
                                                   periodPrevalence = populationDiagnostics$periodPrevalence,
                                                   populationSample = populationDiagnostics$populationSample,
                                                   populationDateRange = populationDiagnostics$populationDateRange)
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

  return(results)
}
