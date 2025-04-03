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

  directory <- validateDirectory(directory)
  if (isTRUE(directory)) {
    return(cli::cli_inform(c("i" = "{.strong shiny} folder will not be overwritten. Stopping process.")))
  }

  dir.create(path = file.path(directory, "shiny"), showWarnings = FALSE)
  cli::cli_inform(c("i" = "Creating shiny from provided data"))

  file.copy(from = system.file("shiny",
                               package = "PhenotypeR"),
            to = directory,
            recursive = TRUE,
            overwrite = TRUE)

  omopgenerics::exportSummarisedResult(result,
                                       minCellCount = minCellCount,
                                       fileName = "result.csv",
                                       path = file.path(directory, "shiny", "data", "raw"))

  # shiny::shinyAppDir(file.path(directory, "shiny"))
  if (isTRUE(open)) {
  rlang::check_installed("usethis")
  usethis::proj_activate(path = file.path(directory,"shiny"))
  }

  return(invisible())
}


validateDirectory <- function(directory) {
  # create directory if it does not exit
  if (!dir.exists(directory)) {
    cli::cli_inform(c("i" = "Provided directory does not exist, it will be created."))
    dir.create(path = directory, recursive = TRUE)
    cli::cli_inform(c("v" = "directory created: {.pkg {directory}}"))

  } else if (file.exists(file.path(directory, "shiny"))) {
    # ask overwrite shiny
    overwrite <- "1"  # overwrite if non-interactive
    if (rlang::is_interactive()) {
      cli::cli_inform(c(
        "!" = "A {.strong shiny} folder already exists in the provided directory. Enter choice 1 or 2:",
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
      cli::cli_inform(c("i" = "{.strong shiny} folder will be overwritten."))
      unlink(file.path(directory, "shiny"), recursive = TRUE)
      cli::cli_inform(c("v" = "Prior {.strong shiny} folder deleted."))
    }
  }
  return(directory)
}


