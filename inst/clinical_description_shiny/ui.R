ui <- bslib::page_navbar(
  theme = bslib::bs_theme(version = 5, preset = "lumen"),
  title = "Phenotype Development",
  id = "nav",
  fillable = FALSE,
  
  shiny::tags$head(
    shiny::uiOutput("dynamic_css")
  ),
  
  bslib::nav_panel(
    title = "Clinical Description",
    shiny::div(class = "p-3",
               shiny::titlePanel(clinical_description_spec$title),
               shiny::p(clinical_description_spec$description, class = "text-muted mb-4"),
               bslib::layout_columns(
                 col_widths = c(3, 9),
                 bslib::card(
                   full_screen = TRUE,
                   bslib::card_header("Metadata"),
                   metadata_ui
                 ),
                 shiny::div(
                   shiny::h4("Clinical Profile", class = "mb-3"),
                   clinical_ui
                 )
               ),
               shiny::br(),
               shiny::uiOutput("clinical_download_section"),
               shiny::br(),
               shiny::br()
    )
  ),
  
  bslib::nav_panel(
    title = "Database Description",
    shiny::div(class = "p-3",
               shiny::titlePanel(db_spec$title),
               shiny::p(db_spec$description, class = "text-muted mb-4"),
               bslib::layout_columns(
                 col_widths = c(12),
                 bslib::card(
                   full_screen = TRUE,
                   bslib::card_header("Database Details"),
                   db_ui
                 )
               ),
               shiny::br(),
               shiny::uiOutput("db_download_section"),
               shiny::br(),
               shiny::br()
    )
  )
)