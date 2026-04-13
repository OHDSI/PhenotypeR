
#' Get clinical descriptions using an LLM
#'
#' @param chat An ellmer chat
#' @param name Clinical event of interest
#' @param outputDir Folder to save clinical descriptions.
#'
#' @returns Creates a word document with a clinical description for each event.
#' @export
#'
getClinicalDescription <- function(chat, name, outputDir){

  rlang::check_installed("ellmer")
  rlang::check_installed("officer")
  rlang::check_installed("fs")

  model_name <- chat$get_model()

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
        exportClinicalDescription(modelName = model_name,
                                  outputDir = outputDir)
    }
  }

  return(invisible(descriptions))

}

fetchClinicalDescription <- function(chat, name){

  cli::cli_inform("Getting clinical description for {name}")

  systemPrompt <- "You are a factual assistant helping a user working with real-world health care data. Assume the user has medical knowledge equivalent to a well-informed member of the public. Your goal is to write a clinical definition to assess the reliability of study cohorts identified in real-world data.

  Context and Rules:
  - Study cohorts may include people with specific diagnoses, lab tests, procedures, or medication users.
  - This output is strictly for data scientists and epidemiologists. Do NOT include patient-facing warnings, disclaimers, or advice to consult a healthcare professional.
  - If a diagnostic threshold or treatment protocol varies significantly by region or over recent time, state that it varies and provide the typical range rather than declaring a single absolute value.
  - Use generic drug ingredient names when explaining medicines. Avoid abbreviations where possible; if an abbreviation is necessary, you must spell it out on first use.
  - Keep responses strictly factual, straightforward, circumspect, and highly specific.
  - Do not exaggerate or use flowery/euphemistic/ cliched language.
  - Use British spelling.
  - Write full sentences. No bullet points, no lists, no bold, no italics, and no other special formatting.

  Tone Example:
  - GOOD: 'Type 2 diabetes mellitus is characterised by hyperglycaemia (high blood sugar levels)'
  - GOOD: 'When diagnosing hypertension, the main consideration is to differentiate primary (essential) hypertension from secondary hypertension, which is caused by an underlying condition.'
  - GOOD: 'Common symptoms experienced in the lead up to diagnosis include polyuria (frequent urination), polydipsia (increased thirst), and polyphagia (increased hunger).'
  - GOOD: 'For venous thromboembolism, major risk factors include recent surgery (especially orthopaedic), major trauma, immobility, active cancer, pregnancy, and inherited or acquired thrombophilias (clotting disorders).'
  - BAD: 'Hypertension is often referred to as a silent killer' - cliched language
  - BAD: 'Diet low in sodium (such as the DASH diet)' - acronym not explained
  - BAD: 'The cornerstone of management is paracetamol' - cliched language
  - BAD: 'The search for a secondary cause is particularly important in younger patients' - too flowery
  - BAD: 'Certain medications and substances can also induce or exacerbate hypertension' - too vague
  "

  # start from a clean slate
  chat <- chat$clone()$set_turns(list())
  chat <- chat$set_system_prompt(value = systemPrompt)

  userPrompt <- "Provide a comprehensive clinical profile for {{name}}. Structure your response to map exactly to the following requested sections:

  - introduction_synonyms: Provide a concise high-level clinical description of {{name}}, including commonly used synonyms in the medical literature and by medical professionals.
  - clinical_presentation_and_symptoms: Summarise the typical clinical presentation of {{name}} and associated symptoms patients experience in the lead up to being diagnosed,
  - epidemiology: Summarise the known epidemiology of {{name}}. Focus first on how prevalence and/or incidence vary by patient characteristics (such as age and sex), but don't report specific numbers. Then summarise associated modifiable and non-modifiable risk factors. Then summarise typical comorbidities (that may come before or afterwards) seen among patients.
  - assessment_diagnosis: Explain how patients are typically assessed by doctors and other medical professionals when presenting with {{name}}, and how the diagnosis is made (including the typical tests and measurements used to inform diagnosis if relevant).
  - therapeutic_plan_treatment: Describe the typical therapeutic/ treatment plan for {{name}}. Focus in the first on the initial treatments patients are likely to receive. Then describe medicines received later on, explaining how they depend on if initial treatment was successful or not if relevant.
  - complications_prognosis: Summarise common complications seen among people diagnosed with {{name}}. Then describe short, medium, and longer term prognosis for patients.
  - disqualifiers: Explain the disqualifiers/ differential diagnoses related to {{name}} that medical professionals must consider. Comment on temporality if relevant, whether differential or more specific diagnoses are considered at the same time or later on after initial diagnosis."


  type_my_df <- ellmer::type_object(
      introduction_synonyms = ellmer::type_string(),
      clinical_presentation_and_symptoms = ellmer::type_string(),
      epidemiology = ellmer::type_string(),
      assessment_diagnosis = ellmer::type_string(),
      therapeutic_plan_treatment = ellmer::type_string(),
      complications_prognosis = ellmer::type_string(),
      disqualifiers = ellmer::type_string()
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

exportClinicalDescription <- function(clinicalDescription, modelName, outputDir) {

  for (i in seq_along(clinicalDescription)) {

    name <- names(clinicalDescription)[i]
    file_safe_name <- fs::path_sanitize(name)
    path <- file.path(outputDir, paste0(file_safe_name, ".docx"))


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
