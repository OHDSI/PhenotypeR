
chat <- ellmer::chat("google_gemini")
expectations <- PhenotypeR::getCohortExpectations(chat = chat,
                      phenotypes = c("hypertension",
                                     "type_2_diabetes",
                                     "hospitalised_inpatient",
                        "user_of_warfarin",
                        "user_of_acetaminophen",
                        "user_of_morphine",
                        "measurement_of_prostate_specific_antigen_level"))

readr::write_csv(expectations, here::here("extras", "shiny_expectations.csv"))
