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
#'
#' @return A shiny app
#' @export
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#'
#' cdm <- mockPhenotypeR()
#'
#' result <- phenotypeDiagnostics(cdm$my_cohort)
#'
#' shinyDiagnostics(result, tempdir())
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
shinyDiagnostics <- function(result,
                             directory,
                             minCellCount = 5,
                             open = rlang::is_interactive()){
  folderName <- "PhenotypeRShiny"

  # check if directory needs to be overwritten directory
  directory <- validateDirectory(directory, folderName)
  if (isTRUE(directory)) {
    return(cli::cli_inform(c("i" = "{.strong shiny} folder will not be overwritten. Stopping process.")))
  }

  cli::cli_inform(c("i" = "Creating shiny from provided data"))

  # copy files
  to <- file.path(directory, folderName)
  from <- system.file("shiny", package = "PhenotypeR")
  copyDirectory(from = from, to = to)

  # export data
  omopgenerics::exportSummarisedResult(result = result,
                                       minCellCount = minCellCount,
                                       fileName = "result.csv",
                                       path = file.path(to, "data", "raw"))

  # open project
  if (isTRUE(open)) {
    rlang::check_installed("usethis")
    usethis::proj_activate(path = to)
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
  files <- list.files(path = from, full.names = TRUE, recursive = TRUE)

  # new file names
  newFiles <- files |>
    purrr::map_chr(\(x) {
      nm <- stringr::str_replace(
        string = x,
        pattern = paste0("^", from),
        replacement = to
      )
      dir <- dirname(nm)
      if (!dir.exists(dir)) {
        dir.create(path = dir, recursive = TRUE)
      }
      nm
    })

  # copy files
  file.copy(from = files, to = newFiles)
}
