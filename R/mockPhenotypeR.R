#' Function to create a mock cdm reference for mockPhenotypeR
#'
#' @description
#' `mockPhenotypeR()` creates an example dataset that can be used to show how
#' the package works
#'
#' @param nPerson number of people in the cdm.
#' @param con  A DBI connection to create the cdm mock object.
#' @param writeSchema Name of an schema on the same connection with writing
#' permissions.
#' @param seed seed to use when creating the mock data.
#'
#' @return cdm object
#' @export
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#'
#' cdm <- mockPhenotypeR()
#'
#' cdm
#' }
mockPhenotypeR <- function(nPerson = 100,
                           con = DBI::dbConnect(duckdb::duckdb()),
                           writeSchema = "main",
                           seed = 111){

  omopgenerics::assertNumeric(nPerson, length = 1, na = FALSE, null = FALSE)
  omopgenerics::assertNumeric(seed, length = 1, na = FALSE, null = FALSE)
  omopgenerics::assertCharacter(writeSchema, length = 1, na = FALSE, null = FALSE)

  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = nPerson, seed = seed) |>
    omock::mockObservationPeriod(seed = seed) |>
    omock::mockConditionOccurrence(seed = seed) |>
    omock::mockVisitOccurrence(seed = seed) |>
    omock::mockDrugExposure(seed = seed) |>
    omock::mockObservation(seed = seed) |>
    omock::mockMeasurement(seed = seed) |>
    omock::mockProcedureOccurrence(seed = seed) |>
    omock::mockDeath(seed = seed) |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2, seed = seed)

  cdm <- CDMConnector::copyCdmTo(con = con,
                                 cdm = cdm_local,
                                 schema = writeSchema,
                                 overwrite = TRUE)

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "device_exposure",
                            dplyr::tibble(
                              "device_exposure_id" = NA_integer_,
                              "person_id" = NA_integer_,
                              "device_concept_id" = NA_integer_,
                              "device_exposure_start_date" = as.Date(NA),
                              "device_type_concept_id" = NA_integer_,
                              "device_source_concept_id"	= NA_integer_
                            ))

  cdm <- CodelistGenerator:::buildAchillesTables(cdm) |>
    suppressMessages()

  attr(cdm, "write_schema") <- writeSchema

  return(cdm)
}




