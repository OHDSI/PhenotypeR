test_that("missing codelist attribute", {
  skip_on_cran()

  testthat::skip_on_cran()
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockCohort(name = "my_cohort")

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)
  attr(cdm, "cohort_codelist") <- NULL
  expect_warning(result <- cdm$my_cohort |>
                    codelistDiagnostics())
 expect_true("summarised_result" %in% class(result))
 expect_identical(result, omopgenerics::emptySummarisedResult())

 CDMConnector::cdmDisconnect(cdm = cdm)
})

