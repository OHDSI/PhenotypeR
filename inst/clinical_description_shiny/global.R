library(shiny)
library(bslib)
library(jsonlite)
library(jsonvalidate)
library(officer)
library(tools)
library(shinyjs)

# create ellmer chat object for AI draft functionality
# e.g. chat <- ellmer::chat("google_gemini")
chat <- NULL

clinical_description_spec <- jsonlite::fromJSON(system.file("clinical_description_specification.json", 
                                                            package = "PhenotypeR"),
                                                simplifyVector = FALSE)
db_spec <- PhenotypeR::dataSourceDescriptionSpecification() |> 
  jsonlite::fromJSON(simplifyVector = FALSE)


get_label_text <- function(id) {
  switch(id,
         "phenotype_name" = "Phenotype Name",
         "version" = "Version",
         "created_by" = "Created By",
         "created_date" = "Created Date",
         "last_edited_by" = "Last Edited By",
         "last_edited_date" = "Last Edited Date",
         "source_of_information" = "Source of Information",
         "introduction_synonyms" = "Introduction & Synonyms",
         "clinical_presentation_and_symptoms" = "Clinical Presentation & Symptoms",
         "assessment_diagnosis" = "Assessment & Diagnosis",
         "therapeutic_plan_treatment" = "Therapeutic Plan & Treatment",
         "complications_prognosis" = "Complications & Prognosis",
         "disqualifiers" = "Disqualifiers",
         "epidemiology" = "Epidemiology",
         "database_name" = "Database Name",
         "database_description" = "Database Description",
         tools::toTitleCase(gsub("_", " ", id)))
}
create_label_ui <- function(id, description) {
  shiny::tags$span(
    get_label_text(id),
    bslib::tooltip(shiny::icon("info-circle"), description)
  )
}

metadata_props <- clinical_description_spec$properties$metadata$properties
metadata_ui <- lapply(names(metadata_props), function(id) {
  prop <- metadata_props[[id]]
  label_ui <- create_label_ui(id, prop$description)

  if (!is.null(prop$format) && prop$format == "date") {
    shiny::dateInput(id, label_ui, format = "yyyy-mm-dd", value = Sys.Date(), width = "100%")
  } else {
    shiny::textInput(id, label_ui, width = "100%")
  }
})

clinical_props <- clinical_description_spec$properties$clinical_profile$properties
clinical_ui <- lapply(names(clinical_props), function(id) {
  prop <- clinical_props[[id]]
  label_ui <- create_label_ui(id, prop$description)

  bslib::card(
    full_screen = TRUE,
    class = "expandable-card",
    shiny::textAreaInput(id, label_ui, rows = 6, width = "100%", autoresize = TRUE)
  )
})

db_admin <- db_spec$properties$administrative_details$properties
db_admin_ui <- lapply(names(db_admin), function(id) {
  prop <- db_admin[[id]]
  label_ui <- create_label_ui(id, prop$description)

  if (id == "main_references") {
    bslib::card(
      full_screen = TRUE,
      class = "expandable-card",
      shiny::textAreaInput(id, label_ui, rows = 3, width = "100%", autoresize = TRUE)
    )
  } else {
    bslib::card(
      full_screen = TRUE,
      class = "expandable-card",
      shiny::textAreaInput(id, label_ui, rows = 1, width = "100%", autoresize = TRUE)
    )
  }
})

db_data <- db_spec$properties$data_elements_collected$properties
db_data_ui <- lapply(names(db_data), function(id) {
  prop <- db_data[[id]]
  label_ui <- create_label_ui(id, prop$description)
  
    bslib::card(
      full_screen = TRUE,
      class = "expandable-card",
      shiny::textAreaInput(id, label_ui, rows = 5, width = "100%", autoresize = TRUE)
    )
})
