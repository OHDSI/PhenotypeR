hasRows <- function(tbl){
  (tbl |>
    utils::head(1) |>
    dplyr::tally() |>
    dplyr::pull("n")) >= 1
}

validateDiagnosticsCohortId <- function(diagnostics, cohort, call = parent.frame()) {
  # to avoid evaluation
  diagnostics <- rlang::enquo(diagnostics)
  expression <- rlang::quo_get_expr(diagnostics)

  # check that input is a list
  if (rlang::is_call(expression) &&
      (rlang::call_name(expression) == "list" ||
         identical(expression[[1]], quote(base::list)))) {

    # find cohortId argument
    expression_environment <- rlang::quo_get_env(diagnostics)
    arguments <- rlang::call_args(expression)
    argument_names <- names(arguments)
    cohort_id_position <- which(argument_names == "cohortId")

    # evaluate safely cohortId if present
    if (length(cohort_id_position) == 1) {
      # change cohortId for NULL
      cohort_id_expression <- arguments[[cohort_id_position]]
      arguments[cohort_id_position] <- list(quote(NULL))
      names(arguments) <- argument_names
      safe_expression <- rlang::call2("list", !!!arguments)
      diagnostics <- rlang::eval_tidy(safe_expression, env = expression_environment)
      # validate cohortId
      diagnostics$cohortId <- rlang::inject(
        omopgenerics::validateCohortIdArgument(
          !!rlang::new_quosure(cohort_id_expression, expression_environment),
          cohort = cohort,
          call = call
        )
      )
      return(diagnostics)
    }
  }

  return(rlang::eval_tidy(diagnostics))
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
