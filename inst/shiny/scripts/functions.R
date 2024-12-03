

getChoices <- function(result, flatten = FALSE) {
  # initial checks
  result <- omopgenerics::validateResultArgument(result)
  omopgenerics::assertLogical(flatten, length = 1)

  # get choices
  cli::cli_inform("Get possible settings")
  settings <- getPossibleSettings(result)
  cli::cli_inform("Get possible groupings")
  grouping <-getPossibleGrouping(result)
  cli::cli_inform("Get possible variables")
  variables <- getPossibleVariables(result)
  sets <- omopgenerics::settings(result)
  if (!all(c("group", "strata", "additional") %in% colnames(sets))) {
    cli::cli_inform("Correcting settings")
    sets <- result |>
      correctSettings() |>
      omopgenerics::settings()
  }

  # tidy columns
  cli::cli_inform("Tidying columns")
  tidyCols <- sets |>
    dplyr::group_by(.data$result_type) |>
    dplyr::group_split()
  names(tidyCols) <- purrr::map_chr(tidyCols, \(x) unique(x$result_type))
  tidyCols <- tidyCols |>
    purrr::map(\(x) {
      setCols <- x |>
        dplyr::select(!dplyr::any_of(c(
          "result_id", "result_type", "package_name", "package_version",
          "group", "strata", "additional", "min_cell_count"
        ))) |>
        purrr::map(unique)
      setCols <- names(setCols)[!is.na(setCols)]
      c("cdm_name", getCols(x$group), getCols(x$strata), getCols(x$additional), setCols)
    })

  if (flatten) {
    cli::cli_inform("Flattening")
    names(tidyCols) <- paste0(names(tidyCols), "_tidy_columns")
    choices <- c(
      correctNames(settings, "settings"),
      correctNames(grouping, "grouping"),
      correctNames(variables),
      tidyCols
    )
  } else {
    choices <- unique(c(names(settings), names(grouping), names(variables))) |>
      purrr::set_names() |>
      purrr::map(\(x) list(
        settings = settings[[x]],
        grouping = grouping[[x]],
        variable_name = variables[[x]]$variable_name,
        estimate_name = variables[[x]]$estimate_name,
        tidy_columns = tidyCols[[x]]
      ))
  }
  cli::cli_inform("Found all choices")
  return(choices)
}
getPossibleSettings <- function(result) {
  omopgenerics::settings(result) |>
    dplyr::select(!dplyr::any_of(c(
      "result_id", "package_name", "package_version", "min_cell_count"))) |>
    getPossibilities()
}
getPossibleGrouping <- function(result) {
  result |>
    omopgenerics::addSettings(
      settingsColumn = settingsColumns(result, metadata = TRUE)
    ) |>
    dplyr::select(c(
      "result_type", "cdm_name", "group_name", "group_level", "strata_name",
      "strata_level", "additional_name", "additional_level")) |>
    dplyr::distinct() |>
    getPossibilities(split = TRUE)
}
getPossibleVariables <- function(result) {
  result |>
    omopgenerics::addSettings(
      settingsColumn = settingsColumns(result, metadata = TRUE)) |>
    dplyr::select(c("result_type", "variable_name", "estimate_name")) |>
    dplyr::distinct() |>
    getPossibilities()
}
getPossibilities <- function(x, split = FALSE) {
  x <- x |>
    dplyr::group_by(.data$result_type) |>
    dplyr::group_split() |>
    as.list()
  names(x) <- purrr::map_chr(x, \(x) unique(x$result_type))
  uniquePos <- function(xx) {
    xx <- xx |>
      unique() |>
      as.character() |>
      sort() # To remove when the output is constant and always equal
    xx[!is.na(xx)]
  }
  getPos <- function(xx, split = FALSE) {
    xx <- xx |>
      dplyr::select(!"result_type")
    if (split) xx <- visOmopResults::splitAll(xx)
    xx |>
      as.list() |>
      purrr::map(uniquePos) |>
      vctrs::list_drop_empty()
  }
  x <- x |>
    purrr::map(getPos, split = split)
  return(x)
}
correctNames <- function(x, prefix = "") {
  if (prefix == "") {
    sub <- "_"
  } else {
    sub <- paste0("_", prefix, "_")
  }
  x <- unlist(x, recursive = FALSE)
  names(x) <- gsub(".", sub, names(x), fixed = TRUE)
  return(x)
}
getCols <- function(x) {
  cols <- x |>
    unique() |>
    stringr::str_split(pattern = " &&& ") |>
    unlist() |>
    unique()
  cols <- cols[!is.na(cols)]
  return(cols)
}

correctSettings <- function(result) {
  # check input
  result <- omopgenerics::validateResultArgument(result)

  set <- omopgenerics::settings(result)

  cols <- c("group", "strata", "additional")
  cols <- cols[cols %in% colnames(set)]
  if (length(cols) > 0) {
    cli::cli_warn(c("!" = "{.var {cols}} will be overwritten in settings."))
  }

  # obtain group, strata, and additional at
  x <- result |>
    dplyr::select("result_id", "strata_name", "group_name", "additional_name") |>
    dplyr::distinct()
  group <- rep("", nrow(set))
  strata <- rep("", nrow(set))
  additional <- rep("", nrow(set))
  for (k in seq_len(nrow(set))) {
    cli::cli_inform("-- Correcting {k} of {nrow(set)}")
    xk <- x |>
      dplyr::filter(.data$result_id == .env$set$result_id[k])
    group[k] <- visOmopResults::groupColumns(xk) |> joinCols()
    strata[k] <- visOmopResults::strataColumns(xk) |> joinCols()
    additional[k] <- visOmopResults::additionalColumns(xk) |> joinCols()
  }

  # correct settings
  set <- set |>
    dplyr::mutate(
      group = .env$group, strata = .env$strata, additional = .env$additional
    )

  return(omopgenerics::newSummarisedResult(result, settings = set))
}
joinCols <- function(x) {
  if (length(x) == 0) return(NA_character_)
  stringr::str_flatten(x, collapse = " &&& ")
}

filterData <- function(result,
                       resultType,
                       input) {
  # initial check
  result <- omopgenerics::validateResultArgument(result)
  omopgenerics::assertCharacter(resultType)

  # filter result type
  result <- result |>
    visOmopResults::filterSettings(.data$result_type == .env$resultType)
  if (nrow(result) == 0) return(emptySummarisedResult())

  if (length(input) == 0) {
    inputs <- character()
  } else {
    inputs <- names(input)
  }

  # subset to inputs of interest
  inputs <- inputs[startsWith(inputs, resultType)]

  # filter settings
  set <- omopgenerics::settings(result)
  setPrefix <- paste0(resultType, "_settings_")
  toFilter <- inputs[startsWith(inputs, setPrefix)]
  nms <- substr(toFilter, nchar(setPrefix)+1, nchar(toFilter))
  for (nm in nms) {
    if (nm %in% colnames(set)) {
      set <- set |>
        dplyr::filter(as.character(.data[[nm]]) %in% input[[paste0(setPrefix, nm)]])
    }
  }
  result <- result |>
    dplyr::filter(.data$result_id %in% set$result_id)

  if (nrow(result) == 0) return(emptySummarisedResult())

  # filter grouping
  cols <- c(
    "cdm_name", "group_name", "group_level", "strata_name", "strata_level",
    "additional_name", "additional_level")
  groupCols <- visOmopResults::groupColumns(result)
  strataCols <- visOmopResults::strataColumns(result)
  additionalCols <- visOmopResults::additionalColumns(result)
  group <- result |>
    dplyr::select(dplyr::all_of(cols)) |>
    dplyr::distinct() |>
    visOmopResults::splitAll()
  groupPrefix <- paste0(resultType, "_grouping_")
  toFilter <- inputs[startsWith(inputs, groupPrefix)]
  nms <- substr(toFilter, nchar(groupPrefix)+1, nchar(toFilter))
  for (nm in nms) {
    if (nm %in% colnames(group)) {
      group <- group |>
        dplyr::filter(.data[[nm]] %in% input[[paste0(groupPrefix, nm)]])
    }
  }
  result <- result |>
    dplyr::inner_join(
      group |>
        visOmopResults::uniteGroup(cols = groupCols) |>
        visOmopResults::uniteStrata(cols = strataCols) |>
        visOmopResults::uniteAdditional(cols = additionalCols),
      by = cols
    )

  # filter variables and estimates
  nms <- c("variable_name", "estimate_name")
  nms <- nms[paste0(resultType, "_", nms) %in% inputs]
  for (nm in nms) {
    result <- result |>
      dplyr::filter(.data[[nm]] %in% input[[paste0(resultType, "_", nm)]])
  }

  # return a summarised_result
  result <- result |>
    omopgenerics::newSummarisedResult(settings = set)

  return(result)
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
