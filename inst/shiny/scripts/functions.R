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


# reactablefmtr no longer on cran
reactablefmtr_add_title <- function(table = NULL,
                      title = NULL,
                      align = "left",
                      font_color = "#000",
                      font_size = 32,
                      font_style = "normal",
                      font_weight = "bold",
                      text_decoration = NULL,
                      text_transform = NULL,
                      letter_spacing = NULL,
                      word_spacing = NULL,
                      text_shadow = NULL,
                      background_color = "#FFFFFF",
                      margin = NULL) {

  '%notin%' <- Negate('%in%')

  if (align %notin% c("left", "right", "center") == TRUE) {

    stop("align must be either 'left', 'right', or 'center'")
  }

  if (font_style %notin% c("normal", "italic") == TRUE) {

    stop("font_style must be either 'normal' or 'italic'")
  }

  if (font_weight %notin% c("normal", "bold") == TRUE) {

    stop("font_weight must be either 'normal' or 'bold'")
  }

  if (!is.null(text_transform) && text_transform %notin% c("uppercase", "lowercase", "capitalize") == TRUE) {

    stop("text_transform must be either 'uppercase', 'lowercase', or 'capitalize'")
  }

  if (!is.null(margin) && length(margin)<4) {

    stop("please provide margin dimensions within `margin()`. Ex. margin = margin(t=10)")
  }

  if (is.null(margin)) {

    margin <- margin(t=0,r=0,b=0,l=0)

  } else {margin <- margin}

  htmlwidgets::prependContent(
    table,
    htmltools::tags$h1(title,
                       style = paste0("color:", font_color, ";",
                                      "background:", background_color, ";",
                                      "text-align:", align, ";",
                                      "font-size:", font_size, "px;",
                                      "font-style:", font_style, ";",
                                      "font-weight:", font_weight, ";",
                                      "text-decoration:", text_decoration, ";",
                                      "letter-spacing:", letter_spacing, "px;",
                                      "word-spacing:", word_spacing, "px;",
                                      "text-transform:", text_transform, ";",
                                      "text-shadow:", text_shadow, ";",
                                      "margin-top:", margin[[1]], "px;",
                                      "margin-right:", margin[[2]], "px;",
                                      "margin-bottom:", margin[[3]], "px;",
                                      "margin-left:", margin[[4]], "px")
    )
  )
}

reactablefmtr_add_subtitle <- function(table = NULL,
                         subtitle = NULL,
                         align = "left",
                         font_color = "#000",
                         font_size = 24,
                         font_style = "normal",
                         font_weight = "bold",
                         text_decoration = NULL,
                         text_transform = NULL,
                         letter_spacing = NULL,
                         word_spacing = NULL,
                         text_shadow = NULL,
                         background_color = "#FFFFFF",
                         margin = NULL) {

  '%notin%' <- Negate('%in%')

  if (align %notin% c("left", "right", "center") == TRUE) {

    stop("align must be either 'left', 'right', or 'center'")
  }

  if (font_style %notin% c("normal", "italic") == TRUE) {

    stop("font_style must be either 'normal' or 'italic'")
  }

  if (font_weight %notin% c("normal", "bold") == TRUE) {

    stop("font_weight must be either 'normal' or 'bold'")
  }

  if (!is.null(text_transform) && text_transform %notin% c("uppercase", "lowercase", "capitalize") == TRUE) {

    stop("text_transform must be either 'uppercase', 'lowercase', or 'capitalize'")
  }

  if (!is.null(text_decoration) && text_decoration %notin% c("underline", "overline", "underline overline", "line-through") == TRUE) {

    stop("text_decoration must be either 'underline', 'overline', 'underline overline', or 'line-through'")
  }

  if (!is.null(margin) && length(margin)<4) {

    stop("please provide margin dimensions within `margin()`. Ex. margin = margin(t=10)")
  }

  if (is.null(margin)) {

    margin <- margin(t=0,r=0,b=0,l=0)

  } else {margin <- margin}


  htmlwidgets::prependContent(
    table,
    htmltools::tags$h2(subtitle,
                       style = paste0("color:", font_color, ";",
                                      "background:", background_color, ";",
                                      "text-align:", align, ";",
                                      "font-size:", font_size, "px;",
                                      "font-style:", font_style, ";",
                                      "font-weight:", font_weight, ";",
                                      "text-decoration:", text_decoration, ";",
                                      "letter-spacing:", letter_spacing, "px;",
                                      "word-spacing:", word_spacing, "px;",
                                      "text-transform:", text_transform, ";",
                                      "text-shadow:", text_shadow, ";",
                                      "margin-top:", margin[[1]], "px;",
                                      "margin-right:", margin[[2]], "px;",
                                      "margin-bottom:", margin[[3]], "px;",
                                      "margin-left:", margin[[4]], "px")
    )
  )
}
