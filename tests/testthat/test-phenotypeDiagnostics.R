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

  original_log_path  <- file.path(tempdir(), omopgenerics::uniqueTableName())
  dir.create(original_log_path, showWarnings = FALSE)
  options("omopgenerics.logFile" = original_log_path)
  omopgenerics::createLogFile(logFile = file.path(original_log_path, "log.txt"))
  omopgenerics::logMessage("start test")

  staging_path <- file.path(tempdir(), omopgenerics::uniqueTableName())
  dir.create(staging_path, showWarnings = FALSE)

  # running diagnostics should leave the original cohort unchanged
  cohort_pre <- cdm$my_cohort |>
    dplyr::collect()
  original_log_summary_pre <- omopgenerics::summariseLogFile(logFile = file.path(original_log_path, "log.txt"))
  logs_pre <- list.files(staging_path, pattern = ".txt")
  results_pre <- list.files(staging_path, pattern = ".csv")
  expect_no_error(my_result <- phenotypeDiagnostics(cdm$my_cohort,
                                                    populationDiagnostics = list("populationSample" = 10000),
                                                    stagingDirectory = staging_path))
  cohort_post <- cdm$my_cohort |>
    dplyr::collect()
  logs_post <- list.files(staging_path, pattern = ".txt")
  results_post <- list.files(staging_path, pattern = ".csv")
  original_log_summary_post <- omopgenerics::summariseLogFile(logFile = file.path(original_log_path, "log.txt"))

  expect_identical(cohort_pre, cohort_post)
  expect_true(length(logs_post) > length(logs_pre))
  # we have incremental
  expect_true(length(results_post) > length(results_pre))
  expect_true("incremental_codelist_diagnostics.csv" %in% results_post)
  expect_true("incremental_cohort_diagnostics.csv" %in% results_post)
  expect_true("incremental_database_diagnostics.csv" %in% results_post)
  expect_true("incremental_population_diagnostics.csv" %in% results_post)
  # we have updated the original log
  expect_true(nrow(original_log_summary_post) >
                nrow(original_log_summary_pre))


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
                                            cohortDiagnostics = list("matchedSample" = 100))

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
      c("cohort_1",
        "cohort_1_matched",
        "cohort_1_sampled",
        "cohort_1 &&& cohort_2",
        "cohort_2",
        "cohort_2_matched",
        "cohort_2_sampled",
        "cohort_2 &&& cohort_1") |> sort()
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
