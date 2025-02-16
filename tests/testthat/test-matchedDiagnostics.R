test_that("cohort to pop diagnostics", {
  testthat::skip_on_cran()

  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockVisitOccurrence() |>
    omock::mockProcedureOccurrence() |>
    omock::mockCohort(name = "my_cohort")

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)
  expect_no_error(result <- cdm$my_cohort |>
                    matchedDiagnostics())
  # can be NULL and would do no sampling
  cdm$my_cohort |>
    matchedDiagnostics(matchedSample  = NULL)

  # expected errors
  expect_error(matchedDiagnostics(cohort = "not a cohort"))
  expect_error(cdm$my_cohort |>
                    matchedDiagnostics(matchedSample  = 0))
  expect_error(cdm$my_cohort |>
                 matchedDiagnostics(matchedSample  = "a"))
  expect_error(cdm$my_cohort |>
                 matchedDiagnostics(matchedSample  = Inf))


})

test_that("run with multiple cohorts", {
  testthat::skip_on_cran()

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
  expect_no_error(result <- cdm$my_cohort |>
                    matchedDiagnostics())

  expect_identical(sort(unique(result$group_level)),
  c("cohort_1_matched", "cohort_1_sampled",
    "cohort_2_matched", "cohort_2_sampled")
  )

})
