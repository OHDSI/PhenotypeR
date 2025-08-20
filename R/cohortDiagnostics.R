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
#' @inheritParams cohortSampleDoc
#' @inheritParams survivalDoc
#' @inheritParams matchedDoc
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

cohortDiagnostics <- function(cohort, survival = FALSE, cohortSample = 20000, matchedSample = 1000){

  cli::cli_bullets(c("*" = "Starting Cohort Diagnostics"))

  # Initial checks ----
  checksCohortDiagnostics(survival, cohortSample, matchedSample)

  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  prefix <- omopgenerics::tmpPrefix()
  tempCohortName  <- paste0(prefix, cohortName)
  results <- list()

  cli::cli_bullets(c(">" = "Getting cohort attrition"))
  results[["cohort_attrition"]] <- cdm[[cohortName]] |>
    CohortCharacteristics::summariseCohortAttrition()

  cli::cli_bullets(c(">" = "Getting cohort count"))
  results[["cohort_count"]] <- cdm[[cohortName]] |>
    CohortCharacteristics::summariseCohortCount()

  cohortNameSampled <- paste0(prefix, "sampled")

  # Check cohort sizes
  x <- cohort |>
    omopgenerics::cohortCount() |>
    dplyr::filter(.data$number_subjects > !!cohortSample) |>
    dplyr::collect()

  if(is.null(cohortSample)){
    cdm[[cohortNameSampled]] <- CohortConstructor::copyCohorts(cdm[[cohortName]], name = cohortNameSampled)
  }else{
    if(nrow(x) == 0){
      cli::cli_bullets(c(">" = "Skipping cohort sampling as all cohorts have less than {cohortSample} individuals."))
      cdm[[cohortNameSampled]] <- CohortConstructor::copyCohorts(cdm[[cohortName]], name = cohortNameSampled)
    }else{
      cli::cli_bullets(c(">" = "Sampling cohorts to up to {cohortSample} individuals"))
      cdm[[cohortNameSampled]] <- CohortConstructor::sampleCohorts(cdm[[cohortName]], n = cohortSample, name = cohortNameSampled)
    }
  }

  # if there is more than one cohort, we'll get timing and overlap of all together
  if(length(cohortIds) > 1){
    cli::cli_bullets(c(">" = "Getting cohort overlap"))
    results[["cohort_overlap"]] <-  cdm[[cohortNameSampled]] |>
      CohortCharacteristics::summariseCohortOverlap()

    cli::cli_bullets(c(">" = "Getting cohort timing"))
    results[["cohort_timing"]] <- cdm[[cohortNameSampled]] |>
      CohortCharacteristics::summariseCohortTiming(estimates = c("median", "q25", "q75", "min", "max", "density"))
  }

  if(is.null(matchedSample) || matchedSample != 0){
    cli::cli_bullets(c(">" = "Creating matching cohorts"))
    cdm <- createMatchedCohorts(cdm, tempCohortName, cohortNameSampled, cohortIds, matchedSample)
    cdm <- bind(cdm[[cohortNameSampled]], cdm[[tempCohortName]], name = tempCohortName)
  }else{
    cdm[[tempCohortName]] <- CohortConstructor::copyCohorts(cdm[[cohortNameSampled]],
                                                            name = tempCohortName)
  }

  cli::cli_bullets(c(">" = "Getting cohorts and indexes"))
  cdm[[tempCohortName]]  <- cdm[[tempCohortName]] |>
    PatientProfiles::addDemographics(age = TRUE,
                                     ageGroup = list(c(0, 17), c(18, 64), c(65, 150)),
                                     sex = TRUE,
                                     priorObservation = FALSE,
                                     futureObservation = FALSE,
                                     dateOfBirth = FALSE,
                                     name = tempCohortName)
  cdm[[tempCohortName]] <- CohortConstructor::addCohortTableIndex(cdm[[tempCohortName]])

  cli::cli_bullets(c(">" = "Summarising cohort characteristics"))
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

  cli::cli_bullets(c(">" = "Calculating age density"))
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

  # Large scale characteristics
  cli::cli_bullets(c(">" = "Run large scale characteristics (including source and standard codes)"))
  results[["lsc_standard_source"]] <- CohortCharacteristics::summariseLargeScaleCharacteristics(
    cohort = cdm[[tempCohortName]],
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

  cli::cli_bullets(c(">" = "Run large scale characteristics (including only standard codes)"))
  results[["lsc_standard"]] <- CohortCharacteristics::summariseLargeScaleCharacteristics(
    cohort = cdm[[tempCohortName]],
    window = list(c(-Inf, -1), c(-Inf, -366), c(-365, -31),
                  c(-30, -1), c(0, 0),
                  c(1, 30), c(31, 365),
                  c(366, Inf), c(1, Inf)),
    eventInWindow = c("condition_occurrence", "visit_occurrence",
                      "measurement", "procedure_occurrence",
                      "observation"),
    episodeInWindow = c("drug_exposure"),
    minimumFrequency = 0.0005,
    includeSource = FALSE,
    excludedCodes = NULL
  )

  if(isTRUE(survival)){
    if("death" %in% names(cdm)){
      cli::cli_bullets(c(">" = "Creating death cohort"))
      if(cdm$death |> dplyr::summarise("n" = dplyr::n()) |> dplyr::pull("n") == 0){
        cli::cli_warn("Death table is empty. Skipping survival analysis")
      }else{
        deathCohortName <- paste0(prefix, "death_cohort")
        cdm[[deathCohortName]] <- CohortConstructor::deathCohort(cdm,
                                                                 name = deathCohortName,
                                                                 subsetCohort = tempCohortName,
                                                                 subsetCohortId = NULL)

        cli::cli_bullets(c(">" = "Estimating single survival event"))
        results[["single_survival_event"]] <- CohortSurvival::estimateSingleEventSurvival(cdm,
                                                                                          targetCohortTable = tempCohortName,
                                                                                          outcomeCohortTable = deathCohortName)
      }
    }else{
      cli::cli_warn("No table 'death' in the cdm object. Skipping survival analysis.")
      results[["single_survival_event"]] <- omopgenerics::emptySummarisedResult()
    }
  }

  omopgenerics::dropSourceTable(cdm, dplyr::starts_with(prefix))
  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind()

  newSettings <- results |>
    omopgenerics::settings() |>
    dplyr::mutate("phenotyper_version" = as.character(utils::packageVersion(pkg = "PhenotypeR")),
                  "diagnostic" = "cohortDiagnostics",
                  "cohortSample"  = .env$cohortSample,
                  "matchedSample" = .env$matchedSample)

  results <- results |>
    omopgenerics::newSummarisedResult(settings = newSettings)

  return(results)
}

createMatchedCohorts <- function(cdm, tempCohortName, cohortName, cohortIds, matchedSample){

  cdm <- omopgenerics::emptyCohortTable(cdm, name = tempCohortName)

  for(i in seq_along(cohortIds)){
    tempCohortNameId <- paste0(tempCohortName,i)

    workingCohortId <- cohortIds[i]
    workingCohortName <- omopgenerics::getCohortName(cdm[[cohortName]],
                                                     cohortId = workingCohortId)

    cdm[[tempCohortNameId]] <- CohortConstructor::subsetCohorts(
      cdm[[cohortName]],
      cohortId = workingCohortId,
      name = tempCohortNameId)

    if(!is.null(matchedSample)){
      cli::cli_bullets(c(">" = glue::glue("Sampling cohort `{cohortName}`")))
      cdm[[tempCohortNameId]] <- CohortConstructor::sampleCohorts(cdm[[tempCohortNameId]],
                                                                  cohortId = workingCohortId,
                                                                  n = matchedSample,
                                                                  name = tempCohortNameId)
    }

    cli::cli_bullets(c("*" = "{.strong Generating an age and sex matched cohort for {workingCohortName}}"))
    cdm[[tempCohortNameId]] <- CohortConstructor::matchCohorts(cdm[[tempCohortNameId]],
                                                               name = tempCohortNameId)

    cdm <- bind(cdm[[tempCohortName]], cdm[[tempCohortNameId]], name = tempCohortName)
  }

  return(cdm)
}

checksCohortDiagnostics <- function(survival, cohortSample, matchedSample, call = parent.frame()){
  omopgenerics::assertLogical(survival, call = call)
  if(isTRUE(survival)){
    rlang::check_installed("CohortSurvival", version = "1.0.2")
  }
  omopgenerics::assertNumeric(cohortSample, integerish = TRUE, min = 0, null = TRUE, length = 1, call = call)
  omopgenerics::assertNumeric(matchedSample, integerish = TRUE, min = 0, null = TRUE, length = 1, call = call)
}
