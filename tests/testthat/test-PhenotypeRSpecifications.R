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
    as.Date(c(NA, "2020-12-31"))
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
