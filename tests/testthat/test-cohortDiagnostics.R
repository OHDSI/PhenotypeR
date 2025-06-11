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
    cohortDiagnostics(match = FALSE))

  # Check all the expected summarised results have been calculated)
  expect_true(all(c((dplyr::pull(omopgenerics::settings(result), "result_type") |> unique()) %in%
                      c("summarise_cohort_attrition", "summarise_cohort_count", "summarise_characteristics",
                    "summarise_table", "summarise_large_scale_characteristics"))))
  expect_true(result$group_level |> unique() == "cohort_1")

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
  expect_warning(result <- cdm$my_cohort |>
                   cohortDiagnostics(match = TRUE))

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
                     sort(),
                   c("cohort_1", "cohort_1_matched", "cohort_1_sampled",
                     "cohort_2", "cohort_2_matched", "cohort_2_sampled"))

  # cohort and timing and overlap should have been estimated now we have more than one cohort
  expect_true(any(stringr::str_detect(
    omopgenerics::settings(result) |>
      dplyr::pull("result_type"),
    "cohort_overlap")))
  expect_true(any(stringr::str_detect(
                   omopgenerics::settings(result) |>
                    dplyr::pull("result_type"),
                   "cohort_timing")))

  # Check matched cohorts
  expect_true(
    all(sort(unique(result$group_level)) == c("cohort_1", "cohort_1 &&& cohort_2", "cohort_1_matched", "cohort_1_sampled",
                                                        "cohort_2", "cohort_2 &&& cohort_1", "cohort_2_matched", "cohort_2_sampled"))
  )

  # Check all the summarised results are there
  expect_true(
    all(result |>
          omopgenerics::settings() |>
          dplyr::pull("result_type")  %in%
        c(rep("summarise_cohort_attrition",2), "summarise_cohort_count", "summarise_cohort_overlap",
        "summarise_cohort_timing", "summarise_characteristics", "summarise_table",
        rep("summarise_large_scale_characteristics", 12))
    )
  )

  # empty death table
  cdm <- omopgenerics::emptyOmopTable(cdm, name = "death")
  expect_warning(cohortDiagnostics(cdm$my_cohort))

  # check survival analysis is being done
  cdm <- mockPhenotypeR()
  result <- cohortDiagnostics(cdm$my_cohort)
  expect_true(all(
    c(rep("summarise_cohort_attrition",2), "summarise_cohort_count", "summarise_cohort_overlap",
      "summarise_cohort_timing", "summarise_characteristics", "summarise_table",
      rep("summarise_large_scale_characteristics", 12), "survival_probability", "survival_events",
      "survival_summary", "survival_attrition"),
    result |>
      omopgenerics::settings() |>
      dplyr::pull("result_type")
  ))
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
