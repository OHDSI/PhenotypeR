test_that("overall diagnostics function", {

  skip_on_cran()

  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockVisitOccurrence() |>
    omock::mockProcedureOccurrence() |>
    omock::mockCohort(name = "my_cohort",
                      numberCohorts = 2)

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)

  # running diagnostics should leave the original cohort unchanged
  cohort_pre <- cdm$my_cohort |>
    dplyr::collect()
  expect_no_error(my_result <- phenotypeDiagnostics(cdm$my_cohort))
  cohort_post <- cdm$my_cohort |>
    dplyr::collect()

  # Only database diagnostics
  dd_only <- phenotypeDiagnostics(cdm$my_cohort,
                                  databaseDiagnostics = TRUE,
                                  codelistDiagnostics = FALSE,
                                  cohortDiagnostics = FALSE,
                                  matchedAnalysis = TRUE,
                                  populationDiagnostics = FALSE)
  expect_true("summarise_omop_snapshot" %in%
                (settings(dd_only) |> dplyr::pull("result_type")))
  expect_true("summarise_observation_period" %in%
                (settings(dd_only) |> dplyr::pull("result_type")))

  # Only codelist diagnostics
  expect_identical(phenotypeDiagnostics(cdm$my_cohort,
                                        databaseDiagnostics = FALSE,
                                        codelistDiagnostics = TRUE,
                                        cohortDiagnostics = FALSE,
                                        matchedAnalysis = FALSE,
                                        populationDiagnostics = FALSE),
                   omopgenerics::emptySummarisedResult())


  # Only cohort diagnostics
  expect_identical(phenotypeDiagnostics(cdm$my_cohort,
                                        databaseDiagnostics = FALSE,
                                        codelistDiagnostics = FALSE,
                                        cohortDiagnostics = FALSE,
                                        matchedAnalysis = TRUE,
                                        populationDiagnostics = FALSE),
                   omopgenerics::emptySummarisedResult())


  cohort_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                            databaseDiagnostics = FALSE,
                                            codelistDiagnostics = FALSE,
                                            cohortDiagnostics = TRUE,
                                            matchedAnalysis = FALSE,
                                            populationDiagnostics = FALSE)
  expect_true(
    all(c("summarise_characteristics", "summarise_table",
          "summarise_cohort_attrition",
          "summarise_cohort_attrition",
          "summarise_cohort_overlap", "summarise_cohort_timing",
          "summarise_large_scale_characteristics") %in%
          (settings(cohort_diag_only) |>
             dplyr::pull("result_type") |>
             unique())))
  expect_true(
    all(sort(unique(cohort_diag_only$group_level)) == c("cohort_1", "cohort_1 &&& cohort_2",
                                                        "cohort_2", "cohort_2 &&& cohort_1"))
  )

  cohort_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                            databaseDiagnostics = FALSE,
                                            codelistDiagnostics = FALSE,
                                            cohortDiagnostics = FALSE,
                                            matchedAnalysis = TRUE,
                                            populationDiagnostics = FALSE)
  expect_identical(cohort_diag_only, expected = omopgenerics::emptySummarisedResult())

  cohort_pop_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                            databaseDiagnostics = FALSE,
                                            codelistDiagnostics = FALSE,
                                            cohortDiagnostics = FALSE,
                                            matchedAnalysis = FALSE,
                                            populationDiagnostics = TRUE)
  expect_true(
    all(c("incidence", "incidence_attrition", "prevalence", "prevalence_attrition") %in%
          unique(settings(cohort_pop_diag_only) |>
                   dplyr::pull("result_type"))))

  expect_error(phenotypeDiagnostics(cdm$my_cohort, databaseDiagnostics = "hello"))
  expect_error(phenotypeDiagnostics(cdm$my_cohort, codelistDiagnostics = 1))
  expect_error(phenotypeDiagnostics(cdm$my_cohort, cohortDiagnostics   = "f"))
  expect_error(phenotypeDiagnostics(cdm$my_cohort, matchedAnalysis  = -10))
  expect_error(phenotypeDiagnostics(cdm$my_cohort, populationDiagnostics = "hhh"))

})
