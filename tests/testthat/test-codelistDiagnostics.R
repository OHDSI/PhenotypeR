test_that("missing codelist attribute", {
  skip_on_cran()

  testthat::skip_on_cran()
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockCohort(name = "my_cohort_1")  |>
    omock::mockCohort(name = "my_cohort_2", numberCohorts = 2)

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)
  attr(cdm, "write_schema") <- "results"

  # Codelist empty
  expect_warning(result <- cdm$my_cohort_1 |>
                   codelistDiagnostics())
  expect_true("summarised_result" %in% class(result))
  expect_identical(result, omopgenerics::emptySummarisedResult())

  # No cohort codelist attribute
  attr(cdm$my_cohort_1, "cohort_codelist") <- NULL
  expect_warning(result <- cdm$my_cohort_1 |>
                   codelistDiagnostics())
  expect_true("summarised_result" %in% class(result))
  expect_identical(result, omopgenerics::emptySummarisedResult())

  # Empty cohorts
  cdm[["my_cohort_2"]] <- cdm[["my_cohort_2"]] |>
    addCodelistAttribute(codelist = list("a" = c(1L,2L)),
                         cohortName = "cohort_1") |>
    addCodelistAttribute(codelist = list("b" = c(1L,2L)),
                         cohortName = "cohort_2")

  cdm$my_cohort_2 <- cdm$my_cohort_2 |>
    CohortConstructor::requireAge(ageRange = c(201,201),
                                  name = "my_cohort_2",
                                  cohortId = c(1))
  expect_no_error(cdm$my_cohort_2 |> codelistDiagnostics())

  CDMConnector::cdmDisconnect(cdm = cdm)
})

test_that("duplicated codelists", {
  skip_on_cran()
  cdm <- omock::mockCdmFromTables(tables = list(
    cohort1 = dplyr::tibble(
      cohort_definition_id = c(1L, 2L),
      subject_id = 1L,
      cohort_start_date = as.Date("2020-01-01"),
      cohort_end_date = as.Date("2020-01-01")
    )
  )) |>
    omock::mockConditionOccurrence() |>
    omopgenerics::insertCdmTo(to = CDMConnector::dbSource(
      con = duckdb::dbConnect(duckdb::duckdb()), writeSchema = "main"
    ))
  cdm$cohort1 <- cdm$cohort1 |>
    omopgenerics::newCohortTable() |>
    addCodelistAttribute(
      codelist = list(a = c(1L, 2L, 3L)),
      cohortName = c("cohort_1")
    ) |>
    addCodelistAttribute(
      codelist = list(a = c(1L, 2L, 3L), b = 3L),
      cohortName = c("cohort_2", "cohort_2")
    )

  expect_no_error(codelistDiagnostics(cdm$cohort1))

  # now b codelist is different
  cdm$cohort1 <- cdm$cohort1 |>
    addCodelistAttribute(
      codelist = list(b = 4L),
      cohortName = c("cohort_1")
    )
  expect_error()
})

test_that("measurementDiagnostics working", {
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockMeasurement() |>
    omock::mockCohort(name = "my_cohort_1")

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)
  attr(cdm, "write_schema") <- "results"

  codes <- list(all_measurements = cdm$measurement |>
    dplyr::pull("measurement_concept_id") |>
    unique()) |>
    omopgenerics::newCodelist()
  cdm$measurement_cohort <- CohortConstructor::conceptCohort(cdm,
                                                             codes,
                                                             "measurement_cohort")
  res <- PhenotypeR::codelistDiagnostics(cdm$measurement_cohort,
                                         measurementSample = NULL)

  expect_equal(
    settings(res)$result_type,
    c("cohort_code_use", "measurement_summary", "measurement_value_as_number", "measurement_value_as_concept")
  )
  expect_equal(res |> omopgenerics::splitGroup() |> dplyr::pull("cohort_name") |> unique(),
               "all_measurements")

  expect_identical(res |>
                     omopgenerics::settings() |>
                     dplyr::pull("diagnostic") |>
                     unique(),
                   "codelistDiagnostics")


 # sampling
  res_sampled <- PhenotypeR::codelistDiagnostics(cdm$measurement_cohort, measurementSample = 5)

  expect_true(res_sampled |>
    omopgenerics::filterSettings(result_type == "measurement_summary") |>
    dplyr::filter(variable_name == "number_subjects", .data$estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.integer() <= 5)

  # no measurement diagnostics
  res_no_meas <- PhenotypeR::codelistDiagnostics(cdm$measurement_cohort,
                                                 measurementSample = 0)
  expect_false("measurement_summary" %in% omopgenerics::settings(res_no_meas))

  multiple_codes <- CodelistGenerator::stratifyByConcept(codes, cdm)
  cdm$measurement_2 <- CohortConstructor::conceptCohort(cdm,
                                                        multiple_codes,
                                                        "measurement_2")

    res <- PhenotypeR::codelistDiagnostics(cdm$measurement_2)
  expect_equal(
    settings(res)$result_type,
    c("cohort_code_use", "measurement_summary", "measurement_value_as_number", "measurement_value_as_concept")
  )
  expect_equal(res |>
                 omopgenerics::splitGroup() |>
                 dplyr::pull("cohort_name") |>
                 unique() |>
                 sort(),
               names(multiple_codes) |> sort())
})

test_that("drugDiagnostics working", {
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockMeasurement() |>
    omock::mockCohort(name = "my_cohort_1")

  con <- DBI::dbConnect(duckdb::duckdb())
  cdm <- omopgenerics::insertCdmTo(
    cdm = cdm_local,
    to = CDMConnector::dbSource(con = con, writeSchema = "main")
  )

  codes <- list(all_drugs = unique(cdm_local$drug_exposure$drug_concept_id)) |>
    omopgenerics::newCodelist()
  cdm$drug_cohort <- CohortConstructor::conceptCohort(cdm, codes, "drug_cohort")

  expect_no_error(res <- PhenotypeR::codelistDiagnostics(cdm$drug_cohort))

  expect_true(all(
    settings(res)$result_type %in% c("cohort_code_use", "summarise_drug_use")
  ))


  expect_identical(
    res |>
      omopgenerics::settings() |>
      dplyr::pull("diagnostic") |>
      unique(),
    "codelistDiagnostics"
  )

  # check ingredient work (dose checks)


  # no drug diagnostics

})
