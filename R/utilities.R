hasRows <- function(tbl){
  (tbl |>
    utils::head(1) |>
    dplyr::tally() |>
    dplyr::pull("n")) >= 1
}

validateDiagnosticsInput <- function(x, diagnostics, cohort, call = parent.frame()) {
  x <- rlang::enquo(x)
  expression_environment <- rlang::quo_get_env(x)

  # Resolve cohortId expressions
  resolveCohortIds <- function(expression) {
    if (!rlang::is_call(expression) ||
        !(identical(expression[[1]], quote(list)) ||
          identical(expression[[1]], quote(base::list)))) {
      return(expression)
    }

    arguments <- rlang::call_args(expression)
    argument_names <- names(arguments)
    for (i in seq_along(arguments)) {
      if (!is.null(argument_names) && identical(argument_names[[i]], "cohortId")) {
        cohortId <- rlang::inject(
          omopgenerics::validateCohortIdArgument(
            !!rlang::new_quosure(arguments[[i]], expression_environment),
            cohort = cohort,
            call = call
          )
        )
        arguments[i] <- list(cohortId)
      } else {
        arguments[i] <- list(resolveCohortIds(arguments[[i]]))
      }
    }
    rlang::call2("list", !!!arguments)
  }

  expression <- resolveCohortIds(rlang::quo_get_expr(x))
  x <- rlang::eval_tidy(expression, env = expression_environment)

  omopgenerics::assertList(x, null = TRUE, call = call, nm = diagnostics)

  if (is.null(x)) {
    return(x)
  }

  # A named list describes one configuration -> wrapped to handle multiple
  if (length(x) == 0 || !is.null(names(x))) {
    x <- list(x)
  }

  availableArguments <- paste0("PhenotypeR::", diagnostics) |>
    rlang::parse_expr() |>
    rlang::eval_tidy() |>
    formals() |>
    purrr::discard(rlang::is_missing)

  nms <- names(availableArguments)

  msg <- paste0(
    diagnostics, " elements must be named only with arguments from the ",
    diagnostics, " function.\nIf you don't want to run ", diagnostics,
    ", set `", diagnostics, " = NULL`."
  )

  # add defaults that are missing or complain if extra arguments are provided
  purrr::map(x, \(conf) {
    omopgenerics::assertList(conf, call = call, nm = diagnostics)
    omopgenerics::assertChoice(
      names(conf), choices = nms, unique = TRUE, null = TRUE, call = call,
      msg = msg
    )
    c(conf, availableArguments[!names(availableArguments) %in% names(conf)])
  })
}
