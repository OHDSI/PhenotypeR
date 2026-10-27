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
#' If the list is empty, the default values will be used.
#' Example:
#' In the following example, all default diagnostics will be run except
#' *person table summary* from databaseDiagnostics:
#' `databaseDiagnostics = list("personTableSummary" = FALSE)`
#'
#' If `NULL` database diagnostics won't be executed.
#' @param codelistDiagnostics A list of arguments that uses `codelistDiagnostics`.
#' If the list is empty, the default values will be used.
#' Example:
#' In the below example, all diagnostics will be run, and a subsample of 1,000 participants will
#' be used to run measurement diagnostics and another independent subsample of 500 participants
#' will be used to run drug diagnostics:
#' `codelistDiagnostics = list(
#' "measurementDiagnosticsSample" = 1000,
#' "drugDiagnosticsSample" = 500
#' )`
#'
#' If `NULL` codelist diagnostics won't be executed.
#' @param cohortDiagnostics A list of arguments that uses `cohortDiagnostics`.
#' If the list is empty, the default values will be used.
#' Example:
#' `cohortDiagnostics = list(
#' "cohortSurvival" = TRUE
#' )`
#'
#' If `NULL` cohort diagnostics won't be executed.
#' @param populationDiagnostics A list of arguments that uses `populationDiagnostics`.
#' If the list is empty, the default values will be used.
#' Example:
#' In the below example, all diagnostics will be run and a subsample of 100,000 participants
#' will be used to run populationDiagnostics.
#' `populationDiagnostics = list(
#' "populationSample" = 100000
#' )`
#'
#' If `NULL` population diagnostics won't be executed.
#' @param stagingDirectory Path to folder to save incremental results and log file
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
#' result <- phenotypeDiagnostics(cdm$warfarin)
#'
#' }
phenotypeDiagnostics <- function(cohort,
                                 databaseDiagnostics = list(),
                                 codelistDiagnostics = list(),
                                 cohortDiagnostics = list(),
                                 populationDiagnostics = list(),
                                 stagingDirectory = NULL) {
  # Get arguments
  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)

  databaseDiagnostics <- validateDiagnosticsInput(
    x = {{databaseDiagnostics}},
    diagnostics = "databaseDiagnostics",
    cohort = cohort
  )
  codelistDiagnostics <- validateDiagnosticsInput(
    x = {{codelistDiagnostics}},
    diagnostics = "codelistDiagnostics",
    cohort = cohort
  )
  cohortDiagnostics <- validateDiagnosticsInput(
    x = {{cohortDiagnostics}},
    diagnostics = "cohortDiagnostics",
    cohort = cohort
  )
  populationDiagnostics <- validateDiagnosticsInput(
    x = {{populationDiagnostics}},
    diagnostics = "populationDiagnostics",
    cohort = cohort
  )

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

  # empty initial results
  results <- list()

  n <- length(databaseDiagnostics)
  for (i in seq_len(n)) {
    omopgenerics::logMessage("Running databaseDiagnostics ({i} of {n})")
    diag <- databaseDiagnostics[[i]]
    key <- sprintf("databaseDiagnostics_%03i", i)
    results[[key]] <- databaseDiagnostics(
      cohort = cohort,
      cohortId = diag$cohortId,
      snapshot = diag$snapshot,
      personTableSummary = diag$personTableSummary,
      observationPeriodsSummary = diag$observationPeriodsSummary,
      clinicalRecordsSummary = diag$clinicalRecordsSummary
    )
    saveIncremental(incrementalResultPath, results, "databaseDiagnostics", i, n)
  }

  n <- length(codelistDiagnostics)
  for (i in seq_len(n)) {
    omopgenerics::logMessage("Running codelistDiagnostics ({i} of {n})")
    diag <- codelistDiagnostics[[i]]
    key <- sprintf("codelistDiagnostics_%03i", i)
    results[[key]] <- codelistDiagnostics(
      cohort = cohort,
      cohortId = diag$cohortId,
      achillesCodeUse = diag$achillesCodeUse,
      orphanCodeUse = diag$orphanCodeUse,
      cohortCodeUse = diag$cohortCodeUse,
      drugDiagnostics = diag$drugDiagnostics,
      measurementDiagnostics = diag$measurementDiagnostics,
      measurementDiagnosticsSample = diag$measurementDiagnosticsSample,
      drugDiagnosticsSample = diag$drugDiagnosticsSample
    )
    saveIncremental(incrementalResultPath, results, "codelistDiagnostics", i, n)
  }

  n <- length(cohortDiagnostics)
  for (i in seq_len(n)) {
    omopgenerics::logMessage("Running cohortDiagnostics ({i} of {n})")
    diag <- cohortDiagnostics[[i]]
    key <- sprintf("cohortDiagnostics_%03i", i)
    results[[key]] <- cohortDiagnostics(
      cohort = cohort,
      cohortId = diag$cohortId,
      cohortCount = diag$cohortCount,
      cohortCharacteristics = diag$cohortCharacteristics,
      largeScaleCharacteristics = diag$largeScaleCharacteristics,
      compareCohorts = diag$compareCohorts,
      cohortSurvival = diag$cohortSurvival,
      cohortSample = diag$cohortSample,
      matchedSample = diag$matchedSample
    )
    saveIncremental(incrementalResultPath, results, "cohortDiagnostics", i, n)
  }

  n <- length(populationDiagnostics)
  for (i in seq_len(n)) {
    omopgenerics::logMessage("Running populationDiagnostics ({i} of {n})")
    diag <- populationDiagnostics[[i]]
    key <- sprintf("populationDiagnostics_%03i", i)
    results[[key]] <- populationDiagnostics(
      cohort = cohort,
      cohortId = diag$cohortId,
      incidence = diag$incidence,
      periodPrevalence = diag$periodPrevalence,
      populationSample = diag$populationSample,
      populationDateRange = diag$populationDateRange
    )
    saveIncremental(incrementalResultPath, results, "populationDiagnostics", i, n)
  }

  # export log file
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

saveIncremental <- function(path, result, diag, i, n) {
  if (!is.null(path) && dir.exists(path)) {
    omopgenerics::logMessage("Saving {diag} ({i}/{n}) results in {path}")
    key <- sprintf("%s_%03i", diag, i)
    fileName <- sprintf("incremental_%s_%03i.csv", diag, i)
    exportSummarisedResult(
      result = result[[key]],
      fileName = fileName,
      path = path,
      logFile = NULL,
      logSqlPath = NULL
    )
  }
}
