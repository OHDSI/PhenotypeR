#' Run cohort-level diagnostics
#'
#' @description
#' Runs phenotypeR diagnostics on the cohort.
#' The diganostics include:
#' * Age groups and sex summarised.
#' * A summary of visits of everyone in the cohort using visit_occurrence table.
#' * A summary of age and sex density of the cohort.
#' * Attritions of the cohorts.
#' * Overlap between cohorts (if more than one cohort is being used).
#'
#' @inheritParams cohortDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#'
#' cdm <- mockPhenotypeR()
#'
#' result <- cohortDiagnostics(cdm$my_cohort)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }

cohortDiagnostics <- function(cohort){

  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  prefix <- omopgenerics::tmpPrefix()
  tempCohortName  <- paste0(prefix, cohortName)
  results <- list()

  cli::cli_bullets(c("*" = "Getting cohort attrition"))
  results[["cohort_attrition"]] <- cdm[[cohortName]] |>
    CohortCharacteristics::summariseCohortAttrition()

  cli::cli_bullets(c("*" = "Getting cohort count"))
  results[["cohort_count"]] <- cdm[[cohortName]] |>
    CohortCharacteristics::summariseCohortCount()

  # if there is more than one cohort, we'll get timing and overlap of all together
  if(length(cohortIds) > 1){
    cli::cli_bullets(c("*" = "Getting cohort overlap"))
    results[["cohort_overlap"]] <-  cdm[[cohortName]] |>
      CohortCharacteristics::summariseCohortOverlap()

    cli::cli_bullets(c("*" = "Getting cohort timing"))
    results[["cohort_timing"]] <- cdm[[cohortName]] |>
      CohortCharacteristics::summariseCohortTiming(estimates = c("median", "q25", "q75", "min", "max", "density"))
  }

  # for other analyses run cohort by cohort
  cli::cli_bullets(c("*" = "get cohorts and index"))
  cdm[[tempCohortName]]  <- cdm[[cohortName]] |>
    PatientProfiles::addDemographics(age = TRUE,
                                     ageGroup = list(c(0, 17), c(18, 64), c(65, 150)),
                                     sex = TRUE,
                                     priorObservation = FALSE,
                                     futureObservation = FALSE,
                                     dateOfBirth = FALSE,
                                     name = tempCohortName)
  cdm[[tempCohortName]] <- CohortConstructor::addCohortTableIndex(cdm[[tempCohortName]])

  cli::cli_bullets(c("*" = "cohort summary"))
  results[["cohort_summary"]] <- cdm[[tempCohortName]] |>
    CohortCharacteristics::summariseCharacteristics(
      strata = list("age_group", "sex"),
      tableIntersectCount = list(
        "Number visits prior year" = list(
          tableName = "visit_occurrence",
          window = c(-365, -1)
        )
      )
    )

  cli::cli_bullets(c("*" = "age density"))
  results[["cohort_density"]] <- cdm[[tempCohortName]] |>
    PatientProfiles::addCohortName() |>
    PatientProfiles::summariseResult(
      counts = FALSE,
      strata    = "sex",
      includeOverallStrata = FALSE,
      group     = "cohort_name",
      includeOverallGroup  = FALSE,
      variables = "age",
      estimates = "density"
    )

  omopgenerics::dropTable(cdm, dplyr::starts_with(prefix))
  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind() |>
    omopgenerics::newSummarisedResult()

  results
}
