
PhenotypeRDiagnostics <- c(
  "databaseDiagnostics",
  "codelistDiagnostics",
  "cohortDiagnostics",
  "populationDiagnostics"
)

#' Create a `phenotyper_specification` object
#'
#' @param x A named list with `r PhenotypeRDiagnostics` fields.
#' Each element should be a valid input for the
#' `PehnotypeR::phenotypeDiagnostics()` arguments:
#'   - **databaseDiagnostics**
#'   - **codelistDiagnostics**
#'   - **cohortDiagnostics**
#'   - **populationDiagnostics**
#'
#' @returns A `phenotyper_specification` object.
#' @export
#'
#' @examples
#' library(PhenotypeR)
#'
#' x <- list(
#'   codelistDiagnostics = list(cohortId = "acetaminophen", orphanCodeUse = TRUE)
#' ) |>
#'   newPhenotypeRSpecifications()
#'
#' x
#'
newPhenotypeRSpecifications <- function(x) {
  x <- constructPhenotypeRSpecifications(x)
  validatePhenotypeRSpecifications(x)
}

importPhenotypeRSpecifications <- function(path) {

}

exportPhenotypeRSpecifications <- function(x,
                                           fileName,
                                           path = getwd(),
                                           type = "excel") {

}

#' @export
print.phenotyper_specifications <- function(x, ...) {
  cli::cli_h1("PhenotypeR specifications")
  cli::cat_line("")
  for (sec in PhenotypeRDiagnostics) {
    cli::cat_line(paste0("- ", length(x[[sec]]), " ", sec))
  }
  invisible(x)
}

constructPhenotypeRSpecifications <- function(x) {
  structure(.Data = x, class = c("phenotyper_specifications", "list"))
}
validatePhenotypeRSpecifications <- function(x, call = parent.frame()) {
  omopgenerics::assertClass(x, class = "phenotyper_specifications", call = call)

  omopgenerics::assertList(x, call = call)

  # add missing labels as not run TODO: discuss if missing is not run or run with defaults
  for (nm in PhenotypeRDiagnostics) {
    if (!nm %in% names(x)) {
      x[[nm]] <- NULL
    }
  }

  # remove extra labels
  extra <- names(x)[!names(x) %in% PhenotypeRDiagnostics]
  if (length(extra) > 0) {
    cli::cli_inform(c("!" = "Extra labels removed from PhenotypeR specifications: {extra}."))
    x[extra] <- NULL
  }

  # validate inputs
  for (nm in PhenotypeRDiagnostics) {
    x[[nm]] <- validateDiagnosticsInput(x[[nm]], nm, call = call)
  }

  return(x)
}
