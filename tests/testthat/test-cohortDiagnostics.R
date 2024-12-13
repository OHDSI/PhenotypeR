test_that("run with a single cohort", {
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
    cohortDiagnostics())

  # check density is being calculated
  expect_true(any(stringr::str_detect(
    omopgenerics::settings(result) |>
      dplyr::pull("result_type"),
    "table")))

  # cohort and timing and overlap should have been skipped
  expect_false(any("summarise_cohort_overlap" ==
   omopgenerics::settings(result) |>
    dplyr::pull("result_type")))

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
                    cohortDiagnostics())

  # check density is being calculated
  expect_true(any(stringr::str_detect(
    omopgenerics::settings(result) |>
      dplyr::pull("result_type"),
    "table")))

  # Check density is calculated by cohort
  expect_identical(result |>
      dplyr::filter(variable_name == "age") |>
      dplyr::select("group_level") |>
      dplyr::distinct() |>
      dplyr::pull() |>
      dplyr::arrange(),
    c("cohort_1", "cohort_2"))

  # cohort and timing and overlap should have been estimated now we have more than one cohort
  expect_true(any(stringr::str_detect(
    omopgenerics::settings(result) |>
      dplyr::pull("result_type"),
    "cohort_overlap")))
  expect_true(any(stringr::str_detect(
                   omopgenerics::settings(result) |>
                    dplyr::pull("result_type"),
                   "cohort_timing")))
})

test_that("check all expected analyses are present in results", {

})

test_that("check input validation", {

})

test_that("check edge cases", {
  # check behaviour if cohort table has no records

  # check behaviour if one cohort has no records but others do
})

test_that("check table and plotting functionality work", {
  # check the functions do not throw errors
  # (these tests don't check whether the plots look nice)

})
