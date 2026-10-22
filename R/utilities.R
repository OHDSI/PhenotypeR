hasRows <- function(tbl){
  (tbl |>
    utils::head(1) |>
    dplyr::tally() |>
    dplyr::pull("n")) >= 1
}

validateDiagnosticsInput <- function(x, diagnostics, cohort, call = parent.frame()) {
  # validation of cohortId
  # to avoid evaluation
  x <- rlang::enquo(x)
  expression <- rlang::quo_get_expr(x)

  # check that input is a list
  if (rlang::is_call(expression) &&
      (rlang::call_name(expression) == "list" ||
       identical(expression[[1]], quote(base::list)))) {

    # find cohortId argument
    expression_environment <- rlang::quo_get_env(x)
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
      x <- rlang::eval_tidy(safe_expression, env = expression_environment)
      # validate cohortId
      x$cohortId <- rlang::inject(
        omopgenerics::validateCohortIdArgument(
          !!rlang::new_quosure(cohort_id_expression, expression_environment),
          cohort = cohort,
          call = call
        )
      )
    } else {
      x <- rlang::eval_tidy(x)
    }
  } else {
    x <- rlang::eval_tidy(x)
  }

  omopgenerics::assertList(x, null = TRUE, call = call, nm = diagnostics)

  if (is.null(x)) {
    return(x)
  }

  availableArguments <- paste0("PhenotypeR::", diagnostics) |>
    rlang::parse_expr() |>
    rlang::eval_tidy() |>
    formals() |>
    purrr::discard(rlang::is_missing)

  if (!length(x) == 0) {
    msg <- paste0(
      diagnostics, " elements must be named only with optional arguments from the ",
      diagnostics, " function.\nIf you don't want to run ", diagnostics,
      ", set `", diagnostics, " = NULL`."
    )
    omopgenerics::assertChoice(
      names(x),
      choices = names(availableArguments),
      unique = TRUE,
      call = call,
      msg = msg
    )
  }

  # add not populated elements
  c(x, availableArguments[!names(availableArguments) %in% names(x)])
}
