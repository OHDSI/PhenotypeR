

codes <- list(
  "user_of_warfarin" = c(1310149L, 40163554L),
  "user_of_acetaminophen" = c(1125315L, 1127078L, 1127433L, 40229134L, 40231925L, 40162522L, 19133768L),
  "user_of_morphine" = c(1110410L, 35605858L, 40169988L),
  "hypertension" = c(320128L),
  "type_2_diabetes" = c(201826L, 40482801L),
  "measurement_of_prostate_specific_antigen_level" = c(2617206L),
  "hospitalised_inpatient" = c(9201L)
)
expectations <- readr::read_csv(here::here("extras", "shiny_expectations.csv"),
                                show_col_types = FALSE)

# run against different omock datasets
datasets <- c("GiBleed", "synpuf-1k_5.3", "synthea-covid19-200k")
result <- list()
for(i in seq_along(datasets)){
working_dataset <- datasets[i]
cdm <- omock::mockCdmFromDataset(datasetName = working_dataset, source = "duckdb")
cdm$my_cohort <- CohortConstructor::conceptCohort(
  cdm = cdm,
  conceptSet = codes,
  exit = "event_end_date",
  overlap = "merge",
  name = "my_cohort"
)
cdm$my_cohort <- cdm$my_cohort |>
  CohortConstructor::requireDuration(daysInCohort = c(2, Inf),
                                     cohortId = "hospitalised_inpatient")
cdm$my_cohort <- cdm$my_cohort |>
  CohortConstructor::exitAtObservationEnd(cohortId = c("hypertension",
                                                       "type_2_diabetes"))
result[[working_dataset]] <- PhenotypeR::phenotypeDiagnostics(cohort = cdm$my_cohort,
                                                              survival = TRUE)
}
result <- omopgenerics::bind(result)


PhenotypeR::shinyDiagnostics(result = result,
                             expectations = expectations,
                             minCellCount = 2, directory = getwd(), open = FALSE)
