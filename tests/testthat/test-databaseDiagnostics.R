test_that("multiplication works", {
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
 expect_identical(settings(db_diag)$result_type,
                  c("summarise_omop_snapshot", "summarise_observation_period", "summarise_person"))

  # Only one codelist
  cdm$my_cohort <- cdm$my_cohort |>
    omopgenerics::newCohortTable() |>
    addCodelistAttribute(
      codelist = list(a = c(37110496L, 45430573L, 1361368L, 45438358L), b = 40371897L),
      cohortName = c("cohort_1", "cohort_1")
    )
  expect_no_error(db_diag <- databaseDiagnostics(cdm$my_cohort))
  expect_identical(c("summarise_omop_snapshot", "summarise_observation_period", "summarise_person", "summarise_clinical_records"),
                   settings(db_diag)$result_type)
  expect_identical(db_diag$group_level |> unique(),
                   c("overall", "all", "1st", "condition_occurrence", "drug_exposure"))
  expect_no_error(OmopSketch::tableOmopSnapshot(db_diag))
  expect_no_error(OmopSketch::tableClinicalRecords(db_diag))
  expect_identical(db_diag |>
                     omopgenerics::settings() |>
                     dplyr::pull("diagnostic") |>
                     unique(),
                   "databaseDiagnostics")

  CDMConnector::cdmDisconnect(cdm = cdm)

})
