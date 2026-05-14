ui <- bslib::page_navbar(
  theme = bslib::bs_theme(version = 5, preset = "lumen"),
  title = "Phenotype Development",
  id = "nav",
  fillable = FALSE,
  
  shiny::tags$head(
    shinyjs::useShinyjs(),
    shiny::uiOutput("dynamic_css"),
    shiny::tags$style("
      .accordion-button:not(.collapsed) {
        background-color: var(--bs-accordion-bg) !important;
        color: var(--bs-accordion-color) !important;
        box-shadow: none !important;
      }
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
               shiny::p(clinical_description_spec$description, 
                        class = "text-muted mb-4"),
               bslib::accordion(
                 multiple = TRUE,
                 open = c("Phenotype name",
                          "Metadata", 
                          "Clinical Profile"),
                 
                 bslib::accordion_panel(
                   title = "Phenotype name",
                   icon = shiny::icon("tags"),
                   metadata_ui[[1]],
                   
                   shiny::div(
                     class = "p-3 mb-4 bg-light border-start border-primary border-4 rounded shadow-sm",
                     
                     shiny::actionButton(
                       inputId = "draft_with_ai", 
                       label = "Draft with AI", 
                       icon = shiny::icon("wand-magic-sparkles"), 
                       class = "btn-primary",
                       style = "margin-bottom: 15px;" 
                     ),
                     
                     shiny::uiOutput("ai_draft_message")
                   )
                 
                 ),
               
               

                 
                 bslib::accordion_panel(
                   title = "Metadata",
                   icon = shiny::icon("tags"),
                   do.call(bslib::layout_column_wrap, c(list(width = 1/2), 
                                                        metadata_ui[-1]))
                 ),
                 
                 bslib::accordion_panel(
                   title = "Clinical Profile",
                   icon = shiny::icon("file-medical"),
                   clinical_ui
                 )
               )
    ),
    shiny::div(class = "mb-4",
               shiny::uiOutput("clinical_download_section")
    )
  ),
  
  bslib::nav_panel(
    title = "Database Description New",
    shiny::div(class = "p-3",
               shiny::titlePanel(db_spec$title),
               shiny::p(db_spec$description, 
                        class = "text-muted mb-4"),
               bslib::accordion(
                 multiple = TRUE,
                 open = c("Administrative details",
                          "Data elements collected"),
                 
                 bslib::accordion_panel(
                   title = "Administrative details",
                   icon = shiny::icon("file-medical"),
                   db_admin_ui
                 ),
                 
                 bslib::accordion_panel(
                   title = "Data elements collected",
                   icon = shiny::icon("file-medical"),
                   db_data_ui
                 )
               )
    ),
    shiny::div(class = "mb-4",
               shiny::uiOutput("db_download_section")
    )
  )
)