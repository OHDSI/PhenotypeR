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

#' Helper for consistent documentation of `measurementDiagnosticsSample`.
#'
#' @param measurementDiagnosticsSample The number of people to take a random sample for
#' measurement diagnostics. If `measurementDiagnosticsSample = NULL`, no sampling will be
#' performed. If `measurementDiagnosticsSample = 0` measurement diagnostics will not be
#' run.
#'
#' @name measurementDiagnosticsSampleDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `drugDiagnosticsSample`.
#'
#' @param drugDiagnosticsSample The number of people to take a random sample for
#' drug diagnostics. If `drugDiagnosticsSample = NULL`, no sampling will be
#' performed. If `drugDiagnosticsSample = 0` drug diagnostics will not be
#' run.
#'
#' @name drugDiagnosticsSampleDoc
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
#' @param populationDateRange A Date vector of length two. The first date sets
#' the earliest possible date and the second sets the latest possible date. Use
#' `NA` for an open endpoint; both endpoints can be `NA` to use the full date
#' range. In PhenotypeR specification files, enter the range as
#' `YYYY-MM-DD to YYYY-MM-DD` (for example, `2015-01-01 to 2020-12-31`).
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
