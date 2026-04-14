hasRows <- function(tbl){
  (tbl |>
    utils::head(1) |>
    dplyr::tally() |>
    dplyr::pull("n")) >= 1
}

checkDatabaseDiagnosticsInput <- function(databaseDiagnostics, call = parent.frame()) {
  omopgenerics::assertList(databaseDiagnostics, null = TRUE, call = call)

  if(is.null(databaseDiagnostics)) {
    return(databaseDiagnostics)
  }

  availableArguments <- formals(PhenotypeR::databaseDiagnostics) |>
    purrr::discard(rlang::is_missing)

  if(length(names(databaseDiagnostics))>0){
  omopgenerics::assertChoice(names(databaseDiagnostics),
                               choices = names(availableArguments),
                               unique = TRUE,
                               call = call,
                               msg = "databaseDiagnostics elements must be named only with optional arguments from the databaseDiagnostics function.
                               If you don't want to run databaseDiagnostics, set `databaseDiagnostics = NULL`.")
  }

  databaseDiagnostics <- c(databaseDiagnostics,
    availableArguments[!names(availableArguments) %in% names(databaseDiagnostics)])

  return(databaseDiagnostics)
}

checkCodelistDiagnosticsInput <- function(codelistDiagnostics, call = parent.frame()) {

  omopgenerics::assertList(codelistDiagnostics, null = TRUE, call = call)

  if(is.null(codelistDiagnostics)) {
    return(codelistDiagnostics)
  }

  availableArguments <- formals(PhenotypeR::codelistDiagnostics) |>
   purrr::discard(rlang::is_missing)

  if(!length(codelistDiagnostics) == 0) {
    omopgenerics::assertChoice(names(codelistDiagnostics),
                               choices = names(availableArguments),
                               unique = TRUE,
                               call = call,
                               msg = "codelistDiagnostics elements must be named only with optional arguments from the codelistDiagnostics function.
                               If you don't want to run codelistDiagnostics, set `codelistDiagnostics = NULL`.")

  }

  codelistDiagnostics <- c(codelistDiagnostics,
                           availableArguments[!names(availableArguments) %in% names(codelistDiagnostics)])

  return(codelistDiagnostics)
}

checkCohortDiagnosticsInput <- function(cohortDiagnostics, call = parent.frame()) {

  omopgenerics::assertList(cohortDiagnostics, null = TRUE, call = call)

  if(is.null(cohortDiagnostics)) {
    return(cohortDiagnostics)
  }

  availableArguments <- formals(PhenotypeR::cohortDiagnostics) |>
    purrr::discard(rlang::is_missing)

  if(!length(cohortDiagnostics) == 0) {
    omopgenerics::assertChoice(names(cohortDiagnostics),
                               choices = names(availableArguments),
                               unique = TRUE,
                               call = call,
                               msg = "cohortDiagnostics elements must be named only with optional arguments from the cohortDiagnostics function.
                               If you don't want to run cohortDiagnostics, set `cohortDiagnostics = NULL`.")

  }

  cohortDiagnostics <- c(cohortDiagnostics,
                         availableArguments[!names(availableArguments) %in% names(cohortDiagnostics)])

  return(cohortDiagnostics)

}

checkPopulationDiagnosticsInput <- function(populationDiagnostics, call = parent.frame()) {

  omopgenerics::assertList(populationDiagnostics, null = TRUE, call = call)

  if(is.null(populationDiagnostics)) {
    return(populationDiagnostics)
  }

  availableArguments <- formals(PhenotypeR::populationDiagnostics) |>
    purrr::discard(rlang::is_missing)

  if(!length(populationDiagnostics) == 0) {
    omopgenerics::assertChoice(names(populationDiagnostics),
                               choices = names(availableArguments),
                               unique = TRUE,
                               call = call,
                               msg = "populationDiagnostics elements must be named only with optional arguments from the populationDiagnostics function.
                               If you don't want to run populationDiagnostics, set `populationDiagnostics = NULL`.")

  }

  populationDiagnostics <- c(populationDiagnostics,
                         availableArguments[!names(availableArguments) %in% names(populationDiagnostics)])

  return(populationDiagnostics)

}





