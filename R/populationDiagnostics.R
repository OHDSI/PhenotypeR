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
#' library(IncidencePrevalence)
#' cdm <- mockIncidencePrevalenceRef(sampleSize = 1000)
#' pop_diag <- populationDiagnostics(cohort = cdm$outcome,
#'                                   populationSample = 250)
#' CDMConnector::cdm_disconnect(cdm)
#' }
populationDiagnostics <- function(cohort,
                                  populationSample = 1000000) {

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
    requirementInteractions = FALSE
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
    completeDatabaseIntervals = FALSE,
    minCellCount = 0)

  cli::cli_bullets(c("*" = "{.strong Estimating prevalence}"))
  results[["prevalence"]] <- IncidencePrevalence::estimatePeriodPrevalence(
    cdm = cdm,
    denominatorTable = denominatorTable,
    outcomeTable = cohortName,
    interval = "years",
    completeDatabaseIntervals = TRUE,
    fullContribution = FALSE,
    minCellCount = 0)

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind() |>
    omopgenerics::newSummarisedResult()

  attr(results, "settings") <- attr(results, "settings") |>
    dplyr::select(!dplyr::any_of(c("min_cell_count")))

  results

}
