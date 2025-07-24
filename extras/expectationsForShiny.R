cdm <- omock::mockCdmFromDataset(datasetName = "synpuf-1k_5.3")
con <- duckdb::dbConnect(drv = duckdb::duckdb())
src <- CDMConnector::dbSource(con = con, writeSchema = "main")
cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = src)

# TODO
# after omock next release this will be possible:
# cdm <- omock::mockCdmFromDataset(datasetName = "synpuf-1k_5.3", source = "duckdb")

cdm <- CDMConnector::cdmFromCon(
  con = con,
  cdmName = "Eunomia Synpuf",
  cdmSchema   = "main",
  writeSchema = "main",
  achillesSchema = "main"
)

codes <- list(
  "user_of_warfarin" = c(1310149L, 40163554L),
  "user_of_acetaminophen" = c(1125315L, 1127078L, 1127433L, 40229134L, 40231925L, 40162522L, 19133768L),
  "user_of_morphine" = c(1110410L, 35605858L, 40169988L),
  "measurement_of_prostate_specific_antigen_level" = c(2617206L)
)

cdm$my_cohort <- CohortConstructor::conceptCohort(
  cdm = cdm,
  conceptSet = codes,
  exit = "event_end_date",
  overlap = "merge",
  name = "my_cohort"
)

result <- PhenotypeR::phenotypeDiagnostics(cohort = cdm$my_cohort, survival = TRUE)

chat <- ellmer::chat_google_gemini()
expectations <- PhenotypeR::getCohortExpectations(chat = chat,
                      phenotypes = result)

readr::write_csv(expectations, here::here("extras", "shiny_expectations.csv"))
