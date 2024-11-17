test_that("basic working example with one cohort", {

  skip_on_cran()

  # empty result - should still work without error
  expect_no_error(
    shinyDiagnostics(result = omopgenerics::emptySummarisedResult(),
                     directory = here::here())
    )

  # with results
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
  my_result_code_diag <- cohortDiagnostics(cdm$my_cohort )
  expect_no_error(shinyDiagnostics(my_result_code_diag,
                                   directory = here::here()))

  my_result_cohort_diag <- cdm$my_cohort |> phenotypeDiagnostics()

  expect_no_error(shinyDiagnostics(my_result_cohort_diag,
                                   directory = here::here()))


})
