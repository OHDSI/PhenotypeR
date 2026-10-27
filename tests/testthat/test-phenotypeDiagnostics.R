test_that("test check functions", {
  diagnostics_names <- c(
    "databaseDiagnostics",
    "codelistDiagnostics",
    "cohortDiagnostics",
    "populationDiagnostics"
  )

  for (diagnostics in diagnostics_names) {
    expect_error(validateDiagnosticsInput("h", diagnostics, cohort = NULL))
    expect_error(validateDiagnosticsInput(list("h" = 1), diagnostics, cohort = NULL))
    expect_error(validateDiagnosticsInput(list("h"), diagnostics, cohort = NULL))
    expect_error(validateDiagnosticsInput(list(list("h" = 1)), diagnostics, cohort = NULL))
    expect_no_error(x <- validateDiagnosticsInput(NULL, diagnostics, cohort = NULL))
    expect_null(x)
    expect_no_error(x <- validateDiagnosticsInput(list(), diagnostics, cohort = NULL))

    expected <- formals(get(diagnostics, envir = asNamespace("PhenotypeR"))) |>
      purrr::discard(rlang::is_missing) |>
      purrr::map(eval)
    expect_identical(x, list(expected))
    expect_identical(
      validateDiagnosticsInput(list(list()), diagnostics, cohort = NULL),
      list(expected)
    )
  }
}
)

test_that("diagnostic configurations preserve tidyselect expressions", {
  cdm <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 10) |>
    omock::mockObservationPeriod() |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2)

  prefix <- "cohort_1"
  for (diagnostics in c("databaseDiagnostics", "codelistDiagnostics",
                        "cohortDiagnostics", "populationDiagnostics")) {
    single <- validateDiagnosticsInput(
      list(cohortId = dplyr::starts_with(prefix)), diagnostics, cdm$my_cohort
    )
    multiple <- validateDiagnosticsInput(
      list(
        list(cohortId = dplyr::starts_with(prefix)),
        list(cohortId = dplyr::ends_with("_2"))
      ),
      diagnostics, cdm$my_cohort
    )

    expect_length(single, 1)
    expect_identical(single[[1]]$cohortId, 1L)
    expect_length(multiple, 2)
    expect_identical(multiple[[1]], single[[1]])
    expect_identical(multiple[[2]]$cohortId, 2L)

    configuration <- list(cohortId = 1L)
    configurations <- list(configuration, list(cohortId = 2L))
    expect_identical(
      validateDiagnosticsInput(configuration, diagnostics, cdm$my_cohort), single
    )
    expect_identical(
      validateDiagnosticsInput(configurations, diagnostics, cdm$my_cohort), multiple
    )
  }

  single <- validateDiagnosticsInput(
    list(cohortId = 1, clinicalRecordsSummary = TRUE),
    "databaseDiagnostics", cdm$my_cohort
  )
  expect_identical(single[[1]]$cohortId, 1L)
  expect_true(single[[1]]$clinicalRecordsSummary)
  expect_identical(
    single,
    validateDiagnosticsInput(
      list(list(cohortId = 1, clinicalRecordsSummary = TRUE)),
      "databaseDiagnostics", cdm$my_cohort
    )
  )

  evaluation <- new.env(parent = emptyenv())
  evaluation$done <- FALSE
  expect_error(
    validateDiagnosticsInput(
      list(
        list(cohortId = dplyr::starts_with(prefix), snapshot = {
          evaluation$done <- TRUE
          TRUE
        }),
        list(cohortId = 99)
      ),
      "databaseDiagnostics", cdm$my_cohort
    ),
    "not defined"
  )
  expect_false(evaluation$done)
})

test_that("overall diagnostics function", {

  skip_on_cran()

  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 5000) |>
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

  expect_no_error(phenotypeDiagnostics(
    cdm$my_cohort,
    databaseDiagnostics = NULL,
    codelistDiagnostics = NULL,
    cohortDiagnostics = list(
      cohortId = dplyr::starts_with("cohort_1"),
      cohortCount = TRUE,
      cohortCharacteristics = FALSE,
      largeScaleCharacteristics = FALSE,
      compareCohorts = FALSE,
      cohortSurvival = FALSE
    ),
    populationDiagnostics = NULL
  ))

  cohort_post <- cdm$my_cohort |>
    dplyr::collect()
  logs_post <- list.files(staging_path, pattern = ".txt")
  results_post <- list.files(staging_path, pattern = ".csv")
  original_log_summary_post <- omopgenerics::summariseLogFile(logFile = file.path(original_log_path, "log.txt"))

  expect_identical(cohort_pre, cohort_post)
  expect_true(length(logs_post) > length(logs_pre))
  # we have incremental
  expect_true(length(results_post) > length(results_pre))
  expect_true("incremental_codelistDiagnostics_001.csv" %in% results_post)
  expect_true("incremental_cohortDiagnostics_001.csv" %in% results_post)
  expect_true("incremental_databaseDiagnostics_001.csv" %in% results_post)
  expect_true("incremental_populationDiagnostics_001.csv" %in% results_post)
  # we have updated the original log
  expect_true(nrow(original_log_summary_post) >
                nrow(original_log_summary_pre))

  log_types <- settings(my_result) |>
    dplyr::pull("result_type")
  expect_true("summarise_log_file" %in% log_types)

  expect_no_error(multiple_database_results <- phenotypeDiagnostics(
    cdm$my_cohort,
    databaseDiagnostics = list(
      list(cohortId = 1, snapshot = TRUE, personTableSummary = FALSE,
           observationPeriodsSummary = FALSE, clinicalRecordsSummary = FALSE),
      list(cohortId = 2, snapshot = FALSE, personTableSummary = FALSE,
           observationPeriodsSummary = TRUE, clinicalRecordsSummary = FALSE)
    ),
    codelistDiagnostics = NULL,
    cohortDiagnostics = NULL,
    populationDiagnostics = NULL,
    stagingDirectory = staging_path
  ))
  expect_true(all(
    c("summarise_omop_snapshot", "summarise_observation_period") %in%
      omopgenerics::settings(multiple_database_results)$result_type
  ))
  expect_true(file.exists(file.path(staging_path, "incremental_databaseDiagnostics_002.csv")))


  expect_no_error(my_result_2 <- phenotypeDiagnostics(cdm$my_cohort,
                                                      databaseDiagnostics = NULL,
                                                      codelistDiagnostics = NULL,
                                                      cohortDiagnostics = list(cohortId = 1),
                                                      populationDiagnostics = list(cohortId = 2)))
  expect_error(my_result_2 <- phenotypeDiagnostics(cdm$my_cohort,
                                                      databaseDiagnostics = NULL,
                                                      codelistDiagnostics = NULL,
                                                      cohortDiagnostics = NULL,
                                                      populationDiagnostics = list(cohortId = 55)))

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
                                            cohortDiagnostics = list("matchedSample" = 1000,
                                                                     "compareCohorts" = TRUE))

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
})
