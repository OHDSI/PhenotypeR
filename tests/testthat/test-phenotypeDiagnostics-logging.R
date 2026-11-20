test_that("phenotypeDiagnostics restores logging after a successful run", {
  rlang::local_options(omopgenerics.logFile = NULL, PhenotypeR.run_id = 0L)
  cdm <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 10) |>
    omock::mockObservationPeriod() |>
    omock::mockCohort()

  for (existingLogger in c(FALSE, TRUE)) {
    if (existingLogger) {
      omopgenerics::createLogFile(logFile = tempfile(fileext = ".txt"))
    }
    originalLogFile <- getOption("omopgenerics.logFile")

    expect_no_error(phenotypeDiagnostics(
      cdm$cohort,
      databaseDiagnostics = NULL,
      codelistDiagnostics = NULL,
      cohortDiagnostics = NULL,
      populationDiagnostics = NULL
    ))
    expect_identical(getOption("omopgenerics.logFile"), originalLogFile)
  }
})

test_that("phenotypeDiagnostics restores logging after a diagnostic fails", {
  rlang::local_options(omopgenerics.logFile = NULL)
  cdm <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 10) |>
    omock::mockObservationPeriod() |>
    omock::mockCohort()

  for (existingLogger in c(FALSE, TRUE)) {
    if (existingLogger) {
      omopgenerics::createLogFile(logFile = tempfile(fileext = ".txt"))
    }
    originalLogFile <- getOption("omopgenerics.logFile")

    # Invalid diagnostic arguments fail after the temporary logger is created.
    expect_error(phenotypeDiagnostics(
      cdm$cohort,
      databaseDiagnostics = list(snapshot = "invalid"),
      codelistDiagnostics = NULL,
      cohortDiagnostics = NULL,
      populationDiagnostics = NULL
    ), "`snapshot` is not logical", fixed = TRUE)
    expect_identical(getOption("omopgenerics.logFile"), originalLogFile)
  }
})
