#' Population-level diagnostics
#'
#' @description
#' phenotypeR diagnostics on the cohort of input with relation to a denomination
#' population. Diagnostics include:
#'
#' * Incidence
#' * Prevalence
#'
#' @inheritParams cohortDoc
#' @inheritParams populationSampleDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(omock)
#' library(CDMConnector)
#' library(DBI)
#' library(PhenotypeR)
#' library(dplyr)
#'
#' cdm_local <- mockCdmReference() |>
#'   mockPerson(nPerson = 1000) |>
#'   mockObservationPeriod() |>
#'   mockConditionOccurrence() |>
#'   mockDrugExposure() |>
#'   mockObservation() |>
#'   mockMeasurement() |>
#'   mockVisitOccurrence() |>
#'   mockCohort(name = "my_cohort")
#'
#' con <- DBI::dbConnect(duckdb::duckdb(), ":memory:")
#' cdm <- CDMConnector::copy_cdm_to(con = con,
#'                                  cdm = cdm_local,
#'                                  schema = "main")
#' attr(cdm, "write_schema") <- "main"
#'
#' dateStart <- cdm$my_cohort |>
#'   summarise(start = min(cohort_start_date, na.rm = TRUE)) |>
#'   pull("start")
#' dateEnd   <- cdm$my_cohort |>
#'   summarise(start = max(cohort_start_date, na.rm = TRUE)) |>
#'   pull("start")
#'
#' result <- cdm$my_cohort |>
#'   populationDiagnostics(populationDateRange = c(dateStart, dateEnd))
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
populationDiagnostics <- function(cohort,
                                  populationSample = 1000000,
                                  populationDateRange = as.Date(c(NA, NA))) {

  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)

  cli::cli_bullets(c("*" = "{.strong Creating denominator for incidence and prevalence}"))
  denominatorTable <- omopgenerics::uniqueTableName()

  # add population sampling
  if(!is.null(populationSample)){
    cli::cli_bullets(c("*" = "{.strong Sampling person table to {populationSample}}"))
  cdm$person <- cdm$person |>
    dplyr::slice_sample(n = populationSample)
  }

  cdm <- IncidencePrevalence::generateDenominatorCohortSet(
    cdm = cdm,
    name = denominatorTable,
    ageGroup = list(c(0, 150),
                    c(0, 17),
                    c(18, 64),
                    c(65, 150)),
    sex = c("Both", "Male", "Female"),
    daysPriorObservation = 0,
    requirementInteractions = FALSE,
    cohortDateRange = populationDateRange
  )

  results <- list()

  cli::cli_bullets(c("*" = "{.strong Estimating incidence}"))
  results[["incidence"]] <- IncidencePrevalence::estimateIncidence(
    cdm = cdm,
    denominatorTable = denominatorTable,
    outcomeTable = cohortName,
    interval = c("years", "overall"),
    repeatedEvents = FALSE,
    outcomeWashout = Inf,
    completeDatabaseIntervals = FALSE)

  cli::cli_bullets(c("*" = "{.strong Estimating prevalence}"))
  results[["prevalence"]] <- IncidencePrevalence::estimatePeriodPrevalence(
    cdm = cdm,
    denominatorTable = denominatorTable,
    outcomeTable = cohortName,
    interval = "years",
    completeDatabaseIntervals = TRUE,
    fullContribution = FALSE)

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind() |>
    omopgenerics::newSummarisedResult()

  results

}
