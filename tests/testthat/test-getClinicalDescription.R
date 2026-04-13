test_that("example works", {

  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("ellmer")

  chat <- ellmer::chat("google_gemini")

  # specific diagnosis
  expect_no_error(getClinicalDescription(chat, "prostate cancer", outputDir = tempdir()))
  expect_no_error(getClinicalDescription(chat, "lung cancer", outputDir = tempdir()))
  # can pass multiple - will get one description for each
  expect_no_error(getClinicalDescription(chat, c("asthma", "copd"), outputDir = tempdir()))

})
