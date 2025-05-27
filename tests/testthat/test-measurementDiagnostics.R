test_that("measurementDiagnostics works", {
  skip_on_cran()
  # without cohort
  cdm <- mockPhenotypeR()
  res <- measurementDiagnostics(cdm = cdm, codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L), timing = "any")
  expect_equal(
    omopgenerics::settings(res),
    dplyr::tibble(
      result_id = 1:4L,
      result_type = c("measurement_code_count", "measurements_taken", "measurement_value_as_numeric", "measurement_value_as_concept"),
      package_name = "PhenotypeR",
      package_version = as.character(utils::packageVersion("PhenotypeR")),
      group = "codelist_name &&& concept_name",
      strata = c("", rep("sex &&& age_group", 3)),
      additional = c("concept_id", "concept_id", "concept_id &&& unit_as_concept_id", "concept_id &&& value_as_concept_id"),
      min_cell_count = "0",
      timing = "any"
    )
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_code_count") |>
      dplyr::pull("estimate_value"),
    c("100", "67", "0", "0")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    as.character(c(100, 67, 0, 21, 89, 294, 1207))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(variable_name),
    c("number records", "number subjects", rep("time", 5))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name),
    c("count", "count", "min", "q25", "median", "q75", "max")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, "100", "100", "100", "100")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name),
    c("min", "q25", "median", "q75", "max", "count_missing", "percentage_missing", "count", "percentage")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c("100", "100")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name),
    c("count", "percentage")
  )

  # with cohort
  res <- measurementDiagnostics(cdm = cdm, codes = list("test" = 3001467L), cohort = cdm$my_cohort, timing = "any")
  expect_equal(
    omopgenerics::settings(res),
    dplyr::tibble(
      result_id = 1:4L,
      result_type = c("measurement_code_count", "measurements_taken", "measurement_value_as_numeric", "measurement_value_as_concept"),
      package_name = "PhenotypeR",
      package_version = as.character(utils::packageVersion("PhenotypeR")),
      group = "codelist_name &&& concept_name",
      strata = c("", rep("sex &&& age_group", 3)),
      additional = c("concept_id", "concept_id", "concept_id &&& unit_as_concept_id", "concept_id &&& value_as_concept_id"),
      min_cell_count = "0",
      cohort = "my_cohort",
      timing = "any"
    )
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    as.character(c("72", "53", "0", "22", "85", "282", "1072"))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(variable_name),
    c("number records", "number subjects", rep("time", 5))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name),
    c("count", "count", "min", "q25", "median", "q75", "max")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, "72", "100", "72", "100")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name),
    c("min", "q25", "median", "q75", "max", "count_missing", "percentage_missing", "count", "percentage")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c("72", "100")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name),
    c("count", "percentage")
  )
})

test_that("test timings with eunomia", {
  skip_on_cran()
  skip_if(Sys.getenv("EUNOMIA_DATA_FOLDER") == "")
  # without cohort
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir())
  cdm <- CDMConnector::cdmFromCon(con, cdmName = "eunomia", cdmSchema = "main", writeSchema = "main")
  cohort <- CohortConstructor::conceptCohort(cdm = cdm, conceptSet = list("condition" = 40481087L), name = "cohort")
  res_any <- measurementDiagnostics(
    cdm = cdm, codes = list("bmi" = c(4024958L, 36304833L), "egfr" = c(1619025L, 1619026L, 3029829L, 3006322L)),
    cohort = cohort, timing = "any"
  )
  res_during <- measurementDiagnostics(
    cdm = cdm, codes = list("bmi" = c(4024958L, 36304833L), "egfr" = c(1619025L, 1619026L, 3029829L, 3006322L)),
    cohort = cohort, timing = "during"
  )
  res_start <- measurementDiagnostics(
    cdm = cdm, codes = list("bmi" = c(4024958L, 36304833L), "egfr" = c(1619025L, 1619026L, 3029829L, 3006322L)),
    cohort = cohort, timing = "cohort_start_date"
  )
  expect_equal(
    res_any |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c("5498", "12852", "2329", "2656", "39", "38", "1487", "1035", "3493",
      "2442", "7481", "4961.5", "31880", "31573")
  )
  expect_equal(
    res_during |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    as.character(c(29, 61, 28, 60, rep(1602, 10)))
  )
  expect_equal(
    res_start |>
      omopgenerics::filterSettings(result_type == "measurements_taken") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    as.character(c(1, 1, rep(NA, 5)))
  )
  expect_equal(
    res_any |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c(rep(NA_character_, 5), "12852", "100", rep(NA_character_, 5), "5498", "100", "5498", "12852", "100", "100")
  )
  expect_equal(
    res_during |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c(rep(NA_character_, 5), "61", "100", rep(NA_character_, 5), "29", "100", "61", "29", "100", "100")
  )
  expect_equal(
    res_start |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c(rep(NA_character_, 5), "1", "100", "1", "100")
  )
  expect_equal(
    res_any |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c("12852", "5498", "100", "100")
  )
  expect_equal(
    res_during |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c("61", "29", "100", "100")
  )
  expect_equal(
    res_start |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value),
    c("1", "100")
  )
})
