# Argument descriptions repeated > 1:

#' Helper for consistent documentation of `expectations`.
#'
#' @param expectations Data frame or tibble with cohort expectations. It must contain the following columns: cohort_name, estimate, value, and source.
#'
#' @name expectationsDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `cohort`.
#'
#' @param cohort Cohort table in a cdm reference
#'
#' @name cohortDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `survival`.
#'
#' @param survival TRUE or FALSE. Whether to conduct survival analysis (TRUE)
#' or not (FALSE).
#'
#' @name survivalDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `measurementSample`.
#'
#' @param measurementSample The number of people to take a random sample for
#' measurement diagnostics. If `measurementSample = NULL`, no sampling will be
#' performed. If `measurementSample = 0` measurement diagnostics will not be
#' run.
#'
#' @name measurementSampleDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `drugExposureSample`.
#'
#' @param drugExposureSample The number of people to take a random sample for
#' drug diagnostics. If `drugExposureSample = NULL`, no sampling will be
#' performed. If `drugExposureSample = 0` drug diagnostics will not be
#' run.
#'
#' @name drugExposureSampleDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `cohortSample`.
#'
#' @param cohortSample The number of people to take a random sample for cohortDiagnostics. If `cohortSample = NULL`, no sampling will be performed.
#'
#' @name cohortSampleDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `matched`.
#'
#' @param matchedSample The number of people to take a random sample for
#' matching. If `matchedSample = NULL`, no sampling will be performed. If `matchedSample = 0`, no
#' matched cohorts will be created.
#'
#' @name matchedDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `populationSample`.
#'
#' @param populationSample Number of people from the cdm to sample. If NULL no
#' sampling will be performed. Sample will be within populationDateRange if
#' specified.
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
