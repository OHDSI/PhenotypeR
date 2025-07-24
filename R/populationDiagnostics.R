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
#' library(PhenotypeR)
#' library(dplyr)
#'
#' cdm <- mockPhenotypeR()
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
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
populationDiagnostics <- function(cohort,
                                  populationSample = 1000000,
                                  populationDateRange = as.Date(c(NA, NA))) {

  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  checksPopulationDiagnostics(populationSample, populationDateRange)

  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)

  cli::cli_bullets(c("*" = "{.strong Creating denominator for incidence and prevalence}"))
  denominatorTable <- omopgenerics::uniqueTableName()

  # add population sampling
  if(!is.null(populationSample)){
    cli::cli_bullets(c("*" = "{.strong Sampling person table to {populationSample}}"))
    if(is.na(populationDateRange[[1]]) && is.na(populationDateRange[[2]])){
      cdm$person <- cdm$person |>
        dplyr::slice_sample(n = populationSample)
    } else {
      # sample within date range
      if(!is.na(populationDateRange[[1]]) & is.na(populationDateRange[[2]])){
        cdm$person <- cdm$person |>
          dplyr::inner_join(cdm$observation_period|>
                              dplyr::filter(.data$observation_period_start_date >=
                                              !!populationDateRange[[1]]) |>
                              dplyr::select("person_id") |>
                              dplyr::distinct(),
                            by = "person_id") |>
          dplyr::slice_sample(n = populationSample)
      } else if(is.na(populationDateRange[[1]]) & !is.na(populationDateRange[[2]])){
        cdm$person <- cdm$person |>
          dplyr::inner_join(cdm$observation_period|>
                              dplyr::filter(.data$observation_period_start_date <=
                                              !!populationDateRange[[2]]) |>
                              dplyr::select("person_id") |>
                              dplyr::distinct(),
                            by = "person_id") |>
          dplyr::slice_sample(n = populationSample)
      } else {
        cdm$person <- cdm$person |>
          dplyr::inner_join(cdm$observation_period|>
                              dplyr::filter(.data$observation_period_start_date >=
                                              !!populationDateRange[[1]],
                                            .data$observation_period_start_date <=
                                              !!populationDateRange[[2]]) |>
                              dplyr::select("person_id") |>
                              dplyr::distinct(),
                            by = "person_id") |>
          dplyr::slice_sample(n = populationSample)
      }
    }
cdm$person <- cdm$person |>
  dplyr::compute(temporary = TRUE)
  }

  cdm <- IncidencePrevalence::generateDenominatorCohortSet(
    cdm = cdm,
    name = denominatorTable,
    ageGroup = list(c(0, 150),
                    c(0, 17),
                    c(18, 64),
                    c(65, 150)),
    sex = c("Both", "Male", "Female"),
    daysPriorObservation = c(0, 365),
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
    interval = c("years", "overall"),
    completeDatabaseIntervals = TRUE,
    fullContribution = FALSE)

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind() |>
    omopgenerics::newSummarisedResult()

  results

}

checksPopulationDiagnostics <- function(populationSample, populationDateRange, call = parent.frame()){
  omopgenerics::assertNumeric(populationSample, integerish = TRUE, min = 1, null = TRUE, length = 1, call = call)
  omopgenerics::assertDate(populationDateRange, na = TRUE, length = 2, call = call)
}

