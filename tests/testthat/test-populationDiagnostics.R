test_that("population incidence and prevalence", {
  testthat::skip_on_cran()

  cdm <- IncidencePrevalence::mockIncidencePrevalence(sampleSize = 1000)
  cdm <- IncidencePrevalence::generateDenominatorCohortSet(cdm, name = "denom")
  expect_no_error(pop_diag_sample <- populationDiagnostics(cohort = cdm$outcome,
                                    populationSample = 250))
  expect_no_error(pop_diag_no_sample <- populationDiagnostics(cohort = cdm$outcome,
                                    populationSample = NULL))

  CDMConnector::cdmDisconnect(cdm)

  })
