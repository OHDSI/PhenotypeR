chat <- ellmer::chat("google_gemini")
llm_expectation <- chat$chat(
  ellmer::interpolate("What are the typical characteristics we can expect to see in our real-world data for a cohort of people with an ankle sprain (average age, proportion male vs female, subsequent medications, etc)? Be brief and provide summar with a few sentences."))

readr::write_csv(x = dplyr::tibble(cohort_name = "diagnosis_of_ankle_sprain",
                               estimate = "General summary",
                               value = llm_expectation,
                               source = "llm"),
                 file = here::here("vignettes", "vignette_phenotype_expectations", "expectations_1.csv"))


readr::write_csv(x = getCohortExpectations(chat = chat,
                      phenotypes = c("diagnosis_of_ankle_sprain",
                                     "diagnosis_of_prostate_cancer",
                                     "new_user_of_morphine")),
                 file = here::here("vignettes", "vignette_phenotype_expectations", "expectations_2.csv"))

chat <- ellmer::chat("mistral")
readr::write_csv(x = getCohortExpectations(chat = chat,
                                           phenotypes = c("diagnosis_of_ankle_sprain",
                                                          "diagnosis_of_prostate_cancer",
                                                          "new_user_of_morphine")),
                 file = here::here("vignettes", "vignette_phenotype_expectations", "expectations_3.csv"))

