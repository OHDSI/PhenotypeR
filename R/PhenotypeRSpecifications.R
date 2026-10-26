
PhenotypeRDiagnostics <- c(
  "databaseDiagnostics",
  "codelistDiagnostics",
  "cohortDiagnostics",
  "populationDiagnostics"
)
PhenotyepeRDiagnosticsSpecs <- list(
  args = c(
    "cohortId", "snapshot", "personTableSummary", "observationPeriodsSummary",
    "clinicalRecordsSummary", "achillesCodeUse", "orphanCodeUse",
    "cohortCodeUse", "drugDiagnostics", "drugDiagnosticsSample",
    "measurementDiagnostics", "measurementDiagnosticsSample", "cohortCount",
    "cohortCharacteristics", "largeScaleCharacteristics", "compareCohorts",
    "cohortSurvival", "cohortSample", "matchedSample", "incidence",
    "periodPrevalence", "populationSample", "populationDateRange"
  ),
  argType = c(
    "character", rep("logical", 8), "numeric", "logical", "numeric",
    rep("logical", 5), rep("numeric", 2), rep("logical", 2), "numeric",
    "character"
  ),
  diagnostics = c(
    "id", rep("databaseDiagnostics", 4), rep("codelistDiagnostics", 7),
    rep("cohortDiagnostics", 7), rep("populationDiagnostics", 4)
  )
)

#' Create a `phenotyper_specification` object
#'
#' @param databaseDiagnostics
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
#' x <- newPhenotypeRSpecifications(
#'   codelistDiagnostics = list(cohortId = "acetaminophen", orphanCodeUse = TRUE)
#' )
#'
#' x
#'
newPhenotypeRSpecifications <- function(databaseDiagnostics = NULL,
                                        codelistDiagnostics = NULL,
                                        cohortDiagnostics = NULL,
                                        populationDiagnostics = NULL) {
  # TODO Discuss if default should be NULL [Not run that diagnostic] or list() [run with deafults]
  x <- constructPhenotypeRSpecifications(
    databaseDiagnostics = databaseDiagnostics,
    codelistDiagnostics = codelistDiagnostics,
    cohortDiagnostics = cohortDiagnostics,
    populationDiagnostics = populationDiagnostics
  )
  validatePhenotypeRSpecifications(x)
}

#' Import a `phenotyper_specification` object from a `json` or `xlsx` file
#'
#' @param path File path to a `json` or `xslx` file that contains a valid
#' `phenotyper_specification` definition.
#'
#' @returns A `phenotyper_specification` object.
#'
#' @export
#'
#' @examples
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

#' Export a `phenotyper_specification` object to a `json` or `xlsx` file
#'
#' @param x A `phenotyper_specification` object.
#' @param fileName Name of the file to be created.
#' @param path Path where to save the file.
#' @param type Character with the `type` to export: "excel" or "json".
#'
#' @returns A file will be created with the `phenotyper_specification`
#' definition.
#'
#' @export
#'
#' @examples
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
    if (endsWith(fileName, ".xls")) {
      fileName <- paste0(fileName, "x")
    } else if (!endsWith(fileName, ".xlsx")) {
      fileName <- paste0(fileName, ".xlsx")
    }
    # add instructions
    wb <- openxlsx::loadWorkbook(
      file = system.file("Instructions.xlsx", package = "CodelistGenerator")
    )
    # add data to the Specifications sheet
    openxlsx::writeData(
      wb = wb,
      sheet = "Specifications",
      x = dplyr::as_tibble(x),
      startCol = 2,
      startRow = 3
    )
    openxlsx::saveWorkbook(
      wb = wb,
      file = file.path(path, fileName),
      overwrite = TRUE
    )
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

#' @export
as_tibble.phenotyper_specifications <- function(x, ...) {
  cohortIds <- x |>
    purrr::list_flatten() |>
    purrr::map("cohortId") |>
    purrr::list_c(ptype = character()) |>
    unique() |>
    sort()

  tib <- dplyr::tibble(cohortId = cohortIds)

  cols <- PhenotyepeRDiagnosticsSpecs$args
  type <- PhenotyepeRDiagnosticsSpecs$argType
  diag <- PhenotyepeRDiagnosticsSpecs$diagnostics

  for (dg in PhenotypeRDiagnostics) {
    lj <- x[[dg]] |>
      purrr::map(\(x) {
        purrr::imap(x, \(x, nm) {
          if (nm == "populationDateRange") {
            # format date in `YYYY-MM-DD to YYYY-MM-DD`
          }
        }) |>
          dplyr::as_tibble()
      }) |>
      dplyr::bind_rows()

    cols_diag <- cols[diag %in% c("id", dg)]

    # add missing columns
    missingCols <- cols_diag[!cols_diag %in% colnames(lj)]
    if (length(missingCols) > 0) {
      q <- rep("NA", length(missingCols)) |>
        rlang::set_names(missingCols) |>
        parse_exprs()
      lj <- lj |>
        dplyr::mutate(!!!q)
    }

    # add to tibble
    tib <- tib |>
      dplyr::left_join(
        lj |>
          dplyr::select(dplyr::all_of(cols_diag)),
        by = "cohortId"
      )
  }

  # cast columns
  tib <- tib |>
    dplyr::mutate(
      dplyr::across(dplyr::all_of(cols[type == "character"]), as.character),
      dplyr::across(dplyr::all_of(cols[type == "numeric"]), as.numeric),
      dplyr::across(dplyr::all_of(cols[type == "logical"]), as.logical)
    )

  return(tib)
}

constructPhenotypeRSpecifications <- function(databaseDiagnostics,
                                              codelistDiagnostics,
                                              cohortDiagnostics,
                                              populationDiagnostics) {
  structure(
    .Data = list(
      databaseDiagnostics = databaseDiagnostics,
      codelistDiagnostics = codelistDiagnostics,
      cohortDiagnostics = cohortDiagnostics,
      populationDiagnostics = populationDiagnostics
    ),
    class = c("phenotyper_specifications", "list")
  )
}
validatePhenotypeRSpecifications <- function(x, call = parent.frame()) {
  omopgenerics::assertClass(x, class = "phenotyper_specifications", call = call)
  omopgenerics::assertList(x, call = call, named = TRUE)
  omopgenerics::assertTrue(identical(names(x), PhenotypeRDiagnostics))

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

  cols <- PhenotyepeRDiagnosticsSpecs$args
  type <- PhenotyepeRDiagnosticsSpecs$argType
  diag <- PhenotyepeRDiagnosticsSpecs$diagnostics

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
    # identify diagnostics parametrisation
    phenotypeRSpecifications[[dg]] <- x |>
      dplyr::select("cohortId", dplyr::all_of(cols[diag == dg])) |>
      dplyr::group_split(dplyr::across(!"cohortId")) |>
      purrr::map(\(diag_group) {
        diag_group |>
          purrr::map(unique) |>
          purrr::keep(\(x) !all(is.na(x)))
      })
  }

  return(phenotypeRSpecifications)
}
