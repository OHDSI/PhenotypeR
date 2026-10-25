
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
  omopgenerics::assertCharacter(path, length = 1)

  if (endsWith(path, ".json")) {
    rlang::check_installed("jsonlite", "import in json format")
    x <- jsonlite::read_json(path = path)
  } else if (endsWith(path, ".xlsx")) {
    rlang::check_installed("openxlsx")
    x <- readPhenotypeRExcel(path = path)
  } else {
    cli::cli_abort(c(x = "Only `.xlsx` or `.json` files can contain valid
                     definitions of {.cls phenotyper_specifications}"))
  }

  newPhenotypeRSpecifications(x)
}

exportPhenotypeRSpecifications <- function(x,
                                           fileName,
                                           path = getwd(),
                                           type = "excel") {
  # input check
  x <- validatePhenotypeRSpecifications(x)
  omopgenerics::assertCharacter(fileName, length = 1)
  omopgenerics::assertCharacter(path, length = 1)
  omopgenerics::assertChoice(type, c("excel", "json"), length = 1)

  path <- checkDirectory(path)
  fileName <- file.path(path, fileName)

  if (type == "excel") {
    rlang::check_installed("openxlsx")

  } else if (type == "json") {
    if (!endsWith(fileName, ".json")) {
      fileName <- paste0(fileName, ".json")
    }
    rlang::check_installed("jsonlite", "export in json format")
    jsonlite::write_json(unclass(x), path = fileName, ...)
  }

  invisible(x)
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
readPhenotypeRExcel <- function(path) {
  # to suppress empty worksheets warning
  x <- withCallingHandlers(
    openxlsx::read.xlsx(
      xlsxFile = path,
      sheet = "Specifications",
      startRow = 3,
      cols = 1:24,
      colNames = FALSE,
      skipEmptyRows = TRUE,
      skipEmptyCols = FALSE
    ),
    warning = function(w) {
      if (grepl("No data found on worksheet", conditionMessage(w), fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )

  # if empty return empty list
  if (is.null(x)) {
    return(list())
  }

  # fill empty columns
  Nmissing <- 24 - ncol(x)
  if (Nmissing > 0) {
    x[paste0("X", (ncol(x) + 1):24)] <- NA
  }

  cols <- c(
    "cohortId", "snapshot", "person_table", "observation_period",
    "clinical_records", "achilles_code_use", "orphan_code_use",
    "cohort_code_use", "drug_diagnostics", "drug_diagnostics_sample",
    "measurement_diagnostics", "measurement_diagnostics_sample",
    "cohort_count", "cohort_characteristics", "large_scale_characteristics",
    "compare_cohorts", "cohortSurvival", "cohortOverlap", "cohortSample",
    "matchedSample", "incidence", "periodPrevalence", "populationSample",
    "dateRange"
  )
  type <- c(
    "character", rep("logical", 8), "numeric", "logical", "numeric",
    rep("logical", 6), rep("numeric", 2), rep("logical", 2), "numeric",
    "character"
  )
  diag <- c(
    "id", rep("databaseDiagnostics", 4), rep("codelistDiagnostics", 7),
    rep("cohortDiagnostics", 8), rep("populationDiagnostics", 4)
  )

  rn <- rlang::set_names(paste0("X", 1:24), cols)

  # format list
  x <- dplyr::as_tibble(x) |>
    dplyr::select(dplyr::all_of(rn)) |>
    dplyr::mutate(
      dplyr::across(dplyr::all_of(cols[type == "character"]), as.character),
      dplyr::across(dplyr::all_of(cols[type == "numeric"]), as.numeric),
      dplyr::across(dplyr::all_of(cols[type == "logical"]), as.logical)
    )

  phenotypeRSpecifications <- list()
  # database
  for (dg in PhenotypeRDiagnostics) {
    cols_dg <- cols[diag == dg]
    # identify diagnostics paramatrisation
    dx <- x |>
      dplyr::select("cohortId", dplyr::all_of(cols_dg))
    # add parametrisation id
    phenotypeRSpecifications[[dg]] <- dx |>
      dplyr::inner_join(
        dx |>
          dplyr::select(!"cohortId") |>
          dplyr::distinct() |>
          dplyr::mutate(group_id = dplyr::row_number()),
        by = cols_dg,
        na_matches = "na"
      ) |>
      dplyr::group_split(.data$group_id) |>
      purrr::map(\(diag_group) {
        diag_group |>
          purrr::map(unique) |>
          purrr::keep(\(x) !all(is.na(x)))
      })
  }
}
