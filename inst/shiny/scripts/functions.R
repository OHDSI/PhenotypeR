prepareResult <- function(result, resultList) {
  purrr::map(resultList, \(x) filterResult(result, x))
}
filterResult <- function(result, filt) {
  nms <- names(filt)
  for (nm in nms) {
    q <- paste0(".data$", nm, " %in% filt[[\"", nm, "\"]]") |>
      rlang::parse_exprs() |>
      rlang::eval_tidy()
    result <- omopgenerics::filterSettings(result, !!!q)
  }
  return(result)
}
getValues <- function(result, resultList) {
  resultList |>
    purrr::imap(\(x, nm) {
      res <- filterResult(result, x)
      values <- res |>
        dplyr::select(!c("estimate_type", "estimate_value")) |>
        dplyr::distinct() |>
        omopgenerics::splitAll() |>
        dplyr::select(!"result_id") |>
        as.list() |>
        purrr::map(\(x) sort(unique(x)))
      valuesSettings <- omopgenerics::settings(res) |>
        dplyr::select(!dplyr::any_of(c(
          "result_id", "result_type", "package_name", "package_version",
          "group", "strata", "additional", "min_cell_count"
        ))) |>
        as.list() |>
        purrr::map(\(x) sort(unique(x[!is.na(x)]))) |>
        purrr::compact()
      values <- c(values, valuesSettings)
      names(values) <- paste0(nm, "_", names(values))
      values
    }) |>
    purrr::flatten()
}

filterValues <- function(values, prefix, sufix_to_include){
  values_subset <- values[stringr::str_detect(names(values), prefix)]
  values_subset <- values_subset[stringr::str_detect(names(values_subset),
                                                     paste(sufix_to_include,collapse = "|"))]

  values <- append(values[!stringr::str_detect(names(values), prefix)],
                   values_subset)
  return(values)
}


tidyData <- function(result) {
  # initial checks
  result <- omopgenerics::validateResultArgument(result)

  # correct settings if it has not been done before
  sets <- omopgenerics::settings(result)
  if (!all(c("group", "strata", "additional") %in% colnames(sets))) {
    sets <- result |>
      correctSettings() |>
      omopgenerics::settings()
  }
  sets <- removeSettingsNa(sets)
  attr(result, "settings") <- sets

  # get grouping columns
  groupingCols <- c(
    getCols(sets$group), getCols(sets$strata), getCols(sets$additional))

  # add settings and grouping
  result <- result |>
    visOmopResults::addSettings() |>
    visOmopResults::splitAll()

  # add missing grouping
  notPresent <- groupingCols[!groupingCols %in% colnames(result)]
  if (length(notPresent) > 0) {
    for (col in notPresent) {
      result <- result |>
        dplyr::mutate(!!col := "overall")
    }
  }

  # grouping will be located before variable
  result <- result |>
    dplyr::relocate(dplyr::all_of(groupingCols), .before = "variable_name") |>
    dplyr::select(!"result_id")

  return(result)
}

removeSettingsNa <- function(x) {
  cols <- x |>
    purrr::map(unique)
  cols <- names(cols)[is.na(cols)]
  x |>
    dplyr::select(!dplyr::all_of(cols))
}

yesno <- function(msg, .envir = parent.frame()) {
  yeses <- c("Yes", "Definitely", "For sure", "Yup", "Yeah", "Of course", "Absolutely")
  nos <- c("No way", "Not yet", "I forget", "No", "Nope", "Uhhhh... Maybe?")

  cli::cli_inform(msg, .envir = .envir)
  qs <- c(sample(yeses, 1), sample(nos, 2))
  rand <- sample(length(qs))

  utils::menu(qs[rand]) != which(rand == 1)
}
