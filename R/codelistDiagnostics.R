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
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(CohortConstructor)
#' library(PhenotypeR)
#'
#' cdm <- mockPhenotypeR()
#'
#' cdm$arthropathies <- conceptCohort(cdm,
#'                                    conceptSet = list("arthropathies" = c(40475132)),
#'                                    name = "arthropathies")
#'
#' result <- codelistDiagnostics(cdm$arthropathies)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
codelistDiagnostics <- function(cohort){

  cohort <- omopgenerics::validateCohortArgument(cohort = cohort)
  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  cohortTable <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

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

  cli::cli_bullets(c("*" = "Getting codelists from cohorts"))

   # get all cohort codelists
  all_codelists <- purrr::map(cohortIds, \(x) {
    omopgenerics::cohortCodelist(cohortTable = cdm[[cohortTable]], cohortId = x)
  }) |>
    purrr::flatten() |>
    omopgenerics::newCodelist()

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
  ids <- CDMConnector::cohortCount(cdm[[cohortName]]) |>
    dplyr::filter(number_subjects == 0) |>
    dplyr::pull("cohort_definition_id")

  cli::cli_bullets(c("*" = "Getting index event breakdown"))
  for(i in seq_along(cohortIds)){
    if(i %in% ids){
      cli::cli_warn(message = c("!" = paste0("cohort_definition_id ", i, " is empty. Skipping code use for this cohort.")))
      results[[paste0("index_event_", i)]] <- omopgenerics::emptySummarisedResult()
    }else{
      results[[paste0("index_event_", i)]] <- CodelistGenerator::summariseCohortCodeUse(
        x = omopgenerics::cohortCodelist(cdm[[cohortName]], cohortIds[[i]]),
        cdm = cdm,
        cohortTable = cohortName,
        cohortId = cohortIds[[i]],
        timing = "entry",
        countBy = c("record", "person"),
        byConcept = TRUE
      )
    }
  }

  # all other analyses require achilles, so return if not available
  if(!"achilles_results" %in% names(cdm)){
    cli::cli_warn(
      c("The CDM reference containing the cohort must also contain achilles tables.",
        "Returning only index event breakdown.")
    )
    results <- results |>
      vctrs::list_drop_empty() |>
      omopgenerics::bind()

   if(is.null(results)){
     results <- omopgenerics::emptySummarisedResult()
   }

    return(results)
  }


  cli::cli_bullets(c("*" = "Getting code counts in database based on achilles"))
  results[[paste0("achilles_code_use")]] <- CodelistGenerator::summariseAchillesCodeUse(x = all_codelists, cdm = cdm)

  # cli::cli_bullets(c("*" = "Getting unmapped concepts"))
  # results[[paste0("unmapped_codes", i)]] <- CodelistGenerator::summariseUnmappedCodes(
  #   x = all_codelists,
  #   cdm = cdm
  # )

  cli::cli_bullets(c("*" = "Getting orphan concepts"))
  results[[paste0("orphan_codes", i)]] <- CodelistGenerator::summariseOrphanCodes(
      x = all_codelists,
      cdm = cdm
    )

  results <- results |>
    vctrs::list_drop_empty() |>
    omopgenerics::bind()

  results
}
