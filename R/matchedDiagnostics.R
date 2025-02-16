#' Compare characteristics of cohort matched to database population
#'
#' @description
#' A summary of the cohort that is matched to the original cohort that has been
#' given by the user. Such summary contains basic cohort summary including
#' number of visits within one year prior of the cohort_start_date, as well as
#' a large scale charactersitics using the following domians of OMOP CDM:
#'
#' * condition_occurrence
#' * visit_occurrence
#' * measurement
#' * procedure_occurrence
#' * observation
#' * drug_exposure
#'
#' @inheritParams cohortDoc
#' @inheritParams matchedSampleDoc
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
#' result <- matchedDiagnostics(cdm$my_cohort)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
matchedDiagnostics <- function(cohort,
                               matchedSample = 1000){

  omopgenerics::assertNumeric(matchedSample, min = 1, null = TRUE)

  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  prefix <- omopgenerics::tmpPrefix()
  tempCohortTable  <- paste0(prefix, cohortName)
  results <- list()

  for(i in seq_along(cohortIds)){
    workingCohortId <- cohortIds[i]
    workingCohortName <- omopgenerics::getCohortName(cdm[[cohortName]],
                                                   cohortId = workingCohortId)

  cdm[[tempCohortTable]] <- CohortConstructor::subsetCohorts(
      cdm[[cohortName]],
      cohortId = workingCohortId,
      name = tempCohortTable)
  if(!is.null(matchedSample)){
  cli::cli_bullets(c("*" = "{.strong Sampling cohorts}"))
  cdm[[tempCohortTable]] <- CohortConstructor::sampleCohorts(cdm[[tempCohortTable]],
                                   cohortId = workingCohortId,
                                   n = matchedSample,
                                   name = tempCohortTable)
  }

  cli::cli_bullets(c("*" = "{.strong Generating an age and sex matched cohort for {workingCohortName}}"))
  cdm[[tempCohortTable]] <- CohortConstructor::matchCohorts(cdm[[tempCohortTable]],
                                     name = tempCohortTable)
  cdm[[tempCohortTable]]  <- cdm[[tempCohortTable]] |>
    PatientProfiles::addDemographics(age = TRUE,
                                     ageGroup = list(c(0, 17),
                                                     c(18, 64),
                                                     c(65, 150)),
                                     sex = TRUE,
                                     priorObservation = FALSE,
                                     futureObservation = FALSE,
                                     dateOfBirth = FALSE,
                                     name = tempCohortTable)
  cdm[[tempCohortTable]] <- CohortConstructor::addCohortTableIndex(cdm[[tempCohortTable]])

  results[[paste0("cohort_summary_", workingCohortName)]] <- cdm[[tempCohortTable]] |>
    CohortCharacteristics::summariseCharacteristics(
      strata = list("age_group", "sex"),
      tableIntersectCount = list(
        "Number visits prior year" = list(
          tableName = "visit_occurrence",
          window = c(-365, -1)
        )
      )
    )

  cli::cli_bullets(c("*" = "Getting age density"))
  results[[paste0("cohort_density_", workingCohortName)]] <- cdm[[tempCohortTable]] |>
    PatientProfiles::addCohortName() |>
    PatientProfiles::summariseResult(
      strata    = "sex",
      includeOverallStrata = FALSE,
      group     = "cohort_name",
      includeOverallGroup  = FALSE,
      variables = "age",
      estimates = "density")

  cli::cli_bullets(c("*" = "{.strong Running large scale characterisation}"))
  results[[paste0("lsc_", workingCohortName)]] <- CohortCharacteristics::summariseLargeScaleCharacteristics(
    cohort = cdm[[tempCohortTable]],
    window = list(c(-Inf, -1), c(-Inf, -366), c(-365, -31),
                  c(-30, -1), c(0, 0),
                  c(1, 30), c(31, 365),
                  c(366, Inf), c(1, Inf)),
    eventInWindow = c("condition_occurrence", "visit_occurrence",
                      "measurement", "procedure_occurrence",
                      "observation"),
    episodeInWindow = c("drug_exposure"),
    minimumFrequency = 0.0005,
    includeSource = TRUE,
    excludedCodes = NULL
  )
  }

  omopgenerics::dropTable(cdm, dplyr::starts_with(prefix))

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind() |>
    omopgenerics::newSummarisedResult()

  results
}
