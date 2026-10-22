
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

constructPhenotypeRSpecifications <- function(x) {
  structure(.Data = x, class = "phenotyper_specifications")
}
validatePhenotypeRSpecifications <- function(x, call = parent.frame()) {
  omopgenerics::assertClass(x, class = "phenotyper_specifications", call = call)

  omopgenerics::assertList(x, call = call)

  # add missing labels
  nms <- c("databaseDiagnostics", "codelistDiagnostics", "cohortDiagnostics",
           "populationDiagnostics")
  for (nm in nms) {
    if (!nm %in% names(x)) {
      x[[nm]] <- list()
    }
  }

  # remove extra labels
  extra <- names(x)[!names(x) %in% nms]
}
