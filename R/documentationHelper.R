# Argument descriptions repeated > 1:

#' Helper for consistent documentation of `cohort`.
#'
#' @param cohort Cohort table in a cdm reference
#'
#' @name cohortDoc
#' @keywords internal
NULL


#' Helper for consistent documentation of `matchedSample`.
#'
#' @param matchedSample The number of people to take a random sample for
#' matching. If NULL, no sampling will be performed.
#'
#' @name matchedSampleDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `populationSample`.
#'
#' @param populationSample Number of people from the cdm to sample. If NULL no
#' sampling will be performed
#' @param populationDateRange Two dates. The first indicating the earliest cohort
#' start date and the second indicating the latest possible cohort end date. If
#' NULL or the first date is set as missing, the earliest observation_start_date
#' in the observation_period table will be used for the former. If  NULL or the
#' second date is set as missing, the latest observation_end_date in the
#' observation_period table will be used for the latter.
#'
#' @name populationSampleDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `result`.
#'
#' @param result A summarised result
#'
#' @name resultDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `directory`.
#'
#' @param directory Directory where to save report
#'
#' @name directoryDoc
#' @keywords internal
NULL
