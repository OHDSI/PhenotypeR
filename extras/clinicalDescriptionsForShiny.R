
chat <- ellmer::chat_google_gemini(model = "gemini-2.5-pro")
PhenotypeR::getClinicalDescription(chat = chat,
                                   name = c("hypertension",
                                            "type_2_diabetes",
                                            "hospitalised_inpatient",
                                            "user_of_warfarin",
                                            "user_of_acetaminophen",
                                            "user_of_morphine",
                                            "measurement_of_prostate_specific_antigen_level"),
                                   outputDir = here::here("extras", "clinical_descriptions"))
