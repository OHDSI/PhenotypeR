test_that("review included concepts", {

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
  res <- codelistDiagnostics(cdm$my_cohort)

  cd <- draftClinicalDescription(chat, name = c("warfarin", "morphine",
                                                "asthma", "ankle_sprain", "ankle_fracture"))

 expect_no_error(code_review <- reviewCohortConcepts(chat = chat,
                       cohortConcepts = res,
                       clinicalDescription = cd))

 expect_error(reviewCohortConcepts(chat = chat,
                      cohortConcepts = omopgenerics::emptySummarisedResult(),
                      clinicalDescription = cd))

 expect_error(reviewCohortConcepts(chat = chat,
                      cohortConcepts = dplyr::tibble(),
                      clinicalDescription = cd))


 # expect_error(reviewCohortConcepts(chat = chat,
 #                                   cohortConcepts = res,
 #                                   clinicalDescription = "xyz"))
})
