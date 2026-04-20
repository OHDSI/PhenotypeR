ui <- bslib::page_navbar(
  theme = bslib::bs_theme(version = 5, preset = "lumen"),
  title = "Phenotype Development",
  id = "nav",
  fillable = FALSE,
  
  shiny::tags$head(
    shiny::uiOutput("dynamic_css"),
    shiny::tags$style("
      /* Remove blue background and text color when open */
      .accordion-button:not(.collapsed) {
        background-color: var(--bs-accordion-bg) !important;
        color: var(--bs-accordion-color) !important;
        box-shadow: none !important;
      }
      /* Remove the blue focus ring/outline when clicked */
      .accordion-button:focus {
        box-shadow: none !important;
        border-color: rgba(0,0,0,.125) !important;
      }
    ")
  ),
  
  bslib::nav_panel(
    title = "Clinical Description",
    shiny::div(class = "p-3",
               shiny::titlePanel(clinical_description_spec$title),
               shiny::p(clinical_description_spec$description, class = "text-muted mb-4"),
               
               shiny::div(class = "mb-4",
                          shiny::uiOutput("clinical_download_section")
               ),
               
               bslib::accordion(
                 multiple = TRUE,
                 open = c("Metadata", "Clinical Profile"),
                 
                 bslib::accordion_panel(
                   title = "Metadata",
                   icon = shiny::icon("tags"),
                   
                   # Phenotype Name on its own row
                   shiny::div(
                     class = "p-3 mb-4 bg-light border-start border-primary border-4 rounded shadow-sm",
                     metadata_ui[[1]], # phenotype_name on its own
                     
                     shiny::actionButton(
                       inputId = "draft_with_ai", 
                       label = "Draft with AI", 
                       icon = shiny::icon("wand-magic-sparkles"), 
                       class = "btn-primary mt-2"
                     ),
                     shiny::uiOutput("ai_draft_message")
                   ),
                   
                   # other metadata
                   do.call(bslib::layout_column_wrap, c(list(width = 1/2), metadata_ui[-1]))
                 ),
                 
                 bslib::accordion_panel(
                   title = "Clinical Profile",
                   icon = shiny::icon("file-medical"),
                   clinical_ui
                 )
               )
    )
  ),
  
  bslib::nav_panel(
    title = "Database Description",
    shiny::div(class = "p-3",
               shiny::titlePanel(db_spec$title),
               shiny::p(db_spec$description, class = "text-muted mb-4"),
               
               shiny::div(class = "mb-4",
                          shiny::uiOutput("db_download_section")
               ),
               
               bslib::accordion(
                 multiple = TRUE,
                 open = "Database Details",
                 
                 bslib::accordion_panel(
                   title = "Database Details",
                   icon = shiny::icon("database"),
                   db_ui
                 )
               )
    )
  )
)