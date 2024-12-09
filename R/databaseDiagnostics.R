#' Database diagnostics
#'
#' @description
#' phenotypeR diagnostics on the cdm object.
#'
#' Diagnostics include:
#' * Summarise a cdm_reference object, creating a snapshot with the metadata of the cdm_reference object.
#' * Summarise the observation period table getting some overall statistics in a summarised_result object.
#'
#' @param cdm CDM reference
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
#'
#' cdm_local <- mockCdmReference() |>
#'   mockPerson(nPerson = 100) |>
#'   mockObservationPeriod() |>
#'   mockConditionOccurrence() |>
#'   mockDrugExposure() |>
#'   mockObservation() |>
#'   mockMeasurement() |>
#'   mockCohort(name = "my_cohort", numberCohorts = 2)
#'
#' con <- DBI::dbConnect(duckdb::duckdb(), ":memory:")
#' cdm <- CDMConnector::copy_cdm_to(con = con,
#'                                  cdm = cdm_local,
#'                                  schema = "main")
#' attr(cdm, "write_schema") <- "main"
#'
#' db_diag <- databaseDiagnostics(cdm)
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
databaseDiagnostics <- function(cdm){

results <- list()
results[["snap"]] <- OmopSketch::summariseOmopSnapshot(cdm)
results[["obs_period"]] <- OmopSketch::summariseObservationPeriod(cdm$observation_period)
results <- results |>
  vctrs::list_drop_empty() |>
  omopgenerics::bind() |>
  omopgenerics::newSummarisedResult()

results

}
