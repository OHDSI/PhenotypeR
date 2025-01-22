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
                             open = rlang::is_interactive()){

  if(file.exists(file.path(directory, "shiny"))){
  cli::cli_inform(c("i" = "Existing {.strong shiny} folder in {.arg directory} will be overwritten."))
  unlink(file.path(directory, "shiny"), recursive = TRUE)
  }

  file.copy(from = system.file("shiny",
                               package = "PhenotypeR"),
            to = directory,
            recursive = TRUE,
            overwrite = TRUE)

  omopgenerics::exportSummarisedResult(result,
                                       fileName = "result.csv",
                                       path = file.path(directory, "shiny", "data", "raw"))
  # shiny::shinyAppDir(file.path(directory, "shiny"))
  if (isTRUE(open)) {
  rlang::check_installed("usethis")
  usethis::proj_activate(path = file.path(directory,"shiny"))
  }

  return(invisible())
}
