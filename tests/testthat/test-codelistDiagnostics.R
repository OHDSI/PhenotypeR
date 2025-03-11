test_that("missing codelist attribute", {
  skip_on_cran()

  testthat::skip_on_cran()
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockCohort(name = "my_cohort_1")  |>
    omock::mockCohort(name = "my_cohort_2", numberCohorts = 2)

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)
  attr(cdm, "write_schema") <- "results"

  # Codelist empty
  expect_warning(result <- cdm$my_cohort_1 |>
                   codelistDiagnostics())
  expect_true("summarised_result" %in% class(result))
  expect_identical(result, omopgenerics::emptySummarisedResult())

  # No cohort codelist attribute
  attr(cdm$my_cohort_1, "cohort_codelist") <- NULL
  expect_warning(result <- cdm$my_cohort_1 |>
                   codelistDiagnostics())
  expect_true("summarised_result" %in% class(result))
  expect_identical(result, omopgenerics::emptySummarisedResult())

  # Empty cohorts
  cdm[["my_cohort_2"]] <- cdm[["my_cohort_2"]] |>
    addCodelistAttribute(codelist = list("a" = c(1L,2L)),
                         cohortName = "cohort_1") |>
    addCodelistAttribute(codelist = list("b" = c(1L,2L)),
                         cohortName = "cohort_2")

  cdm$my_cohort_2 <- cdm$my_cohort_2 |>
    CohortConstructor::requireAge(ageRange = c(201,201),
                                  name = "my_cohort_2",
                                  cohortId = c(1))
  expect_no_error(cdm$my_cohort_2 |> codelistDiagnostics())

  CDMConnector::cdmDisconnect(cdm = cdm)
})

