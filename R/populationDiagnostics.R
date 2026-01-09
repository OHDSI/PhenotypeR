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
#' library(CohortConstructor)
#' library(PhenotypeR)
#'
#' cdm <- mockCdmFromDataset(source = "duckdb")
#' cdm$warfarin <- conceptCohort(cdm,
#'                               conceptSet =  list(warfarin = c(1310149L,
#'                                                               40163554L)),
#'                               name = "warfarin")
#'
#' result <- cdm$warfarin |>
#'   populationDiagnostics()
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
populationDiagnostics <- function(cohort,
                                  populationSample = 1000000,
                                  populationDateRange = as.Date(c(NA, NA))) {

  if (!is.null(getOption("omopgenerics.logFile"))) {
    omopgenerics::logMessage("Starting Population Diagnostics")
  }
  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  checksPopulationDiagnostics(populationSample, populationDateRange)

  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)

  if (!is.null(getOption("omopgenerics.logFile"))) {
    omopgenerics::logMessage("Creating denominator for incidence and prevalence")
  }
  denominatorTable <- omopgenerics::uniqueTableName()

  # add population sampling
  if(!is.null(populationSample)){
    if (!is.null(getOption("omopgenerics.logFile"))) {
      omopgenerics::logMessage(paste("Sampling person table to", populationSample))
    }
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

  if (!is.null(getOption("omopgenerics.logFile"))) {
    omopgenerics::logMessage("Estimating incidence")
  }
  results[["incidence"]] <- IncidencePrevalence::estimateIncidence(
    cdm = cdm,
    denominatorTable = denominatorTable,
    outcomeTable = cohortName,
    interval = c("years", "overall"),
    repeatedEvents = FALSE,
    outcomeWashout = Inf,
    completeDatabaseIntervals = FALSE)

  if (!is.null(getOption("omopgenerics.logFile"))) {
    omopgenerics::logMessage("Estimating prevalence")
  }
  results[["prevalence"]] <- IncidencePrevalence::estimatePeriodPrevalence(
    cdm = cdm,
    denominatorTable = denominatorTable,
    outcomeTable = cohortName,
    interval = c("years", "overall"),
    completeDatabaseIntervals = TRUE,
    fullContribution = FALSE)

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind()

  newSettings <- results |>
    omopgenerics::settings() |>
    dplyr::mutate("phenotyper_version" = as.character(utils::packageVersion(pkg = "PhenotypeR")),
                  "diagnostic" = "populationDiagnostics",
                  "populationDateStart" = populationDateRange[1],
                  "populationDateEnd"   = populationDateRange[2],
                  "populationSample"    = populationSample)

  results <- results |>
    omopgenerics::newSummarisedResult(settings = newSettings)

  return(results)
}

checksPopulationDiagnostics <- function(populationSample, populationDateRange, call = parent.frame()){
  omopgenerics::assertNumeric(populationSample, integerish = TRUE, min = 1, null = TRUE, length = 1, call = call)
  omopgenerics::assertDate(populationDateRange, na = TRUE, length = 2, call = call)
}

