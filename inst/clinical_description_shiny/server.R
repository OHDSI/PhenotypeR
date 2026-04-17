server <- function(input, output, session) {
  
  required_metadata <- unlist(clinical_description_spec$properties$metadata$required)
  required_clinical <- unlist(clinical_description_spec$properties$clinical_profile$required)
  all_clinical_fields <- c(required_metadata, required_clinical)
  
  all_db_fields <- unlist(db_spec$required)
  
  clinical_labels <- sapply(all_clinical_fields, get_label_text)
  names(clinical_labels) <- all_clinical_fields
  
  db_labels <- sapply(all_db_fields, get_label_text)
  names(db_labels) <- all_db_fields
  
  clinical_missing <- shiny::reactive({
    all_clinical_fields[vapply(all_clinical_fields, function(id) {
      val <- input[[id]]
      if (is.null(val) || length(val) == 0) return(TRUE)
      if (is.character(val) && all(trimws(val) == "")) return(TRUE)
      if (any(is.na(val))) return(TRUE)
      return(FALSE)
    }, logical(1))]
  })
  
  db_missing <- shiny::reactive({
    all_db_fields[vapply(all_db_fields, function(id) {
      val <- input[[id]]
      if (is.null(val) || length(val) == 0) return(TRUE)
      if (is.character(val) && all(trimws(val) == "")) return(TRUE)
      if (any(is.na(val))) return(TRUE)
      return(FALSE)
    }, logical(1))]
  })
  
  output$dynamic_css <- shiny::renderUI({
    missing <- c(clinical_missing(), db_missing())
    if (length(missing) > 0) {
      css_rules <- paste0(
        "input#", missing, ", textarea#", missing, ", div#", missing, " input { ",
        "background-color: #ffe6e6 !important; border-color: #dc3545 !important; ",
        "}", 
        collapse = "\n"
      )
      shiny::tags$style(shiny::HTML(css_rules))
    }
  })
  
  output$clinical_download_section <- shiny::renderUI({
    missing <- clinical_missing()
    
    if (length(missing) == 0) {
      shiny::div(
        class = "d-flex gap-2",
        shiny::downloadButton("download_clinical_json", "Download JSON", class = "btn-primary"),
        shiny::downloadButton("download_clinical_word", "Download Word", class = "btn-info")
      )
    } else {
      missing_names <- paste(clinical_labels[missing], collapse = ", ")
      shiny::tagList(
        shiny::div(
          class = "d-flex gap-2",
          shiny::actionButton("disabled_clinical_json", "Download JSON", class = "btn-secondary disabled"),
          shiny::actionButton("disabled_clinical_word", "Download Word", class = "btn-secondary disabled")
        ),
        shiny::p(paste("Please fill in the following missing required fields to enable downloads:", missing_names), class = "text-danger mt-2 fw-bold")
      )
    }
  })
  
  output$db_download_section <- shiny::renderUI({
    missing <- db_missing()
    
    if (length(missing) == 0) {
      shiny::div(
        class = "d-flex gap-2",
        shiny::downloadButton("download_db_json", "Download JSON", class = "btn-primary"),
        shiny::downloadButton("download_db_word", "Download Word", class = "btn-info")
      )
    } else {
      missing_names <- paste(db_labels[missing], collapse = ", ")
      shiny::tagList(
        shiny::div(
          class = "d-flex gap-2",
          shiny::actionButton("disabled_db_json", "Download JSON", class = "btn-secondary disabled"),
          shiny::actionButton("disabled_db_word", "Download Word", class = "btn-secondary disabled")
        ),
        shiny::p(paste("Please fill in the following missing required fields to enable downloads:", missing_names), class = "text-danger mt-2 fw-bold")
      )
    }
  })
  
  output$download_clinical_json <- shiny::downloadHandler(
    filename = function() {
      paste0("clinical_description_", Sys.Date(), ".json")
    },
    content = function(file) {
      shiny::req(length(clinical_missing()) == 0)
      
      export_data <- list(
        metadata = stats::setNames(lapply(names(metadata_props), function(id) {
          if (!is.null(metadata_props[[id]]$format) && metadata_props[[id]]$format == "date") {
            as.character(input[[id]])
          } else {
            input[[id]]
          }
        }), names(metadata_props)),
        clinical_profile = stats::setNames(lapply(names(clinical_props), function(id) {
          input[[id]]
        }), names(clinical_props))
      )
      
      jsonlite::write_json(
        export_data, 
        file, 
        auto_unbox = TRUE, 
        pretty = TRUE
      )
    }
  )
  
  output$download_clinical_word <- shiny::downloadHandler(
    filename = function() {
      paste0("clinical_description_", Sys.Date(), ".docx")
    },
    content = function(file) {
      shiny::req(length(clinical_missing()) == 0)
      
      doc <- officer::read_docx()
      
      doc <- officer::body_add_par(doc, "Metadata", style = "heading 1")
      for (id in names(metadata_props)) {
        val <- if (!is.null(metadata_props[[id]]$format) && metadata_props[[id]]$format == "date") {
          as.character(input[[id]])
        } else {
          input[[id]]
        }
        doc <- officer::body_add_par(doc, get_label_text(id), style = "heading 2")
        doc <- officer::body_add_par(doc, val, style = "Normal")
      }
      
      doc <- officer::body_add_par(doc, "Clinical Profile", style = "heading 1")
      for (id in names(clinical_props)) {
        doc <- officer::body_add_par(doc, get_label_text(id), style = "heading 2")
        doc <- officer::body_add_par(doc, input[[id]], style = "Normal")
      }
      
      print(doc, target = file)
    }
  )
  
  output$download_db_json <- shiny::downloadHandler(
    filename = function() {
      paste0("database_description_", Sys.Date(), ".json")
    },
    content = function(file) {
      shiny::req(length(db_missing()) == 0)
      
      export_data <- stats::setNames(lapply(names(db_props), function(id) {
        input[[id]]
      }), names(db_props))
      
      jsonlite::write_json(
        export_data, 
        file, 
        auto_unbox = TRUE, 
        pretty = TRUE
      )
    }
  )
  
  output$download_db_word <- shiny::downloadHandler(
    filename = function() {
      paste0("database_description_", Sys.Date(), ".docx")
    },
    content = function(file) {
      shiny::req(length(db_missing()) == 0)
      
      doc <- officer::read_docx()
      
      doc <- officer::body_add_par(doc, "Database Description", style = "heading 1")
      for (id in names(db_props)) {
        doc <- officer::body_add_par(doc, get_label_text(id), style = "heading 2")
        doc <- officer::body_add_par(doc, input[[id]], style = "Normal")
      }
      
      print(doc, target = file)
    }
  )
}
