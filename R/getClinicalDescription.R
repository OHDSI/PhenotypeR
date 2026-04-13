
#' Get clinical descriptions using an LLM
#'
#' @param chat An ellmer chat
#' @param name Clinical event of interest
#' @param outputDir Folder to save clinical descriptions.
#'
#' @returns A list with each item containing the clinical description.
#' @export
#'
getClinicalDescription <- function(chat, name, outputDir){

  rlang::check_installed("ellmer")
  rlang::check_installed("officer")

  omopgenerics::assertCharacter(name)
  if (!dir.exists(outputDir)) {
    cli::cli_abort("{outputDir} does not exist")
  }

  descriptions <- list()
  for(i in seq_along(name)){
    working_name <- name[[i]]
    descriptions[[working_name]] <- fetchClinicalDescription(chat = chat,
                                           name = working_name)
    if(!is.null(outputDir)){
      descriptions[working_name] |>
        exportClinicalDescription(modelName = chat$get_model(),
                                  outputDir = outputDir)
    }
  }

  return(invisible(NULL))

}

fetchClinicalDescription <- function(chat, name){

  cli::cli_inform("Getting clinical description for {name}")

  systemPrompt <- "You are a terse assistant helping a user (with equivalent medical knowledge to that of a well-informed member of the lay public) working with real-world health care data to write a
clinical definition that will be used to assess that the study cohorts they create are reliable."
  systemPrompt <- paste0(systemPrompt,
                          "Study cohorts can include, but not limited to, people with a particular diagnosis, people having a routine lab test, people having a procedure, and people who are users of a medication. ")
  systemPrompt <- paste0(systemPrompt,
                          "Unless specified, real world data being used may be drawn from different settings (such as primary care and hospital care) and types (such as electronic healthcare records or insurance data). ")
  systemPrompt <- paste0(systemPrompt,
                          "For medications, use ATC classifications where appropriate, but otherwise use drug ingredient names, and avoid abbreviations. ")
  systemPrompt <- paste0(systemPrompt,
                          "Use British spelling. Keep responses factual, straightforward, circumspect, and do not exaggerate or use flowery or euphuistic language.")

  # start from a clean slate
  chat <- chat$clone()$set_turns(list())
  chat <- chat$set_system_prompt(value = systemPrompt)

  userPrompt <- "Provide a paragraph with a high-level clinical description of {{name}}, including commonly used synonyms in the medical literature, medical professionals, and the general public.
           Write two paragraphs summarising the typical clinical presentation of {{name}} and associated symptoms patients experience in the lead up to being diagnosed,
           Give a three paragraph summary of the epidemiogy of {{name}}. Focus on how prevalence and/or incidence vary by patient characteristics (such as age and sex) in the first paragraph (don't report specific numbers), associated risk factors in the second paragraph, and typical comorbidities (that may come before or afterwards) seen among patients in the third paragraph.
           Explain in two paragraphs how patients are typically assessed by doctors and other medical professionals when presenting with {{name}}, and how the diagnosis is made (including the typical tests and measurements used to inform diagnosis if relevant).
           Provide two paragraphs of the typical therapeutic/ treatment plan for {{name}}. Focus in the first paragraph on the initial treatments patients are likely to receive, and in the second paragraph on medicines received later on (explaining how they depend on if initial treamtent was succesful or not if relevant).
           Write two paragraphs. In the first summarise common complications seen among people diagnosed with {{name}}. In the second describe short, medium, and longer term prognosis for patients.
           Write a paragraph describing disqualifiers/ differential diagnoses related to {{name}} that medical professionals must consider. Comment on temporality if relevant, whether differential or more specific diagnoses are consider at the same time or later on after initial diagnosis."


  type_my_df <- ellmer::type_array(
    items = ellmer::type_object(
      introduction_synonyms = ellmer::type_string(),
      clinical_presentation_and_symptoms = ellmer::type_string(),
      epidemiology = ellmer::type_string(),
      assessment_diagnosis = ellmer::type_string(),
      therapeutic_plan_treatment = ellmer::type_string(),
      complications_prognosis = ellmer::type_string(),
      disqualifiers = ellmer::type_string()
    )
  )

  chat_output <- chat$chat_structured(
    ellmer::interpolate(userPrompt),
    type = type_my_df,
    echo = "none")

  description <- paste(
    "### Introduction/ synonyms",
    chat_output$introduction_synonyms,
    "### Clinical presentation/ symptoms",
    chat_output$clinical_presentation_and_symptoms,
    "### Epidemiology",
    chat_output$epidemiology,
    "### Assessment/ diagnosis",
    chat_output$assessment_diagnosis,
    "### Therapeutic plan/ treatment",
    chat_output$therapeutic_plan_treatment,
    "### Complications and prognosis",
    chat_output$complications_prognosis,
    "### Disqualifiers/ differential diagnoses",
    chat_output$disqualifiers,
    sep = "\n\n"
  )

  return(description)

}

exportClinicalDescription <- function(clinicalDescription, systemPrompt, userPrompt, modelName, outputDir) {

  for (i in seq_along(clinicalDescription)) {

    name <- names(clinicalDescription)[i]
    path <- file.path(outputDir, paste0(name, ".docx"))

    cli::cli_inform("Exporting word document for clinical description of {name}")

    text <- clinicalDescription[[i]]

    paragraphs <- strsplit(text, split = "\n\n") |> unlist()

    template <- system.file("shiny/data/raw/clinical_descriptions/template/template_minimal.docx",
                            package = "PhenotypeR")
    if(!is.null(template) && file.exists(template)){
      doc <-  officer::read_docx(path = template)
    } else {
      doc <- officer::read_docx()
    }
    italics_format <- officer::fp_text(italic = TRUE)

    doc <- officer::body_add_par(doc,
                                 value = paste0("Clinical description for ", name),
                                 style = "Title")
    doc <- officer::body_add_par(doc, value = "", style = "Normal")

    created_on <- officer::ftext(text =  paste0("Created on ", Sys.Date()),
                                 prop = italics_format)
    doc <- officer::body_add_fpar(doc,
                                  value = officer::fpar(created_on))
    doc <- officer::body_add_par(doc, value = "", style = "Normal")

    created_by <- officer::ftext(text =  paste0("Description generated by using ", modelName, " (via PhenotypeR::getClinicalDescription())"),
                                     prop = italics_format)
    doc <- officer::body_add_fpar(doc,
                                  value = officer::fpar(created_by))

    doc <- officer::body_add_par(doc, value = "", style = "Normal")

    for (j in seq_along(paragraphs)) {
      working_paragraph <- paragraphs[[j]]
      working_paragraph <- trimws(working_paragraph)
      if (grepl("^###\\s", working_paragraph)) {
        clean_heading <- sub("^###\\s*", "", working_paragraph)
        doc <- officer::body_add_par(doc, value = clean_heading, style = "heading 1")
      } else {
        doc <- officer::body_add_par(doc, value = working_paragraph, style = "Normal")
      }
    }

    print(doc, target = path)
  }
  cli::cli_alert_success("Exported as {path}")
}
