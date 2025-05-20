test_that("test add codelist works", {
  testthat::skip_on_cran()
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockCohort(name = "cohort1") |>
    omock::mockCohort(name = "cohort2", numberCohorts = 2)

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)

  cohort <- addCodelistAttribute(cdm$cohort1, codelist = list("a" = 1L, "b" = 2L),
                                   cohortName = rep("cohort_1", 2))
  expect_equal(
    attr(cohort, "cohort_codelist") |> dplyr::collect(),
    dplyr::tibble(
      cohort_definition_id = 1,
      codelist_name = c("a", "b"),
      concept_id = 1:2,
      codelist_type = "index event"
    )
  )

    cohort <- addCodelistAttribute(cdm$cohort2, codelist = list("a" = 1L, "b" = 2L),
                                   cohortName = rep("cohort_1", 2))
    # will get a warning if we overwrite
    expect_warning(cohort <- addCodelistAttribute(cdm$cohort2, codelist = list("a" = 1L, "b" = 2L),
                                   cohortName = rep("cohort_1", 2)))
  expect_equal(
    attr(cohort, "cohort_codelist") |> dplyr::collect(),
    dplyr::tibble(
      cohort_definition_id = 1,
      codelist_name = c("a", "b"),
      concept_id = 1:2,
      codelist_type = "index event"
    )
  )

  expect_warning(
    cohort <- addCodelistAttribute(cdm$cohort2, codelist = list("a" = 1L, "b" = 2L, "c" = 3L, "d" = 4L),
                                   cohortName = c("cohort_1", "cohort_2", "cohort_2", "cohort_3"))
  )
  expect_equal(
    attr(cohort, "cohort_codelist") |> dplyr::collect(),
    dplyr::tibble(
      cohort_definition_id = c(1L, 2L, 2L),
      codelist_name = c("a", "b", "c"),
      concept_id = 1:3,
      codelist_type = "index event"
    )
  )

  # expected errors
  expect_error(
    addCodelistAttribute(cdm$cohort2, codelist = list("a" = 1L),
                         cohortName = c("cohort_4"))
  )
  expect_error(
    addCodelistAttribute(cdm$cohort2, codelist = list("a" = 1L, "b" = 1L),
                         cohortName = c("cohort_1"))
  )
})

test_that("test append codelist to existing", {
  testthat::skip_on_cran()
  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockCohort(name = "cohort1", numberCohorts = 2)

  db <- DBI::dbConnect(duckdb::duckdb())
  cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
                                 schema ="main", overwrite = TRUE)

 cohort <- addCodelistAttribute(cdm$cohort1,
                                codelist = list("a" = 1L),
                                cohortName = "cohort_1")
 expect_true(length(omopgenerics::cohortCodelist(cohort, 1)) > 0)
 expect_warning(expect_true(length(omopgenerics::cohortCodelist(cohort, 2)) == 0))
 expect_true(omopgenerics::cohortCodelist(cohort, 1) == 1)

 # adding a codelist to b should not overwrite the one for one
 cohort <- addCodelistAttribute(cdm$cohort1,
                                codelist = list("b" = 2L),
                                cohortName = "cohort_2")
 expect_true(length(omopgenerics::cohortCodelist(cohort, 1)) > 0)
 expect_true(length(omopgenerics::cohortCodelist(cohort, 2)) > 0)
 expect_true(omopgenerics::cohortCodelist(cohort, 1) == 1)
 expect_true(omopgenerics::cohortCodelist(cohort, 2) == 2)

 # should overwrite the existing one for cohort 1
 cohort <- addCodelistAttribute(cdm$cohort1,
                                codelist = list("c" = 3L),
                                cohortName = "cohort_1")
 expect_true(omopgenerics::cohortCodelist(cohort, 1) == 3)
 expect_true(omopgenerics::cohortCodelist(cohort, 2) == 2)

 # should overwrite the existing both cohort 1 and 2
 cohort <- addCodelistAttribute(cdm$cohort1,
                                codelist = list("d" = 4L,
                                                "e" = 5L),
                                cohortName = c("cohort_1", "cohort_2"))
 expect_true(omopgenerics::cohortCodelist(cohort, 1) == 4)
 expect_true(omopgenerics::cohortCodelist(cohort, 2) == 5)

})

test_that("test eunomia", {
  testthat::skip_on_cran()
  skip_if_not_installed("CirceR")
  skip_if_not(CDMConnector::eunomiaIsAvailable())

  con <- DBI::dbConnect(duckdb::duckdb(CDMConnector::eunomiaDir()))
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmName = "eunomia",
    cdmSchema = "main", writeSchema = "main"
  )

  cohortSet <- CDMConnector::readCohortSet(
    system.file(package = "PhenotypeR", "example_cohorts"))
  cohortCodes <- CodelistGenerator::codesFromCohort(
    system.file(package = "PhenotypeR", "example_cohorts"), cdm = cdm
  )

  cdm <- CDMConnector::generateCohortSet(cdm = cdm, cohortSet = cohortSet,
                                         name = "gibleed")
  cdm$gibleed <- addCodelistAttribute(cohort = cdm$gibleed,
                                      codelist = list("gibleed_default" = 1L,
                                                      "gibleed_male" = 2L))



  expect_true(omopgenerics::cohortCodelist(cdm$gibleed,
                                           omopgenerics::settings(cdm$gibleed) |>
                                             dplyr::filter(cohort_name == "gibleed_default") |>
                                             dplyr::pull("cohort_definition_id"))[[1]] == 1)
  expect_true(omopgenerics::cohortCodelist(cdm$gibleed,
                                           omopgenerics::settings(cdm$gibleed) |>
                                             dplyr::filter(cohort_name == "gibleed_male") |>
                                             dplyr::pull("cohort_definition_id"))[[1]] == 2)

  CDMConnector::cdmDisconnect(cdm)

})
