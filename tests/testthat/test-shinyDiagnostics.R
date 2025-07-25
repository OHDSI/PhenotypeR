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
  my_result_code_diag <- cohortDiagnostics(cdm$my_cohort)
  expect_no_error(shinyDiagnostics(my_result_code_diag,
                                   directory = tempdir()))

  my_result_cohort_diag <- cdm$my_cohort |> phenotypeDiagnostics()

  expect_no_error(shinyDiagnostics(my_result_cohort_diag,
                                   directory = tempdir(),
                                   open = FALSE))

  expect_error(shinyDiagnostics(my_result_cohort_diag,
               directory = tempdir(),
               expectations = 0))

  my_results1 <- omopgenerics::newSummarisedResult(my_result_cohort_diag,
                                                   settings = my_result_cohort_diag |>
                                                     omopgenerics::settings() |>
                                                     dplyr::mutate("phenotyper_version" = "0"))

  expect_warning(shinyDiagnostics(my_results1, tempdir(), open = FALSE))

  my_results1 <- omopgenerics::newSummarisedResult(my_result_cohort_diag,
                                                   settings = my_result_cohort_diag |>
                                                     omopgenerics::settings() |>
                                                     dplyr::mutate("phenotyper_version" = c(rep(c("1","2"),24),"1")))

  expect_warning(shinyDiagnostics(my_results1, tempdir(), open = FALSE))


})
