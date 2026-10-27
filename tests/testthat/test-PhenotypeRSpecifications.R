test_that("specifications preserve diagnostic arguments and parse population dates", {
  dates <- as.Date(c("2020-01-01", "2020-12-31"))
  x <- newPhenotypeRSpecifications(
    populationDiagnostics = list(
      cohortId = c("cohort_1", "cohort_2"),
      populationDateRange = dates
    )
  )

  expect_s3_class(x, "phenotyper_specifications")
  expect_identical(names(x), c(
    "databaseDiagnostics", "codelistDiagnostics",
    "cohortDiagnostics", "populationDiagnostics"
  ))
  expect_identical(x$populationDiagnostics[[1]]$populationDateRange, dates)

  tab <- tibble::as_tibble(x)
  expect_identical(tab$cohortId, c("cohort_1", "cohort_2"))
  expect_identical(unique(tab$incidence), TRUE)
  expect_identical(tab$populationDateRange, rep("2020-01-01 to 2020-12-31", 2))
})

test_that("population date range parser accepts open endpoints and rejects unsafe input", {
  expect_identical(
    characterToRange("NA to 2020-12-31"),
    as.Date(c(NA, "2020-12-31"))
  )
  expect_identical(
    characterToRange("2020-01-01 to NA"),
    as.Date(c("2020-01-01", NA))
  )
  expect_identical(
    characterToRange("NA to NA"),
    as.Date(c(NA, NA))
  )
  expect_identical(
    characterToRange(""),
    as.Date(c(NA, NA))
  )

  expect_error(characterToRange("2020/01/01 to 2020/12/31"))
  expect_error(characterToRange("2020-02-30 to 2020-12-31"))
  expect_error(characterToRange(c("2020-01-01")))

  marker <- tempfile()
  malicious <- paste0("system('touch ", marker, "')")
  expect_error(characterToRange(malicious))
  expect_false(file.exists(marker))
})

test_that("JSON specification export and import round-trip date ranges safely", {
  skip_if_not_installed("jsonlite")
  x <- newPhenotypeRSpecifications(
    databaseDiagnostics = list(personTableSummary = FALSE),
    populationDiagnostics = list(
      list(cohortId = c("cohort_1", "cohort_2"),
           populationDateRange = as.Date(c(NA, "2020-12-31"))),
      list(cohortId = "cohort_3")
    )
  )
  directory <- tempfile()
  dir.create(directory)

  exportPhenotypeRSpecifications(
    x, fileName = "specifications.json", path = directory, type = "json"
  )
  imported <- importPhenotypeRSpecifications(
    file.path(directory, "specifications.json")
  )
  json <- jsonlite::read_json(
    file.path(directory, "specifications.json"), simplifyVector = FALSE
  )

  expect_identical(
    json$populationDiagnostics[[1]]$populationDateRange,
    "NA to 2020-12-31"
  )
  expect_identical(names(imported), names(x))
  expect_identical(
    imported$databaseDiagnostics[[1]]$personTableSummary,
    FALSE
  )
  expect_identical(imported$populationDiagnostics[[1]]$cohortId,
                   c("cohort_1", "cohort_2"))
  expect_identical(imported$populationDiagnostics[[1]]$populationDateRange,
                   as.Date(c(NA, "2020-12-31")))
  expect_identical(imported$populationDiagnostics[[2]]$populationDateRange,
                   as.Date(c(NA, NA)))
  expect_identical(tibble::as_tibble(imported)$populationDateRange,
                   c("NA to 2020-12-31", "NA to 2020-12-31", "NA to NA"))
})

test_that("Excel specification export and import round-trip date ranges", {
  skip_if_not_installed("openxlsx")
  x <- newPhenotypeRSpecifications(
    populationDiagnostics = list(
      cohortId = "cohort_1",
      populationDateRange = as.Date(c("2020-01-01", NA))
    )
  )
  directory <- tempfile()
  dir.create(directory)

  exportPhenotypeRSpecifications(
    x, fileName = "specifications.xlsx", path = directory, type = "excel"
  )
  imported <- importPhenotypeRSpecifications(
    file.path(directory, "specifications.xlsx")
  )

  expect_identical(imported$populationDiagnostics[[1]]$populationDateRange,
                   as.Date(c("2020-01-01", NA)))
  expect_identical(tibble::as_tibble(imported)$populationDateRange,
                   "2020-01-01 to NA")
})

test_that("Import and export are the same", {
  diag <- newPhenotypeRSpecifications(
    codelistDiagnostics = list(
      cohortId = c("ibuprofen", "beta_blocker"),
      drugDiagnostics = TRUE
    )
  )

  dir <- tempdir()

  # export as excel
  file <- "specs.xlsx"
  exportPhenotypeRSpecifications(x = diag, fileName = file, path = dir, type = "excel")
  diagImported1 <- importPhenotypeRSpecifications(path = file.path(dir, file))
  for (dg in PhenotypeR:::PhenotypeRDiagnostics) {
    expect_identical(diag[[dg]], diagImported1[[dg]])
  }

  # export as json
  file <- "specs.json"
  exportPhenotypeRSpecifications(x = diag, fileName = file, path = dir, type = "json")
  diagImported2 <- importPhenotypeRSpecifications(path = file.path(dir, file))
  for (dg in PhenotypeR:::PhenotypeRDiagnostics) {
    expect_identical(diag[[dg]], diagImported2[[dg]])
  }

  skip_on_cran()
  cdm <- omock::mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
  cdm$my_cohort <- CohortConstructor::conceptCohort(
    cdm = cdm,
    conceptSet = list(ibuprofen = 1127433L, beta_blocker = 40481087L),
    name = "my_cohort"
  )
  # run code and compare results
  result1 <- phenotypeDiagnostics(
    cohort = cdm$my_cohort,
    databaseDiagnostics = NULL,
    codelistDiagnostics = list(
      cohortId = c("ibuprofen", "beta_blocker"),
      drugDiagnostics = TRUE
    ),
    cohortDiagnostics = NULL,
    populationDiagnostics = NULL
  )
  result2 <- phenotypeDiagnostics(
    cohort = cdm$my_cohort,
    databaseDiagnostics = diag$databaseDiagnostics,
    codelistDiagnostics = diag$codelistDiagnostics,
    cohortDiagnostics = diag$cohortDiagnostics,
    populationDiagnostics = diag$populationDiagnostics
  )
  result3 <- phenotypeDiagnostics(
    cohort = cdm$my_cohort,
    databaseDiagnostics = diagImported1$databaseDiagnostics,
    codelistDiagnostics = diagImported1$codelistDiagnostics,
    cohortDiagnostics = diagImported1$cohortDiagnostics,
    populationDiagnostics = diagImported1$populationDiagnostics
  )
  result4 <- phenotypeDiagnostics(
    cohort = cdm$my_cohort,
    databaseDiagnostics = diagImported2$databaseDiagnostics,
    codelistDiagnostics = diagImported2$codelistDiagnostics,
    cohortDiagnostics = diagImported2$cohortDiagnostics,
    populationDiagnostics = diagImported2$populationDiagnostics
  )

  # filter logs out
  result1 <- omopgenerics::filterSettings(result1, result_type != "summarise_log_file")
  result2 <- omopgenerics::filterSettings(result2, result_type != "summarise_log_file")
  result3 <- omopgenerics::filterSettings(result3, result_type != "summarise_log_file")
  result4 <- omopgenerics::filterSettings(result4, result_type != "summarise_log_file")

  # TODO probably this should not be needed!!
  attr(result1, 'settings')$subset <- NULL
  attr(result2, 'settings')$subset <- NULL
  attr(result3, 'settings')$subset <- NULL
  attr(result4, 'settings')$subset <- NULL

  expect_identical(result1, result2)
  expect_identical(result1, result3)
  expect_identical(result1, result4)
})

test_that("exports distinguish skipped diagnostics from enabled defaults", {
  for (x in list(
    newPhenotypeRSpecifications(),
    newPhenotypeRSpecifications(cohortDiagnostics = list())
  )) {
    for (type in c("excel", "json")) {
      file <- tempfile(fileext = if (type == "excel") ".xlsx" else ".json")
      exportPhenotypeRSpecifications(x, basename(file), dirname(file), type)
      expect_identical(importPhenotypeRSpecifications(file), x)
    }
  }
})

test_that("blank cells in a populated Excel block use defaults", {
  x <- newPhenotypeRSpecifications(
    populationDiagnostics = list(cohortId = "my_cohort")
  )
  row <- tibble::as_tibble(x)
  row[setdiff(names(row), c("cohortId", "incidence"))] <- NA
  file <- tempfile(fileext = ".xlsx")
  openxlsx::write.xlsx(
    row, file, sheetName = "Specifications", startRow = 3, colNames = FALSE
  )
  expect_identical(importPhenotypeRSpecifications(file), x)
})
