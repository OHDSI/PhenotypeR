test_that("basic working example with one cohort", {

  skip_on_cran()

  # empty result - should still work without error
  expect_no_error(
    shinyDiagnostics(result = omopgenerics::emptySummarisedResult(),
                     directory = tempdir())
    )

  # with results
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

  my_result_cohort_diag <- cdm$my_cohort |>
    phenotypeDiagnostics(populationDiagnostics = list("populationSample" = 10000))

  expect_no_error(shinyDiagnostics(my_result_cohort_diag,
                                   directory = tempdir()))

  expect_error(shinyDiagnostics(my_result_cohort_diag,
               directory = tempdir(),
               expectationsDir = 0))

  my_results1 <- omopgenerics::newSummarisedResult(my_result_cohort_diag,
                                                   settings = my_result_cohort_diag |>
                                                     omopgenerics::settings() |>
                                                     dplyr::mutate("phenotyper_version" = "0"))

  expect_warning(shinyDiagnostics(my_results1, tempdir(), open = FALSE))
})

test_that("only one diagnostic", {

  skip_on_cran()
  CDMConnector::requireEunomia()
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir())
  cdm <- CDMConnector::cdmFromCon(con = con,
                                  cdmName = "Eunomia Synpuf",
                                  cdmSchema   = "main",
                                  writeSchema = "main")

  cdm$new_cohort <- CohortConstructor::conceptCohort(cdm, conceptSet = list("concept" = 40481087L), name = "new_cohort")

  # examples with single diagnostics ----
  result <- databaseDiagnostics(cdm$new_cohort)
  expect_no_error(shinyDiagnostics(result, directory = tempdir()))

  result <- codelistDiagnostics(cdm$new_cohort)
  expect_warning(shinyDiagnostics(result, directory = tempdir()))

  result <- cohortDiagnostics(cdm$new_cohort, cohortSurvival = FALSE)
  expect_warning(shinyDiagnostics(result, directory = tempdir()))

  result <- populationDiagnostics(cdm$new_cohort, populationSample = 10000)
  expect_no_error(shinyDiagnostics(result, directory = tempdir()))
})

test_that("llm integration", {
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("ellmer")

  chat <- ellmer::chat_ollama(
    model = "MedGemma:4b"
  )

  # Create a code lists
  codes <- list("warfarin" = c(1310149L, 40163554L),
                "morphine" = c(1110410L, 35605858L, 40169988L),
                "asthma" = c(1110410L, 35605858L, 40169988L),
                "ankle_sprain" = c(81151, 40479768L),
                "ankle_fracture" = c(4059173L,81151L, 1310149L)) # erroneous code
  cdm <- omock::mockCdmFromDataset(source = "duckdb")
  cdm$my_cohort <- CohortConstructor::conceptCohort(cdm = cdm,
                                                    conceptSet = codes,
                                                    exit = "event_end_date",
                                                    name = "my_cohort")
  res <- phenotypeDiagnostics(cdm$my_cohort)

  cd <- draftClinicalDescription(chat, name = names(codes))
  code_review <- reviewCohortConcepts(chat = chat,
                                      cohortConcepts = res,
                                      clinicalDescription = cd)
  expectations <- getCohortExpectations(chat = chat,
                                        phenotypes = res,
                                        outputDir = tempdir())


  shinyDiagnostics(result = res,
                   expectations = expectations,
                   clinicalDescriptions = cd,
                   directory = tempdir())



})
