test_that("test summariseDrugExposure", {
  skip("needs update for new functions")

  cdm <- omock::mockCdmFromDataset(source = "duckdb")

  expect_error(summariseDrugExposureDiagnostics(cdm = cdm))

  conceptSet <- CodelistGenerator::getDrugIngredientCodes(
    cdm = cdm,
    name = "acetaminophen",
    nameStyle = "{concept_name}"
  )
  expect_warning(expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    conceptSet = conceptSet,
    checks = getAllCheckOptions()
  )))
  expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    conceptSet = conceptSet,
    ingredient = 1125315,
    checks = getAllCheckOptions()
  ))

  expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    ingredient = 1125315,
    checks = getAllCheckOptions()
  ))

  expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    ingredient = 1125315,
    dateRange = NULL,
    checks = getAllCheckOptions()
  ))

  conceptSet <- CodelistGenerator::getDrugIngredientCodes(
    cdm = cdm,
    name = c("acetaminophen", "alendronate"),
    nameStyle = "{concept_name}"
  )

  expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    conceptSet = conceptSet,
    ingredient = c(1125315),
    dateRange = NULL,
    checks = getAllCheckOptions()
  ))

  expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    conceptSet = conceptSet,
    ingredient = c(1125315, 1557272),
    dateRange = NULL,
    checks = getAllCheckOptions()
  ))

  # account for sorting in validation
  codelist <- list(
    concept1 = conceptSet$acetaminophen,
    concept2 = conceptSet$alendronate
  )
  expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    conceptSet = codelist,
    ingredient = c(1125315, 1557272),
    dateRange = NULL,
    checks = getAllCheckOptions()
  ))
  # order
  x <- result |>
    omopgenerics::filterSettings(check == "dose") |>
    omopgenerics::tidy() |>
    dplyr::distinct(.data$codelist_name, .data$ingredient_name)
  expect_identical(x, dplyr::tibble(
    codelist_name = c("concept1", "concept2"),
    ingredient_name = c("Acetaminophen", "Alendronate")
  ))

  # account for sorting in validation
  codelist <- list(
    concept2 = conceptSet$acetaminophen,
    concept1 = conceptSet$alendronate
  )
  expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    conceptSet = codelist,
    ingredient = c(1125315, 1557272),
    dateRange = NULL,
    checks = getAllCheckOptions()
  ))
  # order
  x <- result |>
    omopgenerics::filterSettings(check == "dose") |>
    omopgenerics::tidy() |>
    dplyr::distinct(.data$codelist_name, .data$ingredient_name)
  expect_identical(x, dplyr::tibble(
    codelist_name = c("concept1", "concept2"),
    ingredient_name = c("Alendronate", "Acetaminophen")
  ))

  expect_no_error(result <- summariseDrugExposureDiagnostics(
    cdm = cdm,
    ingredient = 1125315,
    checks = getAllCheckOptions(),
    byConcept = TRUE
  ))

  CDMConnector::cdmDisconnect(cdm = cdm)
})
