server <- function(input, output, session) {
  
  required_metadata <- unlist(clinical_description_spec$properties$metadata$required)
  required_clinical <- unlist(clinical_description_spec$properties$clinical_profile$required)
  all_clinical_fields <- c(required_metadata, required_clinical)

  required_admin <- unlist(db_spec$properties$administrative_details$required)
  required_data_elements <- unlist(db_spec$properties$data_elements_collected$required)
  all_db_fields <- c(required_admin, required_data_elements)

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
        shiny::downloadButton("download_clinical_json", "Download JSON", class = "btn-primary")
      )
    } else {
      missing_names <- paste(clinical_labels[missing], collapse = ", ")
      shiny::tagList(
        shiny::div(
          class = "d-flex gap-2",
          shiny::actionButton("disabled_clinical_json", "Download JSON", class = "btn-secondary disabled")        ),
        shiny::p(paste("Please fill in the following missing required fields to enable downloads:", missing_names), class = "text-danger mt-2 fw-bold")
      )
    }
  })

  output$db_download_section <- shiny::renderUI({
    missing <- db_missing()

    if (length(missing) == 0) {
      shiny::div(
        class = "d-flex gap-2",
        shiny::downloadButton("download_db_json", "Download JSON", class = "btn-primary")      )
    } else {
      missing_names <- paste(db_labels[missing], collapse = ", ")
      shiny::tagList(
        shiny::div(
          class = "d-flex gap-2",
          shiny::actionButton("disabled_db_json", "Download JSON", class = "btn-secondary disabled")        ),
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


  
  output$ai_draft_message <- shiny::renderUI({
    shiny::req(input$draft_with_ai > 0) 

    if(input$phenotype_name == ""){
      return(
        shiny::span("Phenotype name must be provided",
                  class = "text-danger fw-bold mt-2 d-block")
      )
    }
   
    if(is.null(chat)){
      return(
        shiny::span("No LLM available To use an LLM to draft description, run app locally using PhenotypeR::getClinicalDescription() and create ellmer chat object in global.R",
                    class = "text-danger fw-bold mt-2 d-block")
      )
    }
    
    shinyjs::disable("draft_with_ai")
    shiny::showModal(
      shiny::modalDialog(
        title = "Drafting with AI",
        shiny::div(
          class = "d-flex align-items-center gap-3",
          shiny::icon("spinner", class = "fa-spin fa-2x text-primary"),
          shiny::span("Please wait while LLM generates the clinical description", 
                      class = "fs-5")
        ),
        footer = NULL,      
        easyClose = FALSE  
      )
    )
    
    # Ensure the button enables AND the modal closes when finished
    on.exit({
      shinyjs::enable("draft_with_ai")
      shiny::removeModal()
    })
    
    tmp <- file.path(tempdir(), omopgenerics::uniqueTableName())
    dir.create(tmp)
    
    
    # using ellmer chat object created by user in global
    PhenotypeR::getClinicalDescription(chat,
                                       name = input$phenotype_name,
                                       outputDir =  tmp)
    clinical_description <-  PhenotypeR:::importClinicalDescription(path = tmp)
    

      for (i in seq_along(names(clinical_description[[1]]$clinical_profile))) {
        shiny::updateTextAreaInput(
          session = session,
          inputId = names(clinical_description[[1]]$clinical_profile[i]),
          value = clinical_description[[1]]$clinical_profile[[i]]
        )
      }
    
    for (i in seq_along(names(clinical_description[[1]]$metadata))) {
      shiny::updateTextAreaInput(
        session = session,
        inputId = names(clinical_description[[1]]$metadata[i]),
        value = clinical_description[[1]]$metadata[[i]]
      )
    }


  })
  
}
