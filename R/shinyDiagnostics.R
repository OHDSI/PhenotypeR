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
#' @param minCellCount Minimum cell count for suppression when exporting results.
#' @param open If TRUE, the shiny app will be launched in a new session. If
#' FALSE, the shiny app will be created but not launched.
#' @inheritParams expectationsDoc
#' @param clinicalDescriptionsDir Directory where to find the clinical descriptions word documents.
#' @param removeEmptyTabs Whether to remove tabs of those diagnostics that have not been performed or that were insufficient counts to produce a result (TRUE) or not (FALSE)
#'
#' @return A shiny app
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
#'
#' result <- phenotypeDiagnostics(cdm$warfarin, populationSample = 100000)
#'
#' expectations <- dplyr::tibble("cohort_name" = "warfarin",
#'                        "estimate" = c("Mean age",
#'                                    "Male percentage",
#'                                    "Frequently seen comorbidities"),
#'                        "value" = c("32", "74%",  "Atrial fibrillation, heart failure, hypertension and ischaemic heart disease"),
#'                        "diagnostics" = c("cohort_characteristics", "cohort_characteristics", "compare_large_scale_characteristics"),
#'                        "source" = c("AlbertAI"))
#'
#' shinyDiagnostics(result, tempdir(), expectations = expectations)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
shinyDiagnostics <- function(result,
                             directory,
                             minCellCount = 5,
                             open = rlang::is_interactive(),
                             expectations = NULL,
                             clinicalDescriptionsDir = NULL,
                             removeEmptyTabs = TRUE){
  folderName <- "PhenotypeRShiny"
  omopgenerics::assertTable(expectations,
                            columns = c("cohort_name", "estimate", "value", "source"),
                            allowExtraColumns = TRUE, null = TRUE)

  # Check phenotyper version
  if(nrow(result) != 0){
    if(!"phenotyper_version" %in% colnames(result |> omopgenerics::settings())){
      cli::cli_abort("PhenotypeDiagnostics results were generated with an old version of PhenotypeR. Please re-run the analysis with the new version to avoid version conflicts. Alternatively, use the same version to run shinyDiagnostics().")
    }else{
      phenotyper_version <- result |>
        omopgenerics::settings() |>
        dplyr::pull("phenotyper_version") |>
        unique()
      if(length(phenotyper_version) > 1){
        cli::cli_warn("result was generated using different PhenotypeR versions.")
      }else{
        current_version <- utils::packageVersion("PhenotypeR")
        if(phenotyper_version != current_version){
          cli::cli_warn("result was generated using PhenotypeR version {phenotyper_version}, whereas the version currently installed is {current_version}")
        }
      }
    }
  }

  # check if directory needs to be overwritten directory
  directory <- validateDirectory(directory, folderName)
  if (isTRUE(directory)) {
    return(cli::cli_inform(c("i" = "{.strong shiny} folder will not be overwritten. Stopping process.")))
  }

  cli::cli_inform(c("i" = "Creating shiny from provided data"))

  # copy files
  to <- file.path(directory, folderName)
  from <- system.file("shiny", package = "PhenotypeR")
  invisible(copyDirectory(from = from, to = to))

  # export summarised results
  omopgenerics::exportSummarisedResult(result = result,
                                       minCellCount = minCellCount,
                                       fileName = "result.csv",
                                       path = file.path(to, "data", "raw"))

  # copy clinical descriptions directory
  if(!is.null(clinicalDescriptionsDir)) {
      invisible(copyDirectory(from = clinicalDescriptionsDir, to = file.path(to, "data","raw","clinical_descriptions")))
  }

  # remove tabs
  if(isTRUE(removeEmptyTabs)){
    ui <- readLines(con = file.path(to,"ui.R"))
    diag_to_remove <- checkWhichDiagnostics(result)
    ui <- removeDiagnostics(ui, result, diag_to_remove)
    writeLines(ui, file.path(to,"ui.R"))
  }

  # export expectations
  dir.create(file.path(to,"data","raw","expectations"))
  if(!is.null(expectations)){
    readr::write_csv(expectations, file = file.path(to, "data", "raw", "expectations", "expectations.csv"))
  }else{
    dplyr::tibble("cohort_name" = NA_character_,
                   "value" = NA_character_,
                   "estimate" = NA_character_,
                   "source" = NA_character_) |>
      readr::write_csv(file = file.path(to, "data", "raw", "expectations", "expectations.csv"))
  }

  # open project
  if (isTRUE(open)) {
    rlang::check_installed("usethis")
    usethis::proj_activate(path = to)
  }else{
    if(dir.exists(paste0(directory,"/", folderName))){
      cli::cli_inform(c("i" = "Shiny app created in {directory}/{folderName}"))
    }else{
      cli::cli_inform(c("i" = "Shiny app could not be created in {directory}. Please try again."))
    }
  }

  return(invisible())
}

validateDirectory <- function(directory, folderName) {
  # create directory if it does not exit
  if (!dir.exists(directory)) {
    cli::cli_inform(c("i" = "Provided directory does not exist, it will be created."))
    dir.create(path = directory, recursive = TRUE)
    cli::cli_inform(c("v" = "directory created: {.pkg {directory}}"))

  } else if (file.exists(file.path(directory, folderName))) {
    # ask overwrite shiny
    overwrite <- "1"  # overwrite if non-interactive
    if (rlang::is_interactive()) {
      cli::cli_inform(c(
        "!" = "A {.strong {folderName}} folder already exists in the provided directory. Enter choice 1 or 2:",
        " " = "1) Overwrite",
        " " = "2) Cancel"
      ))
      overwrite <- readline()
      while (!overwrite %in% c("1", "2")) {
        cli::cli_inform(c("x" = "Invalid input. Please choose 1 to overwrite or 2 to cancel:"))
        overwrite <- readline()
      }
    }
    if (overwrite == "2") {
      return(TRUE)
    } else {
      cli::cli_inform(c("i" = "{.strong {folderName}} folder will be overwritten."))
      unlink(file.path(directory, folderName), recursive = TRUE)
      cli::cli_inform(c("v" = "Prior {.strong {folderName}} folder deleted."))
    }
  }
  return(directory)
}

copyDirectory <- function(from, to) {
  # files to copy
  oldFiles <- list.files(path = from, full.names = TRUE, recursive = TRUE)

  files <- list.files(path = from, full.names = FALSE, recursive = TRUE)
  NewFiles <- paste0(to, "/", files)

  dirsToCreate <- unique(dirname(NewFiles))
  sapply(dirsToCreate, dir.create, recursive = TRUE, showWarnings = FALSE)

  # copy files
  file.copy(from = oldFiles, to = NewFiles)
}

checkWhichDiagnostics <- function(result){

  if(nrow(result) == 0){
    diag_present <- ""
  }else{
    diag_present <- omopgenerics::settings(result) |> dplyr::pull("diagnostic") |> unique()
    diag_present <- diag_present[diag_present != "Logging"]
  }

  result_type <- omopgenerics::settings(result) |> dplyr::pull("result_type") |> unique()
  to_remove <- vector("list", length(diag_present))
  names(to_remove) <- diag_present

  if("databaseDiagnostics" %in% names(to_remove)) {
    vals <- c(
      summarise_omop_snapshot   = "snapshot",
      summarise_person          = "person",
      summarise_observation_period = "observation_period",
      summarise_clinical_records   = "clinical_records"
    )

    to_remove[["databaseDiagnostics"]] <- unname(vals[!names(vals) %in% result_type])
  }

  if("codelistDiagnostics" %in% names(to_remove)) {
    vals <- c(
      "achilles_code_use" = "achilles_code_use",
      "orphan_code_use" = "orphan_code_use",
      "cohort_code_use" = "cohort_code_use",
      "measurement_summary" = "measurement_diagnostics",
      "summarise_drug_use" = "drug_diagnostics"
    )

    to_remove[["codelistDiagnostics"]] <- unname(vals[!names(vals) %in% result_type])
  }

  if ("cohortDiagnostics" %in% names(to_remove)) {
    vals <- c(
      "summarise_cohort_count" =  "cohort_count",
      "summarise_characteristics" = "cohort_characteristics",
      "summarise_large_scale_characteristics" = "large_scale_characteristics",
      "summarise_large_scale_characteristics" = "compare_large_scale_characteristics",
      "summarise_cohort_overlap" = "compare_cohorts",
      "survival_estimates" =  "cohort_survival"
    )

    to_remove[["cohortDiagnostics"]] <- unname(vals[!names(vals) %in% result_type])
  }

  if("populationDiagnostics" %in% names(to_remove)) {
    vals <- c(
      "incidence" =  "incidence",
      "prevalence" = "prevalence"
    )

    to_remove[["populationDiagnostics"]] <- unname(vals[!names(vals) %in% result_type])
  }

  return(to_remove)
}

removeDiagnostics <- function(ui, result, to_remove){

  # Eliminate overall diagnostics
  x <- setdiff(c("databaseDiagnostics", "codelistDiagnostics", "cohortDiagnostics", "populationDiagnostics"), names(to_remove))
  if(length(x) != 0) {
    for(i in seq_along(x)){
      start <- which(stringr::str_detect(ui, stringr::regex(paste0("\\b", x[[i]], "_start\\b"), ignore_case = FALSE)))
      end   <- which(stringr::str_detect(ui, stringr::regex(paste0("\\b", x[[i]], "_end\\b"), ignore_case = FALSE)))
      ui <- ui[-seq(start,end,1)]
    }
    cli::cli_warn("{x} tab{?s} will be removed as the diagnostic{?s} {?was/were} not performed")
  }

  # Eliminate specific diagnostics
  if(length(to_remove) != 0) {
    for(i in seq_along(to_remove)){
      if(length(to_remove[[i]]) != 0){
        xi <- to_remove[[i]]

        for(j in seq_along(xi)) {
          start <- which(stringr::str_detect(ui, stringr::regex(paste0("\\b", xi[[j]], "_start\\b"), ignore_case = FALSE)))
          end   <- which(stringr::str_detect(ui, stringr::regex(paste0("\\b", xi[[j]], "_end\\b"), ignore_case = FALSE)))
          ui <- ui[-seq(start,end,1)]
        }

        cli::cli_warn("The following tabs from {names(to_remove[i])} will be removed because they are not present in the summarised result: {to_remove[[i]]}")
      }
    }
  }

  return(ui)
}





