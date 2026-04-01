hasRows <- function(tbl){
  (tbl |>
    utils::head(1) |>
    dplyr::tally() |>
    dplyr::pull("n")) >= 1
}

checkDatabaseDiagnosticsInput <- function(databaseDiagnostics, call = parent.frame()) {
  omopgenerics::assertList(databaseDiagnostics, null = TRUE, call = call)

  diagnostics <- c("snapshot", "person", "observationPeriods", "clinicalRecords")

  if(is.null(databaseDiagnostics)) {
    return(databaseDiagnostics)
  }

  if(!length(databaseDiagnostics) == 0) {
    omopgenerics::assertChoice(names(databaseDiagnostics),
                               choices = c("diagnostics", "drugDiagnosticsSample", "measurementDiagnosticsSample"),
                               unique = TRUE,
                               call = call,
                               msg = "databaseDiagnostics elements must be named `diagnostics`.
                               If you don't want to run databaseDiagnostics, set `databaseDiagnostics = NULL`.")
  }

  if(is.null(databaseDiagnostics$diagnostics)) {
    databaseDiagnostics <- append(databaseDiagnostics,
                                  formals("databaseDiagnostics")[diagnostics])
  } else {
    omopgenerics::assertChoice(databaseDiagnostics$diagnostics,
                               choices = diagnostics,
                               call = call)

    x <- setdiff(diagnostics, databaseDiagnostics$diagnostics)
    databaseDiagnostics <- append(databaseDiagnostics,
                                  purrr::map(x, ~ FALSE) |>
                                    setNames(x))
    databaseDiagnostics <- append(databaseDiagnostics,
                                  purrr::map(databaseDiagnostics$diagnostics, ~ TRUE) |>
                                    setNames(databaseDiagnostics$diagnostics))
  }

  return(databaseDiagnostics)
}

checkCodelistDiagnosticsInput <- function(codelistDiagnostics, call = parent.frame()) {

  omopgenerics::assertList(codelistDiagnostics, null = TRUE, call = call)

  if(is.null(codelistDiagnostics)) {
    return(codelistDiagnostics)
  }

  diagnostics <- c("achillesCodeUse", "orphanCodeUse", "cohortCodeUse", "drugDiagnostics", "measurementDiagnostics")
  measurementDiagnosticsSample <- formals("codelistDiagnostics")$measurementDiagnosticsSample
  drugDiagnosticsSample <- formals("codelistDiagnostics")$measurementDiagnosticsSample

  if(!length(codelistDiagnostics) == 0) {
    omopgenerics::assertChoice(names(codelistDiagnostics),
                               choices = c("diagnostics", "drugDiagnosticsSample", "measurementDiagnosticsSample"),
                               unique = TRUE,
                               call = call,
                               msg = "codelistDiagnostics elements must be named either `diagnostics`, `drugDiagnosticsSample`,
                                 or `measurementDiagnosticsSample`. If you don't want to run codelistDiagnostics, set `codelistDiagnostics = NULL`.")
  }

  if(is.null(codelistDiagnostics$diagnostics)) {
    codelistDiagnostics <- append(codelistDiagnostics,
                                  formals("codelistDiagnostics")[diagnostics])
  } else {
    omopgenerics::assertChoice(codelistDiagnostics$diagnostics,
                               choices = diagnostics,
                               call = call)

    x <- setdiff(diagnostics, codelistDiagnostics$diagnostics)
    codelistDiagnostics <- append(codelistDiagnostics,
                                  purrr::map(x, ~ FALSE) |>
                                    setNames(x))
    codelistDiagnostics <- append(codelistDiagnostics,
                                  purrr::map(codelistDiagnostics$diagnostics, ~ TRUE) |>
                                    setNames(codelistDiagnostics$diagnostics))
  }

  if(is.null(codelistDiagnostics$measurementDiagnosticsSample)) {
    codelistDiagnostics$measurementDiagnosticsSample <- measurementDiagnosticsSample
  } else {
    omopgenerics::assertNumeric(codelistDiagnostics$measurementDiagnosticsSample,
                                integerish = TRUE, min = 1, length = 1, null = TRUE)
  }

  if(is.null(codelistDiagnostics$drugDiagnosticsSample)) {
    codelistDiagnostics$drugDiagnosticsSample <- drugDiagnosticsSample
  } else {
    omopgenerics::assertNumeric(codelistDiagnostics$drugDiagnosticsSample,
                                integerish = TRUE, min = 1, length = 1, null = TRUE)
  }

  return(codelistDiagnostics)
}

checkCohortDiagnosticsInput <- function(cohortDiagnostics, call = parent.frame()) {
  omopgenerics::assertList(cohortDiagnostics, null = TRUE, call = call)

  if(is.null(cohortDiagnostics)) {
    return(cohortDiagnostics)
  }

  diagnostics <- c("cohortCount", "cohortCharacteristics", "largeScaleCharacteristics", "compareCohorts", "cohortSurvival")
  cohortSample <- formals("cohortDiagnostics")$cohortSample
  matchedSample <- formals("cohortDiagnostics")$matchedSample

  if(!length(cohortDiagnostics) == 0) {
    omopgenerics::assertChoice(names(cohortDiagnostics),
                               choices = c("diagnostics", "cohortSample", "matchedSample"),
                               unique = TRUE,
                               call = call,
                               msg = "cohortDiagnostics elements must be named either `diagnostics`, `cohortSample`,
                                 or `matchedSample`. If you don't want to run cohortDiagnostics, set `cohortDiagnostics = NULL`.")
  }

  if(is.null(cohortDiagnostics$diagnostics)) {
    cohortDiagnostics <- append(cohortDiagnostics,
                                formals("cohortDiagnostics")[diagnostics])
  } else {
    omopgenerics::assertChoice(cohortDiagnostics$diagnostics,
                               choices = diagnostics,
                               call = call)

    x <- setdiff(diagnostics, cohortDiagnostics$diagnostics)
    cohortDiagnostics <- append(cohortDiagnostics,
                                purrr::map(x, ~ FALSE) |>
                                  setNames(x))
    cohortDiagnostics <- append(cohortDiagnostics,
                                purrr::map(cohortDiagnostics$diagnostics, ~ TRUE) |>
                                  setNames(cohortDiagnostics$diagnostics))
  }

  if(is.null(cohortDiagnostics$cohortSample)) {
    cohortDiagnostics$cohortSample <- cohortSample
  } else {
    omopgenerics::assertNumeric(cohortDiagnostics$cohortSample,
                                integerish = TRUE, min = 1, null = TRUE, length = 1, call = call)
  }

  if(is.null(cohortDiagnostics$matchedSample)) {
    cohortDiagnostics$matchedSample <- matchedSample
  } else {
    omopgenerics::assertNumeric(cohortDiagnostics$matchedSample,
                                integerish = TRUE, min = 0, null = TRUE, length = 1, call = call)
  }

  return(cohortDiagnostics)
}

checkPopulationDiagnosticsInput <- function(populationDiagnostics, call = parent.frame()) {
  omopgenerics::assertList(populationDiagnostics, null = TRUE, call = call)

  if(is.null(populationDiagnostics)) {
    return(populationDiagnostics)
  }

  diagnostics <- c("incidence", "periodPrevalence")
  populationSample <- formals("populationDiagnostics")$populationSample
  populationDateRange <- eval(formals("populationDiagnostics")$populationDateRange)

  if(!length(populationDiagnostics) == 0) {
    omopgenerics::assertChoice(names(populationDiagnostics),
                               choices = c("diagnostics", "populationSample", "populationDateRange"),
                               unique = TRUE,
                               call = call,
                               msg = "populationDiagnostics elements must be named either `diagnostics`, `populationSample`,
                                 or `populationDateRange`. If you don't want to run populationDiagnostics, set `populationDiagnostics = NULL`.")
  }

  if(is.null(populationDiagnostics$diagnostics)) {
    populationDiagnostics <- append(populationDiagnostics,
                                    formals("populationDiagnostics")[diagnostics])
  } else {
    omopgenerics::assertChoice(populationDiagnostics$diagnostics,
                               choices = diagnostics,
                               call = call)

    x <- setdiff(diagnostics, populationDiagnostics$diagnostics)
    populationDiagnostics <- append(populationDiagnostics,
                                    purrr::map(x, ~ FALSE) |>
                                      setNames(x))
    populationDiagnostics <- append(populationDiagnostics,
                                    purrr::map(populationDiagnostics$diagnostics, ~ TRUE) |>
                                      setNames(populationDiagnostics$diagnostics))
  }

  if(is.null(populationDiagnostics$populationSample)) {
    populationDiagnostics$populationSample <- populationSample
  } else {
    omopgenerics::assertNumeric(populationDiagnostics$populationSample,
                                integerish = TRUE, min = 1, null = TRUE, length = 1, call = call)
  }

  if(is.null(populationDiagnostics$populationDateRange)) {
    populationDiagnostics$populationDateRange <- populationDateRange
  } else {
    omopgenerics::assertDate(populationDiagnostics$populationDateRange,
                             na = TRUE, length = 2, call = call)
  }

  return(populationDiagnostics)
}





