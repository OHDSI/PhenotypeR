
PhenotypeRDiagnostics <- c(
  "databaseDiagnostics",
  "codelistDiagnostics",
  "cohortDiagnostics",
  "populationDiagnostics"
)
PhenotypeRDiagnosticsSpecs <- list(
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
#' @param databaseDiagnostics A list of arguments to parametrise
#' `databaseDiagnostics()`. If the list is empty, the default values will be
#' assumed. Use cohort names for cohortId argument
#' (e.g. `cohortId = "myocardial_infarction"`).
#'
#' Example:
#' In the following example, all default diagnostics will be run except
#' *person table summary* from databaseDiagnostics:
#' `databaseDiagnostics = list(personTableSummary = FALSE)`
#'
#' If `NULL` database diagnostics won't be parametrised.
#'
#' @param codelistDiagnostics A list of arguments to parametrise
#' `codelistDiagnostics()`. If the list is empty, the default values will be
#' assumed. Use cohort names for cohortId argument
#' (e.g. `cohortId = "myocardial_infarction"`).
#'
#' Example:
#' In the below example, all diagnostics will be run, and a subsample of
#' 1,000 participants will be used to run measurement diagnostics and another
#' independent subsample of 500 participants will be used to run drug
#' diagnostics:
#'
#' `codelistDiagnostics = list(
#'   measurementDiagnosticsSample = 1000,
#'   drugDiagnosticsSample = 500
#' )`
#'
#' If `NULL` codelist diagnostics won't be parametrised.
#'
#' @param cohortDiagnostics A list of arguments to parametrise
#' `cohortDiagnostics()`. If the list is empty, the default values will be
#' assumed. Use cohort names for cohortId argument
#' (e.g. `cohortId = "myocardial_infarction"`).
#'
#' Example:
#' `cohortDiagnostics = list(
#'   cohortSurvival = TRUE
#' )`
#'
#' If `NULL` cohort diagnostics won't be parametrised.
#'
#' @param populationDiagnostics A list of arguments to parametrise
#' `populationDiagnostics()`. If the list is empty, the default values will be
#' assumed. Use cohort names for cohortId argument
#' (e.g. `cohortId = "myocardial_infarction"`).
#'
#' Example:
#' In the below example, all diagnostics will be run and a subsample of 100,000
#' participants will be used to run populationDiagnostics.
#' `populationDiagnostics = list(
#'   cohortId = "myocardial_infarction",
#'   populationSample = 100000,
#'   populationDateRange = as.Date(c("2015-01-01", "2020-12-31"))
#' )`
#'
#' If `NULL` population diagnostics won't be parametrised.
#'
#' @returns A `phenotyper_specification` object.
#'
#' @export
#'
#' @examples
#' library(PhenotypeR)
#'
#' diag <- newPhenotypeRSpecifications(
#'   codelistDiagnostics = list(cohortId = "warfarin", orphanCodeUse = TRUE)
#' )
#'
#' diag
#'
#' # run Diagnostics from specifications
#' \donttest{
#' library(omock)
#' library(CohortConstructor)
#'
#' cdm <- mockCdmFromDataset(source = "duckdb")
#'
#' cdm$warfarin <- conceptCohort(
#'   cdm = cdm,
#'   conceptSet =  list(warfarin = c(1310149L, 40163554L)),
#'   name = "warfarin"
#' )
#'
#' result <- phenotypeDiagnostics(
#'   cohort = cdm$warfarin,
#'   databaseDiagnostics = diag$databaseDiagnostics,
#'   codelistDiagnostics = diag$codelistDiagnostics,
#'   cohortDiagnostics = diag$cohortDiagnostics,
#'   populationDiagnostics = diag$populationDiagnostics
#' )
#' }
#'
newPhenotypeRSpecifications <- function(databaseDiagnostics = NULL,
                                        codelistDiagnostics = NULL,
                                        cohortDiagnostics = NULL,
                                        populationDiagnostics = NULL) {
  # TODO Discuss if default should be:
  # - NULL [Not run that diagnostic]
  # - list() [run with defaults]
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
#' @param path File path to a `.json` or `.xlsx` file that contains a valid
#' `phenotyper_specification` definition.
#'
#' @returns A `phenotyper_specification` object.
#'
#' @export
#'
#' @examples
#' library(PhenotypeR)
#'
#' diag <- newPhenotypeRSpecifications(
#'   codelistDiagnostics = list(cohortId = "warfarin", orphanCodeUse = TRUE)
#' )
#'
#' diag
#'
#' exportPhenotypeRSpecifications(
#'   x = diag,
#'   fileName = "my_parametrisation",
#'   path = tempdir(),
#'   type = "excel"
#' )
#'
#' diagImported <- importPhenotypeRSpecifications(
#'   path = file.path(tempdir(), "my_parametrisation.xlsx")
#' )
#'
#' diagImported
#'
#' # run Diagnostics from specifications
#' \donttest{
#' library(omock)
#' library(CohortConstructor)
#'
#' cdm <- mockCdmFromDataset(source = "duckdb")
#'
#' cdm$warfarin <- conceptCohort(
#'   cdm = cdm,
#'   conceptSet =  list(warfarin = c(1310149L, 40163554L)),
#'   name = "warfarin"
#' )
#'
#' result <- phenotypeDiagnostics(
#'   cohort = cdm$warfarin,
#'   databaseDiagnostics = diagImported$databaseDiagnostics,
#'   codelistDiagnostics = diagImported$codelistDiagnostics,
#'   cohortDiagnostics = diagImported$cohortDiagnostics,
#'   populationDiagnostics = diagImported$populationDiagnostics
#' )
#' }
#'
importPhenotypeRSpecifications <- function(path) {
  omopgenerics::assertCharacter(path, length = 1)

  if (endsWith(path, ".json")) {
    rlang::check_installed("jsonlite", "import in json format")
    x <- readPhenotypeRJson(path = path)
  } else if (endsWith(path, ".xlsx")) {
    rlang::check_installed("openxlsx")
    x <- readPhenotypeRExcel(path = path)
  } else {
    cli::cli_abort(c(x = "Only `.xlsx` or `.json` files can contain valid
                     definitions of {.cls phenotyper_specifications}"))
  }

  newPhenotypeRSpecifications(
    databaseDiagnostics = x$databaseDiagnostics,
    codelistDiagnostics = x$codelistDiagnostics,
    cohortDiagnostics = x$cohortDiagnostics,
    populationDiagnostics = x$populationDiagnostics
  )
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
#' library(PhenotypeR)
#'
#' diag <- newPhenotypeRSpecifications(
#'   codelistDiagnostics = list(cohortId = "warfarin", orphanCodeUse = TRUE)
#' )
#'
#' diag
#'
#' exportPhenotypeRSpecifications(
#'   x = diag,
#'   fileName = "my_parametrisation",
#'   path = tempdir(),
#'   type = "excel"
#' )
#'
#' diagImported <- importPhenotypeRSpecifications(
#'   path = file.path(tempdir(), "my_parametrisation.xlsx")
#' )
#'
#' diagImported
#'
#' # run Diagnostics from specifications
#' \donttest{
#' library(omock)
#' library(CohortConstructor)
#'
#' cdm <- mockCdmFromDataset(source = "duckdb")
#'
#' cdm$warfarin <- conceptCohort(
#'   cdm = cdm,
#'   conceptSet =  list(warfarin = c(1310149L, 40163554L)),
#'   name = "warfarin"
#' )
#'
#' result <- phenotypeDiagnostics(
#'   cohort = cdm$warfarin,
#'   databaseDiagnostics = diagImported$databaseDiagnostics,
#'   codelistDiagnostics = diagImported$codelistDiagnostics,
#'   cohortDiagnostics = diagImported$cohortDiagnostics,
#'   populationDiagnostics = diagImported$populationDiagnostics
#' )
#' }
#'
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
    writePhenotyepeRExcel(x = x, file = fileName)
  } else if (type == "json") {
    if (!endsWith(fileName, ".json")) {
      fileName <- paste0(fileName, ".json")
    }
    rlang::check_installed("jsonlite", "export in json format")
    writePhenotyepeRJson(x = x, file = fileName)
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


#' @importFrom dplyr as_tibble
#' @export
as_tibble.phenotyper_specifications <- function(x, ...) {
  cohortIds <- x |>
    purrr::list_flatten() |>
    purrr::map("cohortId") |>
    purrr::list_c(ptype = character()) |>
    unique() |>
    sort()

  if (length(cohortIds) == 0L && any(lengths(x) > 0L)) {
    cohortIds <- NA_character_
  }

  tib <- dplyr::tibble(cohortId = cohortIds)

  cols <- PhenotypeRDiagnosticsSpecs$args
  type <- PhenotypeRDiagnosticsSpecs$argType
  diag <- PhenotypeRDiagnosticsSpecs$diagnostics

  for (dg in PhenotypeRDiagnostics) {
    lj <- x[[dg]] |>
      purrr::map(\(x) {
        if (is.null(x$cohortId)) {
          x$cohortId <- cohortIds
        }
        if ("populationDateRange" %in% names(x)) {
          x$populationDateRange <- rangeToCharacter(x$populationDateRange)
        }
        dplyr::as_tibble(x)
      }) |>
      dplyr::bind_rows()

    cols_diag <- cols[diag %in% c("id", dg)]

    # add missing columns
    missingCols <- cols_diag[!cols_diag %in% colnames(lj)]
    if (length(missingCols) > 0) {
      q <- rep("NA", length(missingCols)) |>
        rlang::set_names(missingCols) |>
        rlang::parse_exprs()
      lj <- lj |>
        dplyr::mutate(!!!q)
    }
    lj <- lj |>
      dplyr::mutate(cohortId = as.character(.data$cohortId))

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
    x[nm] <- list(validateDiagnosticsInput(x[[nm]], nm, call = call))
  }

  return(x)
}
readPhenotypeRExcel <- function(path) {
  cols <- PhenotypeRDiagnosticsSpecs$args
  type <- PhenotypeRDiagnosticsSpecs$argType
  diag <- PhenotypeRDiagnosticsSpecs$diagnostics

  nArgs <- length(cols)

  # to suppress empty worksheets warning
  x <- withCallingHandlers(
    openxlsx::read.xlsx(
      xlsxFile = path,
      sheet = "Specifications",
      startRow = 3,
      cols = seq_len(nArgs),
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
    x <- rep(list(NULL), length(PhenotypeRDiagnostics)) |>
      rlang::set_names(PhenotypeRDiagnostics)
    return(x)
  }

  # The export sheet leaves its first column blank for workbook layout.
  if (ncol(x) == nArgs) {
    names(x) <- paste0("X", seq_len(nArgs))
  }

  # fill empty columns
  Nmissing <- nArgs - ncol(x)
  if (Nmissing > 0) {
    x[paste0("X", (ncol(x) + 1):nArgs)] <- NA
  }

  rn <- rlang::set_names(paste0("X", seq_len(nArgs)), cols)

  # format list
  x <- dplyr::as_tibble(x) |>
    dplyr::select(dplyr::all_of(rn)) |>
    dplyr::mutate(
      dplyr::across(dplyr::all_of(cols[type == "character"]), as.character),
      dplyr::across(dplyr::all_of(cols[type == "numeric"]), as.numeric),
      dplyr::across(dplyr::all_of(cols[type == "logical"]), as.logical)
    )

  # create diagnostics
  phenotypeRSpecifications <- list()
  for (dg in PhenotypeRDiagnostics) {
    diagnosticCols <- cols[diag == dg]
    # identify diagnostics parametrisation
    configurations <- x |>
      dplyr::filter(dplyr::if_any(dplyr::all_of(diagnosticCols), \(value) !is.na(value))) |>
      dplyr::select("cohortId", dplyr::all_of(diagnosticCols)) |>
      dplyr::group_split(dplyr::across(!"cohortId")) |>
      purrr::map(\(diag_group) {
        diag_group |>
          purrr::imap(\(x, nm) {
            x <- unique(x)
            if (nm == "populationDateRange" && !all(is.na(x))) {
              x <- characterToRange(x)
            }
            return(x)
          }) |>
          purrr::keep(\(x) !all(is.na(x)))
      })
    if (length(configurations) == 0) {
      configurations <- NULL
    }
    phenotypeRSpecifications[dg] <- list(configurations)
  }

  return(phenotypeRSpecifications)
}
readPhenotypeRJson <- function(path) {
  x <- jsonlite::read_json(path = path, simplifyVector = FALSE)
  x <- purrr::map(x, \(configurations) {
    if (length(configurations) == 0L) {
      return(NULL)
    }
    purrr::map(configurations, \(configuration) {
      purrr::imap(configuration, \(value, nm) {
        if (nm == "populationDateRange") {
          characterToRange(value)
        } else {
          unlist(value, recursive = TRUE, use.names = FALSE)
        }
      })
    })
  })
  return(x)
}
writePhenotyepeRExcel <- function(x, file) {
  # add instructions
  wb <- openxlsx::loadWorkbook(
    file = system.file("Instructions.xlsx", package = "PhenotypeR")
  )
  # add data to the Specifications sheet
  openxlsx::writeData(
    wb = wb,
    sheet = "Specifications",
    x = dplyr::as_tibble(x),
    colNames = FALSE,
    rowNames = FALSE,
    startCol = 1,
    startRow = 3
  )
  openxlsx::saveWorkbook(
    wb = wb,
    file = file,
    overwrite = TRUE
  )
}
writePhenotyepeRJson <- function(x, file) {
  # safely parse date ranges
  x <- unclass(x)
  if (!is.null(x$populationDiagnostics)) {
    x$populationDiagnostics <- x$populationDiagnostics |>
      purrr::map(\(conf) {
        if ("populationDateRange" %in% names(conf)) {
          conf$populationDateRange <- rangeToCharacter(conf$populationDateRange)
        }
        conf
      })
  }
  jsonlite::write_json(
    x = x,
    path = file,
    pretty = TRUE,
    auto_unbox = TRUE
  )
}
characterToRange <- function(x) {
  msg <- c(x = "Date range not correctly formatted, please use: YYYY-MM-DD to YYYY-MM-DD. Use NA for open end points.")
  x <- stringr::str_squish(x)
  if (!grepl("to", x) && nzchar(x)) {
    cli::cli_abort(msg)
  }
  x <- stringr::str_split(x, pattern = "to", n = 2)[[1]] |>
    purrr::map_chr(stringr::str_squish)
  dates <- as.Date(c(x, rep("NA", 2 - length(x))), format = "%Y-%m-%d")
  if ((is.na(dates[1]) & nzchar(x[1]) & !is.na(x[1]) & !identical(x[1], "NA")) |
      (is.na(dates[2]) & nzchar(x[2]) & !is.na(x[2]) & !identical(x[2], "NA"))) {
    cli::cli_abort(msg)
  }
  return(dates)
}
rangeToCharacter <- function(x) {
  paste(ifelse(is.na(x), "NA", format(x, "%Y-%m-%d")), collapse = " to ")
}
