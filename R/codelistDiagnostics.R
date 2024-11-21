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
#'   cdm_local <- omock::mockCdmReference() |>
#'   omock::mockPerson(nPerson = 100) |>
#'   omock::mockObservationPeriod() |>
#'   omock::mockConditionOccurrence() |>
#'   omock::mockDrugExposure() |>
#'   omock::mockCohort(name = "my_cohort")
#'
#'   db <- DBI::dbConnect(duckdb::duckdb())
#'
#'   cdm <- CDMConnector::copyCdmTo(con = db,
#'                                  cdm = cdm_local,
#'                                  schema ="main",
#'                                  overwrite = TRUE)
#'
#'  result <- cdm$my_cohort |>
#'    codelistDiagnostics()
#'
#'  CDMConnector::cdmDisconnect(cdm = cdm)
#' }
codelistDiagnostics <- function(cohort){

  cdm <- omopgenerics::cdmReference(cohort)
  cohortName <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  cohortTable <- omopgenerics::tableName(cohort)
  cohortIds <- omopgenerics::settings(cohort) |>
    dplyr::select("cohort_definition_id") |>
    dplyr::pull()

  if(is.null(attr(cdm[[cohortTable]], "cohort_codelist"))){
    cli::cli_warn(message =
                    c("cohort_codelist attribute for cohort not found",
                      "i" = "Returning an empty summarised result"))
    return(omopgenerics::emptySummarisedResult())
  }

  cli::cli_bullets(c("*" = "Getting codelists from cohorts"))

   # get all cohort codelists
  all_codelists <- omopgenerics::emptyCodelist()
  for(i in seq_along(cohortIds)){
    all_codelists <- purrr::flatten(list(
      all_codelists,
      omopgenerics::cohortCodelist(cdm[[cohortTable]], cohortIds[[i]])
    )) |>
      omopgenerics::newCodelist()
  }

  if(length(all_codelists) == 0){
    cli::cli_warn(message =
                    c("Empty cohort_codelist attribute for cohort",
                      "i" = "Returning an empty summarised result"))
    return(omopgenerics::emptySummarisedResult())
  }

  results <- list()
  results[[1]] <- omopgenerics::emptySummarisedResult()

  cli::cli_bullets(c("*" = "Getting index event breakdown"))
  for(i in seq_along(cohortIds)){
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
