test_that("getting cohort expectations from ellmer", {

  skip_on_cran()
  skip_on_ci()

  chat <- ellmer::chat("google_gemini")

  # specific diagnosis
  expect_no_error(getCohortExpectations(chat, "prostate cancer"))
  expect_no_error(getCohortExpectations(chat, "lung cancer"))
  # can pass multiple
  expect_no_error(getCohortExpectations(chat, c("asthma", "copd")))

  # drugs
  expect_no_error(getCohortExpectations(chat, "metformin"))

  # more examples
  expect_no_error(getCohortExpectations(chat, "knee osteoarthritis"))
  expect_no_error(getCohortExpectations(chat, "knee replacement"))


})

test_that("getting cohort expectations from ellmer - using results object", {

  skip_on_cran()
  skip_on_ci()

  chat <- ellmer::chat_google_gemini()

  # Create a code lists
  codes <- list("warfarin" = c(1310149L, 40163554L),
                "morphine" = c(1110410L, 35605858L, 40169988L),
                "asthma" = c(1110410L, 35605858L, 40169988L),
                "ankle_sprain" = 81151,
                "ankle_fracture" = 4059173)

  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = CDMConnector::eunomiaDir())
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmSchema = "main", writeSchema = "main", cdmName = "Eunomia"
  )

  # Instantiate cohorts with CohortConstructor
  cdm$my_cohort <- CohortConstructor::conceptCohort(cdm = cdm,
                                 conceptSet = codes,
                                 exit = "event_end_date",
                                 overlap = "merge",
                                 name = "my_cohort")

  res <- phenotypeDiagnostics(cdm$my_cohort)

 expect_no_error(expectations <- getCohortExpectations(chat, res))

 expect_no_error(tableCohortExpectations(expectations, type = "reactable"))

 expect_no_error(tableCohortExpectations(expectations, type = "gt"))

 })

test_that("custom table of cohort expectations", {
  skip_on_cran()

  expect_error(tableCohortExpectations("a"))
  expect_error(tableCohortExpectations(dplyr::tibble(name = 1)))

  ex <- data.frame(cohort_name = "my_cohort",
                   estimate = "summary",
                   value = "custom description",
                   source = "someone",
                   extra = "another field")
  expect_no_error(tableCohortExpectations(ex))
  expect_no_error(tableCohortExpectations(ex, type = "gt"))
})
