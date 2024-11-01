test_that("overall diagnostics function", {
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockCohort(name = "my_cohort",
                      numberCohorts = 2)
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

  # running diagnostics should leave the original cohort unchanged
  cohort_pre <- cdm$my_cohort |>
    dplyr::collect()
  expect_no_error(my_result <- phenotypeDiagnostics(cdm$my_cohort))
  cohort_post <- cdm$my_cohort |>
    dplyr::collect()
  # expect_identical(cohort_pre,
  #                  cohort_post)

  expect_identical(phenotypeDiagnostics(cdm$my_cohort,
                                        databaseDiagnostics = FALSE,
                                        codelistDiagnostics = FALSE,
                                        cohortDiagnostics = FALSE,
                                        matchedDiagnostics = FALSE,
                                        populationDiagnostics = FALSE),
                   omopgenerics::emptySummarisedResult())

  dd_only <- phenotypeDiagnostics(cdm$my_cohort,
                                  databaseDiagnostics = TRUE,
                                  codelistDiagnostics = FALSE,
                                  cohortDiagnostics = FALSE,
                                  matchedDiagnostics = FALSE,
                                  populationDiagnostics = FALSE)
  expect_true("summarise_omop_snapshot" %in%
                (settings(dd_only) |> dplyr::pull("result_type")))
  expect_true("summarise_observation_period" %in%
                (settings(dd_only) |> dplyr::pull("result_type")))

  # codelist diag will be empty currently
  code_diag_only <- phenotypeDiagnostics(cdm$my_cohort,
                                         databaseDiagnostics = FALSE,
                                         codelistDiagnostics = TRUE,
                                         cohortDiagnostics = FALSE,
                                         matchedDiagnostics = FALSE,
                                         populationDiagnostics = FALSE)

  cohort_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                            databaseDiagnostics = FALSE,
                                            codelistDiagnostics = FALSE,
                                            cohortDiagnostics = TRUE,
                                            matchedDiagnostics = FALSE,
                                            populationDiagnostics = FALSE)
  expect_true(
    all(c("summarise_characteristics", "summarise_table",
          "summarise_cohort_attrition",
          "summarise_cohort_attrition",
          "summarise_cohort_overlap", "summarise_cohort_timing") %in%
          (settings(cohort_diag_only) |>
             dplyr::pull("result_type"))))

  cohort_pop_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                                databaseDiagnostics = FALSE,
                                                codelistDiagnostics = FALSE,
                                                cohortDiagnostics = FALSE,
                                                matchedDiagnostics = TRUE,
                                                populationDiagnostics = FALSE)
  expect_true(
    all(c("summarise_characteristics",
          "summarise_large_scale_characteristics") %in%
          unique(settings(cohort_pop_diag_only) |>
                   dplyr::pull("result_type"))))


})
