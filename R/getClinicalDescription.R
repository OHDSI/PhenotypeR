
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
  rlang::check_installed("jsonlite")
  rlang::check_installed("jsonvalidate")
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

  cli::cli_inform("Getting clinical description for {name} using {chat$get_model()}")

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

  return(chat_output)

}

exportClinicalDescription <- function(clinicalDescription, modelName, outputDir) {

    for (i in seq_along(clinicalDescription)) {
      name <- names(clinicalDescription)[i]
      file_safe_name <- fs::path_sanitize(name)
      path <- file.path(outputDir, paste0(file_safe_name, ".json"))

      cli::cli_inform("Exporting clinical description for: '{name}'")

      structured_list <- list(
        metadata = list(
          phenotype_name = name,
          version = "1.0",
          created_by = paste0(modelName, " (via PhenotypeR::getClinicalDescription())"),
          created_date = as.Date(Sys.Date()),
          last_edited_by = "N/A",
          last_edited_date = as.Date(Sys.Date()),
          source_of_information = modelName
        ),
        clinical_profile = list(
          introduction_synonyms = clinicalDescription[[i]]$introduction_synonyms,
          clinical_presentation_and_symptoms = clinicalDescription[[i]]$clinical_presentation_and_symptoms,
          assessment_diagnosis = clinicalDescription[[i]]$assessment_diagnosis,
          therapeutic_plan_treatment = clinicalDescription[[i]]$therapeutic_plan_treatment,
          complications_prognosis = clinicalDescription[[i]]$complications_prognosis,
          disqualifiers = clinicalDescription[[i]]$disqualifiers,
          epidemiology = clinicalDescription[[i]]$epidemiology
        )
      )

      jsonlite::write_json(
        structured_list,
        path = path,
        auto_unbox = TRUE,
        pretty = TRUE
      )

      cli::cli_alert_success("Exported as {path}")
    }

}

importClinicalDescription <- function(path){

  omopgenerics::assertCharacter(path, length = 1, call = call)
  if (!file.exists(path)) {
    cli::cli_abort("{.path {path}} does not exist")
  }

  if (file.info(path)$isdir) {
    path <- list.files(path = path, full.names = TRUE)
  }
  path <- path[tools::file_ext(path) == "json"]
  names(path) <- as.list(tools::file_path_sans_ext(basename(path)))

  if(length(path) == 0){
    cli::cli_abort("No clinical descriptions found")
  }

  descriptions <- list()
  for(i in seq_along(path)){
  working_file <- path[[i]]
  cli::cli_inform("Importing clinical description from: '{working_file}'")
  validate <-jsonvalidate::json_validate(
    working_file,
    system.file("clinical_description_specification.json", package = "PhenotypeR"),
    verbose = TRUE,
    error = TRUE)
  working_json <- jsonlite::read_json(working_file)
  working_phenotype <- working_json$metadata$phenotype_name
  descriptions[[working_phenotype]] <- working_json
  cli::cli_alert_success("Imported clinical description: '{working_phenotype}'")
  }

  return(descriptions)

}
