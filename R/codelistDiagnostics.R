#' Run codelist-level diagnostics
#'
#' @description
#' `codelistDiagnostics()` runs phenotypeR diagnostics on the cohort_codelist
#' attribute on the cohort. Thus codelist attribute of the cohort must be
#' populated. If it is missing then it could be populated using
#' `addCodelistAttribute()` function.
#'
#' Furthermore `codelistDiagnostics()` requires achilles tables to be present in
#' the cdm so that concept counts could be derived.
#'
#' @param cohort A cohort table in a cdm reference. The cohort_codelist
#' attribute must be populated. The cdm reference must contain achilles
#' tables as these will be used for deriving concept counts.
#' @inheritParams measurementSampleDoc
#' @inheritParams drugExposureSampleDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(omock)
#' library(CohortConstructor)
#' library(PhenotypeR)
#'
#' cdm <- mockCdmFromDataset(source = "duckdb")
#' cdm$warfarin <- conceptCohort(cdm,
#'                               conceptSet =  list(warfarin = c(1310149L,
#'                                                               40163554L)),
#'                               name = "warfarin")
#' result <- codelistDiagnostics(cdm$warfarin)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
codelistDiagnostics <- function(cohort,
                                measurementSample = 20000,
                                drugExposureSample = 20000){

  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  cdm <- omopgenerics::cdmReference(cohort)
  cohortTable <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()
  measurementSample <- omopgenerics::assertNumeric(measurementSample,
                                                   min = 0, length = 1, null = TRUE)
  drugExposureSample <- omopgenerics::assertNumeric(drugExposureSample,
                                                   min = 0, length = 1, null = TRUE)

  addAttribute <- c("i" = "You can add a codelist to a cohort with `addCodelistAttribute()`.")
  notPresentCodelist <- is.null(attr(cdm[[cohortTable]], "cohort_codelist"))
  if (!notPresentCodelist) {
    notPresentCodelist <- attr(cdm[[cohortTable]], "cohort_codelist") |>
      omopgenerics::isTableEmpty()
    if(notPresentCodelist){
      cli::cli_warn(message = c(
        "!" = "cohort_codelist attribute for cohort is empty",
        "i" = "Returning an empty summarised result",
        addAttribute
      ))
      return(omopgenerics::emptySummarisedResult())
    }
  }
  if (notPresentCodelist) {
    cli::cli_warn(message = c(
      "!" = "cohort_codelist attribute for cohort not found",
      "i" = "Returning an empty summarised result",
      addAttribute
    ))
    return(omopgenerics::emptySummarisedResult())
  }

  # get all cohort codelists
  all_codelists <- purrr::map(cohortIds, \(x) {
    omopgenerics::cohortCodelist(cohortTable = cdm[[cohortTable]], cohortId = x)
  }) |>
    duplicatedCodelists()

  if(length(all_codelists) == 0){
    cli::cli_warn(message = c(
      "!" = "Empty cohort_codelist attribute for cohort",
      "i" = "Returning an empty summarised result",
      addAttribute
    ))
    return(omopgenerics::emptySummarisedResult())
  }

  results <- list()
  results[[1]] <- omopgenerics::emptySummarisedResult()

  # Check empty cohorts
  ids <- omopgenerics::cohortCount(cdm[[cohortTable]]) |>
    dplyr::filter(.data$number_subjects == 0) |>
    dplyr::pull("cohort_definition_id")

  if (!is.null(getOption("omopgenerics.logFile"))) {
    omopgenerics::logMessage("Codelist diagnostics - index event breakdown")
  }
  results[["index_event_"]] <- CodelistGenerator::summariseCohortCodeUse(
    cdm = cdm,
    cohortTable = cohortTable,
    timing = "entry",
    countBy = c("record", "person"))

  # If any measurement/observation codes: do measurement diagnostics
  measurements <- cdm$concept |>
    dplyr::select(dplyr::all_of(c("concept_id", "domain_id"))) |>
    dplyr::inner_join(
      attr(cdm[[cohortTable]], "cohort_codelist") |>
        dplyr::distinct(.data$cohort_definition_id, .data$codelist_name, .data$concept_id),
      by = "concept_id"
    ) |>
    dplyr::filter(tolower(.data$domain_id) %in% c("measurement")) |>
    dplyr::collect()

  if (nrow(measurements) > 0 && (!0 %in% measurementSample)) {
    if (!is.null(getOption("omopgenerics.logFile"))) {
      omopgenerics::logMessage("Codelist diagnostics - measurement concepts")
    }
    measurementCohortsIds <- unique(measurements$cohort_definition_id)

    for (id in measurementCohortsIds) {
      measurementCohort <- cdm[[cohortTable]] |>
        CohortConstructor::subsetCohorts(cohortId = id, name = "measurement_diagnostics_temp_1234")
     if(!is.null(measurementSample)){
       measurementCohort <- measurementCohort |>
         CohortConstructor::sampleCohorts(measurementSample)
     }
      codes <- measurements |>
        dplyr::filter(.data$cohort_definition_id == id)
      codes <- base::split(codes$concept_id, codes$codelist_name)
      results[[paste0("measurement_diagnostics_", id)]] <- MeasurementDiagnostics::summariseCohortMeasurementUse(
        codes = codes,
        cohort = measurementCohort,
        timing = "any",
        byConcept = TRUE,
        byYear = FALSE,
        bySex = FALSE,
        ageGroup = NULL,
        dateRange = as.Date(c(NA, NA)),
        checks = c("measurement_summary", "measurement_value_as_number",
                   "measurement_value_as_concept")
      )
    }
    omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with("measurement_diagnostics_temp_1234"))
  }

  # If any drug codes: do drug exposure diagnostics
  if(!0 %in% drugExposureSample){
  drugs <- cdm$concept |>
    dplyr::select(dplyr::all_of(c("concept_id", "domain_id"))) |>
    dplyr::inner_join(
      attr(cdm[[cohortTable]], "cohort_codelist") |>
        dplyr::distinct(.data$cohort_definition_id, .data$codelist_name, .data$concept_id),
      by = "concept_id"
    ) |>
    dplyr::filter(tolower(.data$domain_id) %in% c("drug")) |>
    dplyr::collect()
  if (nrow(drugs) > 0) {
    if (!is.null(getOption("omopgenerics.logFile"))) {
      omopgenerics::logMessage("Codelist diagnostics - drug diagnostics")
    }
    drugCohortsIds <- unique(drugs$cohort_definition_id)
    for (id in drugCohortsIds) {
      nm <- omopgenerics::uniqueTableName()
      drugCohort <- cdm[[cohortTable]] |>
        CohortConstructor::subsetCohorts(cohortId = id, name = nm)
      if(!is.null(drugExposureSample)){
        drugCohort <- drugCohort |>
          CohortConstructor::sampleCohorts(drugExposureSample)
      }
      codes <- drugs |>
        dplyr::filter(.data$cohort_definition_id == id) |>
        omopgenerics::newCodelist()
      results[[paste0("drug_diagnostics_", id)]] <- summariseCohortDrugUse(
        cohort = drugCohort,
        codes = codes,
        timing = "any",
        byConcept = TRUE,
        byYear = FALSE,
        bySex = FALSE,
        ageGroup = NULL,
        dateRange = as.Date(c(NA, NA)),
        checks = c("exposureDuration", "quantity", "type",
                   "route", "quantity", "dose",
                   "daysBetween")
      )
      omopgenerics::dropSourceTable(cdm = cdm, name = nm)
    }
  }
  }

  # all other analyses require achilles, so return if not available
  if("achilles_results" %in% names(cdm)){
    if (!is.null(getOption("omopgenerics.logFile"))) {
      omopgenerics::logMessage("Codelist diagnostics - achilles code counts")
    }
    results[[paste0("achilles_code_use")]] <- CodelistGenerator::summariseAchillesCodeUse(x = all_codelists, cdm = cdm)

    if (!is.null(getOption("omopgenerics.logFile"))) {
      omopgenerics::logMessage("Codelist diagnostics - orphan concepts")
    }

    results[["orphan_codes"]] <- CodelistGenerator::summariseOrphanCodes(
      x = all_codelists,
      cdm = cdm
    )
  }else{
    cli::cli_warn(
      c("The CDM reference containing the cohort must also contain achilles tables.",
        "Returning only index event breakdown.")
    )
  }

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind()

  if(is.null(results)){
    results <- omopgenerics::emptySummarisedResult()
  }

  newSettings <- results |>
    omopgenerics::settings() |>
    dplyr::mutate("phenotyper_version" = as.character(utils::packageVersion(pkg = "PhenotypeR")),
                  "diagnostic" = "codelistDiagnostics")

  results <- results |>
    omopgenerics::newSummarisedResult(settings = newSettings)

 return(results)
}

duplicatedCodelists <- function(codelists) {
  # check names
  codelist <- codelists |>
    purrr::map(names) |>
    purrr::flatten_chr() |>
    unique() |>
    rlang::set_names() |>
    purrr::map(\(nm) {
      codelists |>
        purrr::map(\(x) x[[nm]]) |>
        purrr::compact() |>
        # this will ensure that if the duplicated codelist is the same there is no error
        unique()
    })
  dupl <- purrr::keep(lengths(codelist), \(x) x > 1)
  if (length(dupl)) {
    dupl <- dupl |>
      purrr::imap_chr(\(x, nm) paste0("Codelist {.pkg ", nm, "}: ", x, " definitions."))
    cli::cli_abort(c(
      x = "There are codelists with multiple definitions in cohort: ",
      dupl,
      i = "Please provide unique definitions for each codelist"
    ))
  }
  codelist |>
    purrr::flatten() |>
    omopgenerics::newCodelist()
}
