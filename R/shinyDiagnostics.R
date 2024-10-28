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
#'   shinyDiagnostics(my_result_cohort_diag)
#' }
shinyDiagnostics <- function(result,
                             directory = here::here()){

  rlang::check_installed("OmopViewer")

  result |>
    OmopViewer::exportStaticApp(
      directory = directory,
      # background = getBackground(result),
      summary = TRUE,
      panels = list(
                   "Database details" = c("Snapshot"= "summarise_omop_snapshot",
                                          "Observation periods"= "summarise_observation_period"),
                   "Codelist diagnostics" = c(
                     "Achilles code use" = "achilles_code_use",
                     "Cohort code use" = "cohort_code_use",
                     "Orphan code use" = "orphan_code_use"),
                   "Cohort diagnostics" = c(
                     "Cohort characteristics" = "summarise_characteristics",
                     "Cohort attrition" = "summarise_cohort_attrition",
                     "Cohort overlap" = "summarise_cohort_overlap",
                     "Cohort timing" = "summarise_cohort_timing"),
                   "Matched diagnostics" = c(
                     "Large scale characteristics" = "summarise_large_scale_characteristics"),
                   "Population diagnostics" = c(
                     "Incidence" = "incidence",
                     "Incidence attrition" = "incidence_attrition",
                     "Prevalence" = "prevalence",
                     "Prevalence attrition" = "prevalence_attrition")
                   )
    )

 # replace md background file
 file.copy(from = system.file("extdata",
                                  "background.md",
                                  package = "PhenotypeR"),
               to = file.path(directory, "shiny",
                              "background.md"),
               overwrite = TRUE)

}

getBackground <- function(result) {

  cohorts <- result |>
    visOmopResults::filterSettings(.data$table_name == "my_cohort") |>
    dplyr::distinct(.data$group_name, .data$group_level) |>
    visOmopResults::splitGroup()

  if ("cohort_name" %in% colnames(cohorts)) {
    cohorts <- c(
      "title" = "**Cohorts**",
      "body" = "The diagnostic results cover the following cohorts: {paste0(unique(cohorts$cohort_name), collapse = ', ')}" |> glue::glue()
    )
  } else {
    cohorts <- character()
  }

  codelists <- result |>
    visOmopResults::filterSettings(.data$result_type == "cohort_code_use") |>
    dplyr::distinct(.data$group_name, .data$group_level) |>
    visOmopResults::splitGroup()

  if ("codelist_name" %in% colnames(codelists)) {
    codelists <- c(
      "title" = "**Codelists**",
      "body" = "Diagnostics have been generated for these codelists: {paste0(unique(codelists$codelist_name), collapse = ', ')}" |> glue::glue()
    )
  } else {
    codelists <- character()
  }

  databases <- result |>
    dplyr::filter(!is.na(.data$cdm_name)) |>
    dplyr::pull("cdm_name") |>
    unique()

  if (length(databases) > 0) {
    databases <- c(
      "title" = "**Databases**",
      "body" = "The results are based on data from the following databases: {paste0(databases, collapse = ', ')}" |> glue::glue()
    )
  } else {
    databases <- character()
  }

  resTypes <- settings(result) |>
    dplyr::filter(!is.na(.data$result_type)) |>
    dplyr::pull("result_type") |>
    unique()

  if (length(resTypes) > 0) {
    resTypes <- c(
      "title" = "**Results**",
      "body" = "The following results are available: {paste0(resTypes, collapse = ', ')}" |> glue::glue()
    )
  } else {
    resTypes <- character()
  }

  c(
    "header" = "PhenotypeR Diagnostics",
    cohorts,
    codelists,
    databases,
    resTypes,
    "footer" = "This Shiny App presents results generated using the [PhenotypeR](https://ohdsi.github.io/PhenotypeR/) package (version {as.character(utils::packageVersion('PhenotypeR'))})." |> glue::glue()
  )
}
