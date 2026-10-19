test_that("example works", {

  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("ellmer")

  chat <- ellmer::chat_ollama(
    model = "MedGemma:4b"
  )

  # specific diagnosis
  tmpDir <- file.path(tempdir(), omopgenerics::uniqueTableName())
  dir.create(tmpDir)
  expect_no_error(cd <- draftClinicalDescription(chat,
                                                 "prostate cancer"))
  expect_no_error(exportClinicalDescription(clinicalDescription = cd,
                                            outputDir = tmpDir))
  expect_no_error(cd2 <- importClinicalDescription(tmpDir))
  expect_true(!is.null(cd2$`prostate cancer`))
  expect_identical(cd, cd2)
  unlink(tmpDir)

  tmpDir <- file.path(tempdir(), omopgenerics::uniqueTableName())
  dir.create(tmpDir)
  # can pass multiple - will get one description for each
  expect_no_error(cd <- draftClinicalDescription(chat, c("asthma", "copd")))
  expect_no_error(exportClinicalDescription(clinicalDescription = cd,
                                            outputDir = tmpDir))
  expect_no_error(descriptions <- importClinicalDescription(tmpDir))
  expect_true(!is.null(descriptions$copd))
  expect_identical(cd, descriptions)

})
