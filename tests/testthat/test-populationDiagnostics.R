test_that("population incidence and prevalence", {
  testthat::skip_on_cran()

  cdm <- IncidencePrevalence::mockIncidencePrevalence(sampleSize = 1000)
  cdm <- IncidencePrevalence::generateDenominatorCohortSet(cdm, name = "denom")
  expect_no_error(pop_diag_sample <- populationDiagnostics(cohort = cdm$outcome,
                                    populationSample = 250))
  expect_no_error(pop_diag_no_sample <- populationDiagnostics(cohort = cdm$outcome,
                                    populationSample = NULL))
  expect_error(pop_diag_no_sample <- populationDiagnostics(cohort = cdm$outcome,
                                                           populationSample = 1.5))

  expect_error(pop_diag_no_sample <- populationDiagnostics(cohort = cdm$outcome,
                                                           populationSample = -10))

  expect_error(pop_diag_no_sample <- populationDiagnostics(cohort = cdm$outcome,
                                                           populationDateRange = "error"))
  CDMConnector::cdmDisconnect(cdm)

  # population sample within study period
  cdm <- IncidencePrevalence::mockIncidencePrevalence(sampleSize = 1000,
                                                      earliestObservationStartDate = c("2010-01-01"),
                                                      latestObservationStartDate = c("2020-01-01"),
                                                      maxDaysToObservationEnd = 365)
  cdm <- IncidencePrevalence::generateDenominatorCohortSet(cdm, name = "denom")

  # should keep all 100 of sample as sample within date range
  expect_no_error(pop_diag_sample <- populationDiagnostics(cohort = cdm$outcome,
                                                           populationSample = 100,
                                                           populationDateRange =
                                                             c(as.Date("2015-01-01"),
                                                               as.Date("2020-01-01"))))
  expect_true(all(pop_diag_sample |>
    omopgenerics::filterSettings(result_type == "incidence_attrition") |>
    dplyr::filter(strata_level == "Cannot satisfy age criteria during the study period based on year of birth") |>
    dplyr::filter(variable_name == "excluded_subjects") |>
    dplyr::pull("estimate_value") == "0"))

  CDMConnector::cdmDisconnect(cdm)

  })
