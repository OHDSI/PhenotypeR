library(shiny)
library(bslib)
library(jsonlite)
library(officer)
library(tools)

clinical_description_spec <- jsonlite::fromJSON(here::here("clinical_description_specification.json"),
                                                simplifyVector = FALSE)
db_spec <- jsonlite::fromJSON(here::here("database_description.json"),
                              simplifyVector = FALSE)


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

db_props <- db_spec$properties
db_ui <- lapply(names(db_props), function(id) {
  prop <- db_props[[id]]
  label_ui <- create_label_ui(id, prop$description)

  if (id == "database_description") {
    bslib::card(
      full_screen = TRUE,
      class = "expandable-card",
      shiny::textAreaInput(id, label_ui, rows = 10, width = "100%", autoresize = TRUE)
    )
  } else {
    shiny::textInput(id, label_ui, width = "100%")
  }
})
