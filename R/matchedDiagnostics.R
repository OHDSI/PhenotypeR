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

  results <- list()
  matchedCohortTable <- paste0(omopgenerics::tableName(cdm[[cohortName]]),
                               "_matched")

  if(!is.null(matchedSample)){
  cli::cli_bullets(c("*" = "{.strong Taking {matchedSample} person sample of cohorts}"))
  cdm[[matchedCohortTable]] <- CohortConstructor::sampleCohorts(cdm[[cohortName]],
                                   n = matchedSample,
                                   name = matchedCohortTable)
  } else {
    cdm[[matchedCohortTable]] <- cdm[[cohortName]] |>
      dplyr::compute(name = matchedCohortTable, temporary = FALSE)
  }

  cli::cli_bullets(c("*" = "{.strong Generating a age and sex matched cohorts}"))
  cdm[[matchedCohortTable]] <- CohortConstructor::matchCohorts(cdm[[matchedCohortTable]],
                                     name = matchedCohortTable)

  cdm[[matchedCohortTable]]  <- cdm[[matchedCohortTable]] |>
    PatientProfiles::addAge(ageGroup = list(c(0, 17), c(18, 64), c(65, 150))) |>
    PatientProfiles::addSex() |>
    dplyr::compute(name = matchedCohortTable, temporary = FALSE)

  results[["cohort_summary"]] <- cdm[[matchedCohortTable]] |>
    CohortCharacteristics::summariseCharacteristics(
      strata = list("age_group", "sex"),
      tableIntersectCount = list(
        "Number visits prior year" = list(
          tableName = "visit_occurrence",
          window = c(-365, -1)
        )
      )
    )

  cli::cli_bullets(c("*" = "{.strong Running large scale characterisation}"))
  results[["lsc"]] <- CohortCharacteristics::summariseLargeScaleCharacteristics(
    cohort = cdm[[matchedCohortTable]],
    window = list(c(-Inf, -1), c(-Inf, -366), c(-365, -31),
                  c(-30, -1), c(0, 0),
                  c(1, 30), c(31, 365),
                  c(366, Inf), c(1, Inf)),
    eventInWindow = c("condition_occurrence", "visit_occurrence",
                      "measurement", "procedure_occurrence",
                      "observation"),
    episodeInWindow = c("drug_exposure"),
    minimumFrequency = 0.0005,
    includeSource = TRUE
  )

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind() |>
    omopgenerics::newSummarisedResult()

  results
}
