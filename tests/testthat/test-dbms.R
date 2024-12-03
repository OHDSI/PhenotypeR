
test_that("eunomia", {
  skip_on_cran()
  skip_on_ci()
  con <- DBI::dbConnect(duckdb::duckdb(dbdir = CDMConnector::eunomia_dir()))
  cdm <- CDMConnector::cdm_from_con(con = con,
                                    cdm_schema = "main",
                                    write_schema = "main")
  meds_cs <- CodelistGenerator::getDrugIngredientCodes(
    cdm = cdm,
    name = c(
      "acetaminophen",
      "morphine",
      "warfarin"
    )
  )
  cdm$meds <- CohortConstructor::conceptCohort(cdm = cdm,
                               conceptSet = meds_cs,
                               name = "meds")
  results <- phenotypeDiagnostics(cdm$meds)
  expect_no_error(shinyDiagnostics(result = results, directory = tempdir()))
})

test_that("postgres test", {
  skip_on_cran()
  skip_if(Sys.getenv("CDM5_POSTGRESQL_DBNAME") == "")

  db <- DBI::dbConnect(RPostgres::Postgres(),
                       dbname = Sys.getenv("CDM5_POSTGRESQL_DBNAME"),
                       host = Sys.getenv("CDM5_POSTGRESQL_HOST"),
                       user = Sys.getenv("CDM5_POSTGRESQL_USER"),
                       password = Sys.getenv("CDM5_POSTGRESQL_PASSWORD"))
  cdm <- CDMConnector::cdmFromCon(
    con = db,
    cdmSchema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"),
    writeSchema = c(schema =  Sys.getenv("CDM5_POSTGRESQL_SCRATCH_SCHEMA")),
    writePrefix = prefix = "phen_"
    achillesSchema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA")
  )

  cdm$asthma <- CohortConstructor::conceptCohort(cdm = cdm,
                                                  conceptSet = list("asthma" = 317009),
                                                  name = "asthma")
  drug_codes <- CodelistGenerator::getDrugIngredientCodes(cdm,
                                       name = c("diclofenac", "metformin"))
  cdm$drugs <- CohortConstructor::conceptCohort(cdm = cdm,
                                                conceptSet = drug_codes,
                                                name = "drugs")
  cdm <- omopgenerics::bind(cdm$asthma, cdm$drugs, name = "my_cohort")

  results <- phenotypeDiagnostics(cdm$my_cohort)
  expect_no_error(shinyDiagnostics(result = results, directory = tempdir()))
  expect_no_error(CodelistGenerator::tableCohortCodeUse(results))
  expect_no_error(CodelistGenerator::tableAchillesCodeUse(results))
  expect_no_error(CodelistGenerator::tableOrphanCodes(results))

  expect_no_error(CohortCharacteristics::tableCharacteristics(results))
  expect_no_error(CohortCharacteristics::tableCohortAttrition(results))
  expect_no_error(CohortCharacteristics::tableCohortOverlap(results))
  expect_no_error(CohortCharacteristics::tableCohortTiming(results))
  expect_no_error(CohortCharacteristics::tableLargeScaleCharacteristics(results))
  # omopViewer::exportStaticApp(results)
  expect_no_error(shinyDiagnostics(result = results, directory = tempdir()))

  CDMConnector::cdm_disconnect(cdm = cdm)

})
