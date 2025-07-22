
devtools::load_all()

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
  "warfarin" = c(1310149L, 40163554L),
  "acetaminophen" = c(1125315L, 1127078L, 1127433L, 40229134L, 40231925L, 40162522L, 19133768L),
  "morphine" = c(1110410L, 35605858L, 40169988L),
  "measurements_cohort" = c(40660437L, 2617206L, 4034850L,  2617239L, 4098179L)
)

cdm$my_cohort <- CohortConstructor::conceptCohort(
  cdm = cdm,
  conceptSet = codes,
  exit = "event_end_date",
  overlap = "merge",
  name = "my_cohort"
)

result <- PhenotypeR::phenotypeDiagnostics(cohort = cdm$my_cohort, survival = TRUE)

PhenotypeR::shinyDiagnostics(result = result, minCellCount = 2, directory = getwd(), open = FALSE)
