test_that("test check functions", {
  expect_error(checkDatabaseDiagnosticsInput(databaseDiagnostics = "h"))
  expect_error(checkDatabaseDiagnosticsInput(codelistDiagnostics = list("h" = 1)))
  expect_error(checkDatabaseDiagnosticsInput(codelistDiagnostics = list("h")))
  expect_error(checkDatabaseDiagnosticsInput(databaseDiagnostics = list("diagnostics" = "h")))
  expect_no_error(x <- checkDatabaseDiagnosticsInput(databaseDiagnostics =  NULL))
  expect_true(is.null(x))
  expect_no_error(x <- checkDatabaseDiagnosticsInput(databaseDiagnostics = list()))
  expect_equal(formals("databaseDiagnostics")[-which(names(formals("databaseDiagnostics")) == "cohort")],
               x)

  expect_error(checkCodelistDiagnosticsInput(codelistDiagnostics = "h"))
  expect_error(checkCodelistDiagnosticsInput(codelistDiagnostics = list("h" = 1)))
  expect_error(checkCodelistDiagnosticsInput(codelistDiagnostics = list("h")))
  expect_error(checkCodelistDiagnosticsInput(codelistDiagnostics = list("diagnostics" = "h")))
  expect_error(checkCodelistDiagnosticsInput(codelistDiagnostics = list("measurementDiagnosticsSample" = "h")))
  expect_error(checkCodelistDiagnosticsInput(codelistDiagnostics = list("drugDiagnosticsSample" = "h")))
  expect_no_error(x <- checkCodelistDiagnosticsInput(codelistDiagnostics =  NULL))
  expect_true(is.null(x))
  expect_no_error(x <- checkCodelistDiagnosticsInput(codelistDiagnostics = list()))
  expect_equal(formals("codelistDiagnostics")[-which(names(formals("codelistDiagnostics")) == "cohort")],
               x)

  expect_error(checkCohortDiagnosticsInput(cohortDiagnostics = "h"))
  expect_error(checkCohortDiagnosticsInput(cohortDiagnostics = list("h" = 1)))
  expect_error(checkCohortDiagnosticsInput(cohortDiagnostics = list("h")))
  expect_error(checkCohortDiagnosticsInput(cohortDiagnostics = list("diagnostics" = "h")))
  expect_error(checkCohortDiagnosticsInput(cohortDiagnostics = list("matchedSample" = "h")))
  expect_error(checkCohortDiagnosticsInput(cohortDiagnostics = list("cohortSample" = 0)))
  expect_no_error(x <- checkCohortDiagnosticsInput(cohortDiagnostics =  NULL))
  expect_true(is.null(x))
  expect_no_error(x <- checkCohortDiagnosticsInput(cohortDiagnostics = list()))
  expect_equal(formals("cohortDiagnostics")[-which(names(formals("cohortDiagnostics")) == "cohort")],
               x)

  expect_error(checkPopulationDiagnosticsInput(populationDiagnostics = "h"))
  expect_error(checkPopulationDiagnosticsInput(populationDiagnostics = list("h" = 1)))
  expect_error(checkPopulationDiagnosticsInput(populationDiagnostics = list("h")))
  expect_error(checkPopulationDiagnosticsInput(populationDiagnostics = list("diagnostics" = "h")))
  expect_error(checkPopulationDiagnosticsInput(populationDiagnostics = list("populationSample" = "h")))
  expect_error(checkPopulationDiagnosticsInput(populationDiagnostics = list("populationDateRange" = 0)))
  expect_no_error(x <- checkPopulationDiagnosticsInput(populationDiagnostics =  NULL))
  expect_true(is.null(x))
  expect_no_error(x <- checkPopulationDiagnosticsInput(populationDiagnostics = list()))
  x1 <- formals("populationDiagnostics")[-which(names(formals("populationDiagnostics")) == "cohort")]
  x1$populationDateRange <- eval(x1$populationDateRange)
  expect_equal(x1,
               x)
}
)

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
  expect_no_error(my_result <- phenotypeDiagnostics(cdm$my_cohort,
                                                    populationDiagnostics = list("populationSample" = 10000)))
  cohort_post <- cdm$my_cohort |>
    dplyr::collect()

  # Only database diagnostics
  dd_only <- phenotypeDiagnostics(cdm$my_cohort,
                                  codelistDiagnostics = NULL,
                                  cohortDiagnostics = NULL,
                                  populationDiagnostics = NULL)

  expect_true("summarise_omop_snapshot" %in%
                (settings(dd_only) |> dplyr::pull("result_type")))
  expect_true("summarise_observation_period" %in%
                (settings(dd_only) |> dplyr::pull("result_type")))

  # Only codelist diagnostics
  expect_identical("summarise_log_file",
  c(omopgenerics::settings(phenotypeDiagnostics(cdm$my_cohort,
                                                databaseDiagnostics = NULL,
                                                cohortDiagnostics = NULL,
                                                populationDiagnostics = NULL)) |>
    dplyr::pull("result_type") |>
    unique()))

  # Only cohort diagnostics
  cohort_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                            databaseDiagnostics = NULL,
                                            codelistDiagnostics = NULL,
                                            populationDiagnostics = NULL,
                                            cohortDiagnostics = list("matchedSample" = 0))

  expect_identical(
    c("summarise_characteristics",
          "summarise_cohort_count",
          "summarise_cohort_attrition",
          "summarise_cohort_overlap",
          "summarise_cohort_timing",
          "summarise_large_scale_characteristics",
          "summarise_log_file",
      "summarise_table") |>
      sort(),
          (settings(cohort_diag_only) |>
             dplyr::pull("result_type") |>
             unique()) |>
      sort()
    )
  expect_identical(
      c(cohort_diag_only |>
      omopgenerics::filterSettings(result_type != "summarise_log_file") |>
      dplyr::pull(group_level) |>
      unique() |>
      sort()),
      c("cohort_1", "cohort_1 &&& cohort_2",
        "cohort_2", "cohort_2 &&& cohort_1")
  )

  cohort_pop_diag_only <-  phenotypeDiagnostics(cdm$my_cohort,
                                                databaseDiagnostics = NULL,
                                                codelistDiagnostics = NULL,
                                                cohortDiagnostics = NULL,
                                                populationDiagnostics = list("populationSample" = 10000))
  expect_true(
    all(c("incidence", "incidence_attrition", "prevalence", "prevalence_attrition") %in%
          unique(settings(cohort_pop_diag_only) |>
                   dplyr::pull("result_type"))))

  # logging is included in the overall result
  all_diag <- phenotypeDiagnostics(cdm$my_cohort,
                                   populationDiagnostics = list("populationSample" = 10000))
  log_types <- settings(all_diag) |>
    dplyr::pull("result_type")
  expect_true("summarise_log_file" %in% log_types)
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
  diag <- phenotypeDiagnostics(cdm$my_cohort,
                               populationDiagnostics = list("populationSample" = 10000))
  end_files <- list.files(pathToSave)
  expect_true("incremental_codelist_diagnostics.csv" %in% end_files)
  expect_true("incremental_cohort_diagnostics.csv" %in% end_files)
  expect_true("incremental_database_diagnostics.csv" %in% end_files)
  expect_true("incremental_population_diagnostics.csv" %in% end_files)

  # no error if file doesn't exist
  options("PhenotypeR.incremenatl_save_path" = "not_a_path")
  expect_no_error(phenotypeDiagnostics(cdm$my_cohort,
                                       populationDiagnostics = list("populationSample" = 10000)))

})
