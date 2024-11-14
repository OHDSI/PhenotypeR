#' Create a shiny app summarising your phenotyping results
#'
#' @description
#' A shiny app that is designed for any diagnostics results from phenotypeR, this
#' includes:
#'
#' * A diagnostics on the database via `databaseDiagnostics`.
#' * A diagnostics on the cohort_codelist attribute of the cohort via `codelistDiagnostics`.
#' * A diagnostics on the cohort via `cohortDiagnostics`.
#' * A diagnostics on the population via `populationDiagnostics`.
#' * A diagnostics on the matched cohort via `matchedDiagnostics`.
#'
#'
#' @inheritParams resultDoc
#' @inheritParams directoryDoc
#' @param open If TRUE, the shiny app will be launched in a new session. If
#' FALSE, the shiny app will be created but not launched.
#'
#' @return A shiny app
#' @export
#'
#' @examples
#' \donttest{
#'   cdm_local <- omock::mockCdmReference() |>
#'     omock::mockPerson(nPerson = 100) |>
#'     omock::mockObservationPeriod() |>
#'     omock::mockConditionOccurrence() |>
#'     omock::mockDrugExposure() |>
#'     omock::mockObservation() |>
#'     omock::mockMeasurement() |>
#'     omock::mockCohort(name = "my_cohort")
#'   cdm_local$visit_occurrence <- dplyr::tibble(
#'     person_id = 1L,
#'     visit_occurrence_id = 1L,
#'     visit_concept_id = 1L,
#'     visit_start_date = as.Date("2000-01-01"),
#'     visit_end_date = as.Date("2000-01-01"),
#'     visit_type_concept_id = 1L)
#'   cdm_local$procedure_occurrence <- dplyr::tibble(
#'     person_id = 1L,
#'     procedure_occurrence_id = 1L,
#'     procedure_concept_id = 1L,
#'     procedure_date = as.Date("2000-01-01"),
#'     procedure_type_concept_id = 1L)
#'
#'   db <- DBI::dbConnect(duckdb::duckdb())
#'   cdm <- CDMConnector::copyCdmTo(con = db,
#'                                  cdm = cdm_local,
#'                                  schema ="main",
#'                                  overwrite = TRUE)
#'   my_result_cohort_diag <- cdm$my_cohort |> phenotypeDiagnostics()
#'   shinyDiagnostics(my_result_cohort_diag, here::here())
#' }
shinyDiagnostics <- function(result,
                             directory,
                             open = rlang::is_interactive()){

  file.copy(from = system.file("shiny",
                               package = "PhenotypeR"),
            to = directory,
            recursive = TRUE,
            overwrite = TRUE)

  omopgenerics::exportSummarisedResult(result,
                                       fileName = "result.csv",
                                       path = file.path(directory, "shiny", "data", "raw"))
  # shiny::shinyAppDir(file.path(directory, "shiny"))
  if (isTRUE(open)) {
  usethis::proj_activate(directory)
  }

  return(invisible())

}
