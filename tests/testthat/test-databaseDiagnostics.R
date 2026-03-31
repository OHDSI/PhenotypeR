test_that("db diagnostics", {
  testthat::skip_on_cran()

  # Create cdm ----
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

  # Empty codelist
  expect_warning(db_diag <- databaseDiagnostics(cdm$my_cohort))
  expect_equal(settings(db_diag)$result_type |>
                 unique() |>
                 sort(),
               c("summarise_dob_density", "summarise_obs_density",
                 "summarise_observation_period",
                 "summarise_omop_snapshot", "summarise_person") )

  # Only one codelist
  cdm$my_cohort <- cdm$my_cohort |>
    omopgenerics::newCohortTable() |>
    addCodelistAttribute(
      codelist = list(a = c(37110496L, 45430573L, 1361368L, 45438358L), b = 40371897L),
      cohortName = c("cohort_1", "cohort_1")
    )
  expect_no_error(db_diag <- databaseDiagnostics(cdm$my_cohort))
  expect_equal(settings(db_diag)$result_type |>
                 unique() |>
                 sort(),
               c("summarise_clinical_records",
                 "summarise_dob_density", "summarise_obs_density",
                 "summarise_observation_period",
                 "summarise_omop_snapshot", "summarise_person", "summarise_trend"))

  expect_no_error(OmopSketch::tableOmopSnapshot(db_diag))
  expect_no_error(OmopSketch::tableClinicalRecords(db_diag))
  expect_identical(db_diag |>
                     omopgenerics::settings() |>
                     dplyr::pull("diagnostic") |>
                     unique(),
                   "databaseDiagnostics")

  # skip clinical table summary
  expect_no_error(db_diag_no_clinical_summary <- databaseDiagnostics(cdm$my_cohort,
                                                                     clinicalRecords = FALSE))
  expect_false("summarise_clinical_records" %in%
                 (omopgenerics::settings(db_diag_no_clinical_summary) |>
                    dplyr::pull("result_type")))
  expect_false("summarise_trend" %in%
                 (omopgenerics::settings(db_diag_no_clinical_summary) |>
                    dplyr::pull("result_type")))

  CDMConnector::cdmDisconnect(cdm = cdm)

})
