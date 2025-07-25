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
#'
#' @return A shiny app
#' @export
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#' library(dplyr)
#'
#' cdm <- mockPhenotypeR()
#'
#' result <- phenotypeDiagnostics(cdm$my_cohort)
#' expectations <- tibble("cohort_name" = rep(c("cohort_1", "cohort_2"),3),
#'                        "value" = c(rep(c("Mean age"),2),
#'                                    rep("Male percentage",2),
#'                                    rep("Survival probability after 5y",2)),
#'                        "estimate" = c("32", "54", "25%", "74%", "95%", "21%"),
#'                        "source" = rep(c("AlbertAI"),6))
#'
#' shinyDiagnostics(result, tempdir(), expectations = expectations)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
shinyDiagnostics <- function(result,
                             directory,
                             minCellCount = 5,
                             open = rlang::is_interactive(),
                             expectations = NULL){
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

  # remove tabs
  ui <- readLines(con = file.path(to,"ui.R"))
  if(nrow(result) == 0){
    cli::cli_warn("The summarised result is empty. ShinyDiagnostics will create an empty shiny app.")
    diagnostics <- ""
  }else{
    diagnostics <- omopgenerics::settings(result) |> dplyr::pull("diagnostic") |> unique()
  }
  ui <- removeLines(ui, diagnostics, "databaseDiagnostics")
  ui <- removeLines(ui, diagnostics, "codelistDiagnostics")
  ui <- removeLines(ui, diagnostics, "cohortDiagnostics")
  ui <- removeLines(ui, diagnostics, "populationDiagnostics")
  writeLines(ui, file.path(to,"ui.R"))

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

removeLines <- function(ui, diagnostics, diagnostic_type){
  if(!diagnostic_type %in% diagnostics){
    startLine <- which(stringr::str_detect(ui, paste0(diagnostic_type, "_start")))
    endLine   <- which(stringr::str_detect(ui, paste0(diagnostic_type, "_end")))
    ui <- ui[-seq(startLine,endLine,1)]
    if(length(diagnostics) == 1 && diagnostics != ""){
      cli::cli_warn("{diagnostic_type} is not present in the summarised result. Eliminating tab from the shiny app.")
    }
  }
  return(ui)
}
