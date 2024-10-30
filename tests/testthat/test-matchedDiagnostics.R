test_that("cohort to pop diagnostics", {
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockCohort(name = "my_cohort")
  cdm_local$visit_occurrence <- dplyr::tibble(
    person_id = 1L,
    visit_occurrence_id = 1L,
    visit_concept_id = 1L,
    visit_start_date = as.Date("2000-01-01"),
    visit_end_date = as.Date("2000-01-01"),
    visit_type_concept_id = 1L
  )
  cdm_local$procedure_occurrence <- dplyr::tibble(
    person_id = 1L,
    procedure_occurrence_id = 1L,
    procedure_concept_id = 1L,
    procedure_date = as.Date("2000-01-01"),
    procedure_type_concept_id = 1L
  )

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
