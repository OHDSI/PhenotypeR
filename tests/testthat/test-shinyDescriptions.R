test_that("no error", {
  skip_on_cran()
  expect_no_error(
    shinyDescriptions(directory = tempdir(),
                      open = FALSE)
  )
})
