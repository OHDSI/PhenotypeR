#' Phenotype a cohort
#'
#' @description
#' This comprises all the diagnostics that are being offered in this package,
#' this includes:
#' \itemize{
#'   \item A diagnostic on the OMOP CDM dataset as a whole via \code{databaseDiagnostics}.
#'   \item A diagnostic on the codelists associated with cohorts via \code{codelistDiagnostics}.
#'   \item A diagnostic on the cohort itself via \code{cohortDiagnostics}.
#'   \item A diagnostic on the frequency of the cohort in the dataset population via \code{populationDiagnostics}.
#' }
#'
#' @inheritParams cohortDoc
#' @param databaseDiagnostics A list of arguments that uses `databaseDiagnostics`.
#'  If the list is empty, the default values will be used.
#'  Example:
#'  *databaseDiagnostics = list(
#'  "diagnostics" = c("snapshot", "personTableSummary", "observationPeriodsSummary", "clinicalRecordsSummary")
#'   )
#' @param codelistDiagnostics A list of arguments that uses `codelistDiagnostics`.
#' If the list is empty, the default values will be used.
#' Example:
#' *codelistDiagnostics = list(
#'  "diagnostics" = c("achillesCodeUse", "orphanCodeUse", "cohortCodeUse",
#'  "drugDiagnostics", "measurementDiagnostics"),
#'  "measurementDiagnosticsSample" = 20000,
#'  "drugDiagnosticsSample" = 20000
#'   )
#' @param cohortDiagnostics A list of arguments that uses `cohortDiagnostics`.
#' If the list is empty,
#' the default values will be used.
#' Example:
#' *cohortDiagnostics = list(
#'  "diagnostics" = c("cohortCount", "cohortCharacteristics", "largeScaleCharacteristics",
#'                    "compareCohorts", "cohortSurvival"),
#'  "cohortSample" = 20000,
#'  "matchedSample" = 1000
#'  )
#' @param populationDiagnostics A list of arguments that uses `populationDiagnostics`.
#' If the list is empty, the default values will be used.
#' Example:
#' *populationDiagnostics = list(
#'  "diagnostics" = c("incidence", "periodPrevalence"),
#'  "populationSample" = 100000,
#'  "populationDateRange" = as.Date(c(NA,NA))
#'  )
#'  @param stagingDirectory Path to folder to save incremental results and log file
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
#'                                  "diagnostics" = c("snapshot", "personTableSummary",
#'                                  "observationPeriodsSummary", "clinicalRecordsSummary")
#'                                ),
#'                                codelistDiagnostics = list(
#'                                  "diagnostics" = c("achillesCodeUse", "orphanCodeUse",
#'                                                    "cohortCodeUse", "drugDiagnostics",
#'                                                    "measurementDiagnostics"),
#'                                  "measurementDiagnosticsSample" = 20000,
#'                                  "drugDiagnosticsSample" = 20000
#'                                ),
#'                                cohortDiagnostics = list(
#'                                  "diagnostics" = c("cohortCount", "cohortCharacteristics",
#'                                                    "largeScaleCharacteristics",
#'                                                    "compareCohorts"),
#'                                  "cohortSample" = 20000,
#'                                  "matchedSample" = 1000
#'                                ),
#'                                populationDiagnostics = list(
#'                                  "diagnostics" = c("incidence", "periodPrevalence"),
#'                                  "populationSample" = 100000,
#'                                  "populationDateRange" = as.Date(c(NA,NA))
#'                                ))
#'
#' # By default, cohortSurvival analysis will not be run. If you want to run it, please use:
#' result <- phenotypeDiagnostics(cdm$warfarin,
#'                                cohortDiagnostics = list(
#'                                "diagnostics" = c("cohortCount", "cohortCharacteristics",
#'                                                  "largeScaleCharacteristics",
#'                                                  "compareCohorts", "cohortSurvival")))
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
                                 populationDiagnostics = list(),
                                 stagingDirectory = NULL) {
  # Get arguments
  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  databaseDiagnostics <- checkDatabaseDiagnosticsInput(databaseDiagnostics)
  codelistDiagnostics <- checkCodelistDiagnosticsInput(codelistDiagnostics)
  cohortDiagnostics   <- checkCohortDiagnosticsInput(cohortDiagnostics)
  populationDiagnostics <- checkPopulationDiagnosticsInput(populationDiagnostics)

  existingLogFile <- getOption(x = "omopgenerics.logFile", default = NULL)
  if(!is.null(existingLogFile)){
  options("omopgenerics.logFile" = NULL)
  }

  if(!is.null(stagingDirectory)){
    checkDirectory(stagingDirectory)
    phenotyperLogFile <- file.path(stagingDirectory, "phenotypeDiagnostics_log_{date}_{time}")
  } else {
    phenotyperLogFile <- tempfile(pattern = "phenotypeDiagnostics_log_{date}_{time}",
                                 fileext = ".txt")
  }

  if(!is.null(phenotyperLogFile)) {
    cli::cli_inform("Logging PhenotypeR progress in {phenotyperLogFile}")
    omopgenerics::createLogFile(logFile = phenotyperLogFile)
  }

  incrementalResultPath <- getOption(x = "PhenotypeR.incremenatl_save_path")
  if(!is.null(stagingDirectory)) {
    incrementalResultPath <- stagingDirectory
  }

  # Run phenotypeR diagnostics
  cdm <- omopgenerics::cdmReference(cohort)
  results <- list()

  if (!is.null(databaseDiagnostics)) {
    results[["db_diag"]] <- databaseDiagnostics(cohort,
                                                snapshot = databaseDiagnostics$snapshot,
                                                personTableSummary = databaseDiagnostics$personTableSummary,
                                                observationPeriodsSummary = databaseDiagnostics$observationPeriodsSummary,
                                                clinicalRecordsSummary = databaseDiagnostics$clinicalRecordsSummary)
    if(!is.null(incrementalResultPath)){
      if (dir.exists(incrementalResultPath))
        cli::cli_inform("Savining database diagnostics results in {incrementalResultPath}")
        exportSummarisedResult(results[["db_diag"]] ,
                               fileName = "incremental_database_diagnostics.csv",
                               path = incrementalResultPath)
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
        cli::cli_inform("Savining codelist diagnostics results in {incrementalResultPath}")
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
        cli::cli_inform("Savining cohort diagnostics results in {incrementalResultPath}")
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
        cli::cli_inform("Savining population diagnostics results in {incrementalResultPath}")
        exportSummarisedResult(results[["pop_diag"]] ,
                               fileName = "incremental_population_diagnostics.csv",
                               path = incrementalResultPath)
      }
    }
  }

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

  # if log file existed at the start, copy back to original location
  if (!is.null(existingLogFile)) {
    file.copy(from = getOption(x = "omopgenerics.logFile", default = NULL),
              to = existingLogFile,
              overwrite = TRUE) |>
      invisible()
    options("omopgenerics.logFile" = existingLogFile)
  }

  return(results)
}
