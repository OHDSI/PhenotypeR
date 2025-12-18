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
                                  diagnostics = c("databaseDiagnostics"))
  expect_true("summarise_omop_snapshot" %in%
                (settings(dd_only) |> dplyr::pull("result_type")))
  expect_true("summarise_observation_period" %in%
                (settings(dd_only) |> dplyr::pull("result_type")))

  # Only codelist diagnostics
  expect_identical(phenotypeDiagnostics(cdm$my_cohort,
                                        diagnostics = "codelistDiagnostics"),
                   omopgenerics::emptySummarisedResult())


  # Only cohort diagnostics
  cohort_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                            diagnostics = "cohortDiagnostics",
                                            matchedSample = 0)
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

  cohort_pop_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                            diagnostics = "populationDiagnostics")
  expect_true(
    all(c("incidence", "incidence_attrition", "prevalence", "prevalence_attrition") %in%
          unique(settings(cohort_pop_diag_only) |>
                   dplyr::pull("result_type"))))

  # logging is included in the overall result
  all_diag <- phenotypeDiagnostics(cdm$my_cohort)
  log_types <- settings(all_diag) |>
    dplyr::pull("result_type")
  expect_true("summarise_log_file" %in% log_types)

  expect_error(phenotypeDiagnostics(cdm$my_cohort, diagnostics = "hello"))
  expect_error(phenotypeDiagnostics(cdm$my_cohort, matchedSample  = -10))
  expect_error(phenotypeDiagnostics(cdm$my_cohort, populationSample = 0))
  expect_error(phenotypeDiagnostics(cdm$my_cohort, populationDateRange = 0))
})

test_that("incremental save", {

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


  pathToSave <- tempdir()
  options("PhenotypeR.incremenatl_save_path" = pathToSave)
  diag <- phenotypeDiagnostics(cdm$my_cohort)
  end_files <- list.files(pathToSave)
  expect_true("incremental_codelist_diagnostics.csv" %in% end_files)
  expect_true("incremental_cohort_diagnostics.csv" %in% end_files)
  expect_true("incremental_database_diagnostics.csv" %in% end_files)
  expect_true("incremental_population_diagnostics.csv" %in% end_files)

  # no error if file doesn't exist
  options("PhenotypeR.incremenatl_save_path" = "not_a_path")
  expect_no_error(phenotypeDiagnostics(cdm$my_cohort))

})
