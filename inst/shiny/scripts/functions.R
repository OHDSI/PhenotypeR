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

find_info_in_the_line <- function(doc_text, string) {
  pattern <- paste0("^", string, "\\s*")
  
  pi <- doc_text |>
    dplyr::filter(stringr::str_detect(text, regex(pattern, ignore_case = TRUE))) |>
    dplyr::pull("paragraph_index")
  
  doc_text <- doc_text |>
    dplyr::filter(.data$paragraph_index == pi) |>
    dplyr::pull("text") |>
    paste0(collapse = "")
  
  doc_text <- gsub(pattern, "", doc_text, ignore.case = TRUE)
  
  return(doc_text)
}

find_info_in_the_paragraph <- function(doc_text, start, end, addStyle, removeFirstTitle = FALSE){
  pi_start <- doc_text |>
    dplyr::filter(stringr::str_detect(text, regex(paste0("^", start), ignore_case = TRUE))) |>
    dplyr::pull("paragraph_index")
  
  if(removeFirstTitle){pi_start <- pi_start + 1}
  if(is.null(end)){
    pi_end <- doc_text |> dplyr::filter(dplyr::row_number() == nrow(doc_text)) |>
      dplyr::pull("paragraph_index")
  }else{
    pi_end <- c(doc_text |>
                  dplyr::filter(stringr::str_detect(text, regex(paste0("^", end), ignore_case = TRUE))) |>
                  dplyr::pull("paragraph_index")-1)
  }

  doc_text <- doc_text |>
    dplyr::filter(.data$paragraph_index %in% c(pi_start:pi_end)) 

  if(isTRUE(addStyle)){
    doc_text <- doc_text |>
      dplyr::mutate("text" = dplyr::if_else(bold, paste0("<strong>", .data$text, "</strong>"), .data$text),
                    "text" = dplyr::if_else(italic, paste0("<em>", .data$text, "</em>"), .data$text),
                    "text" = dplyr::if_else(underline, paste0("<span style='text-decoration: underline;'>", .data$text, "</span>"), text))
                    
      
  }
  
  doc_text <- doc_text |>
    dplyr::arrange(paragraph_index, run_index) |>   
    dplyr::group_by(paragraph_index) |>
    dplyr::summarise("text" = paste0(text, collapse = "")) |>
    dplyr::pull(text)
  
  doc_text <- stringr::str_replace(string = doc_text, pattern = "^NA$", replacement = "\n")

  return(doc_text)
}


parse_docx_runs <- function(path_docx) {
  
  unzip(path_docx, files = "word/document.xml", exdir = "data/raw/clinical_description")
  doc_xml_path <- file.path("data/raw/clinical_description", "word", "document.xml")
  if (!file.exists(doc_xml_path)) stop("document.xml not found in docx")
  
  doc <- xml2::read_xml(doc_xml_path)
  ns <- xml2::xml_ns(doc)
  
  paragraphs <- xml2::xml_find_all(doc, ".//w:p", ns = ns)
  
  rows <- purrr::imap_dfr(paragraphs, function(pnode, p_index) {
    pstyle_node <- xml2::xml_find_first(pnode, ".//w:pPr/w:pStyle", ns = ns)
    style_name <- if (!is.na(pstyle_node)) xml2::xml_attr(pstyle_node, "w:val") else NA_character_
    
    runs <- xml2::xml_find_all(pnode, ".//w:r", ns = ns)
    if (length(runs) == 0) {
      text_nodes <- xml2::xml_find_all(pnode, ".//w:t", ns = ns)
      text_combined <- paste0(xml2::xml_text(text_nodes), collapse = "")
      dplyr::tibble(
        "paragraph_index" = p_index,
        "run_index" = 1L,
        "text" = ifelse(text_combined == "", NA_character_, text_combined),
        "bold" = FALSE,
        "italic" = FALSE,
        "underline" = FALSE,
        "style_name" = style_name
      )
    } else {
      purrr::imap_dfr(runs, function(rnode, r_index) {
        tnodes <- xml2::xml_find_all(rnode, ".//w:t", ns = ns)
        text_run <- if (length(tnodes) == 0) "" else paste0(xml2::xml_text(tnodes), collapse = "")
        
        has_b <- length(xml2::xml_find_all(rnode, ".//w:rPr/w:b", ns = ns)) > 0
        has_i <- length(xml2::xml_find_all(rnode, ".//w:rPr/w:i", ns = ns)) > 0
        has_u <- length(xml2::xml_find_all(rnode, ".//w:rPr/w:u", ns = ns)) > 0
        
        dplyr::tibble(
          "paragraph_index" = p_index,
          "run_index" = r_index,
          "text" = ifelse(text_run == "", NA_character_, text_run),
          "bold" = has_b,
          "italic" = has_i,
          "underline" = has_u,
          "style_name" = style_name
        )
      })
    }
  })
  
  rows <- rows |>
    dplyr::arrange(paragraph_index, run_index)
  
  unlink(file.path("data/raw/clinical_description", "word"))
  return(rows)
}
