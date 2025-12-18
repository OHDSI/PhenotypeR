test_that("basic working example with one cohort", {

  skip_on_cran()

  # empty result - should still work without error
  expect_no_error(
    shinyDiagnostics(result = omopgenerics::emptySummarisedResult(),
                     directory = tempdir())
    )

  # with results
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockVisitOccurrence() |>
    omock::mockProcedureOccurrence() |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2)

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)

  my_result_cohort_diag <- cdm$my_cohort |> phenotypeDiagnostics()

  expect_no_error(shinyDiagnostics(my_result_cohort_diag,
                                   directory = tempdir()))

  expect_error(shinyDiagnostics(my_result_cohort_diag,
               directory = tempdir(),
               expectations = 0))

  my_results1 <- omopgenerics::newSummarisedResult(my_result_cohort_diag,
                                                   settings = my_result_cohort_diag |>
                                                     omopgenerics::settings() |>
                                                     dplyr::mutate("phenotyper_version" = "0"))

  expect_warning(shinyDiagnostics(my_results1, tempdir(), open = FALSE))
})

test_that("only one diagnostic", {

  skip_on_cran()
  CDMConnector::requireEunomia()
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir())
  cdm <- CDMConnector::cdmFromCon(con = con,
                                  cdmName = "Eunomia Synpuf",
                                  cdmSchema   = "main",
                                  writeSchema = "main")

  cdm$new_cohort <- CohortConstructor::conceptCohort(cdm, conceptSet = list("concept" = 40481087L), name = "new_cohort")

  # examples with single diagnostics ----
  result <- databaseDiagnostics(cdm)
  expect_no_error(shinyDiagnostics(result, directory = tempdir()))

  result <- codelistDiagnostics(cdm$new_cohort)
  expect_warning(shinyDiagnostics(result, directory = tempdir()))

  result <- cohortDiagnostics(cdm$new_cohort, survival = FALSE)
  expect_warning(shinyDiagnostics(result, directory = tempdir()))

  result <- populationDiagnostics(cdm$new_cohort)
  expect_no_error(shinyDiagnostics(result, directory = tempdir()))
})


