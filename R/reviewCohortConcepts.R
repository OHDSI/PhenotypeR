

#' Use an LLM to review concepts that led to cohort inclusion
#'
#' @param chat An ellmer chat
#' @param cohortConcepts Results that include codelist diagnostics
#' @param clinicalDescription A clinical description
#'
#' @returns A tibble with concepts reviewed
#' @export
#'
reviewCohortConcepts <- function(chat, cohortConcepts, clinicalDescription){

  rlang::check_installed("ellmer")

  cohortConcepts <- omopgenerics::validateResultArgument(cohortConcepts)
  conceptsToReview <- cohortConcepts |>
    omopgenerics::filterSettings(result_type == "cohort_code_use")

  if(nrow(conceptsToReview) == 0){
    cli::cli_warn("No included concepts found to review")
    return(dplyr::tibble())
  }

  conceptsToReview <- conceptsToReview |>
    dplyr::filter(variable_name != "overall") |>
    omopgenerics::splitAll() |>
    dplyr::select("cohort_name",
                  "codelist_name",
                  "standard_concept" = "variable_name",
                  "standard_concept_id" = "variable_level",
                  "source_concept_name",
                  "source_concept_id",
                  "source_concept_value") |>
    dplyr::distinct()

  phenotypes <- conceptsToReview |>
    dplyr::pull("cohort_name") |>
    unique()

  reviewedConcepts <- list()
  for(i in seq_along(phenotypes)){
    workingPhenotype <- phenotypes[i]
    workingConcepts <- conceptsToReview |>
      dplyr::filter(cohort_name == workingPhenotype)
    reviewedConcepts[[i]] <- getIncludedConceptsReview(chat = chat,
                              name = workingPhenotype,
                              concepts = workingConcepts,
                              clinicalDescription = clinicalDescription[[workingPhenotype]])
  }
  reviewedConcepts <- dplyr::bind_rows(reviewedConcepts)

  reviewedConcepts

}

# for a single cohort + codelist
getIncludedConceptsReview <- function(chat, name, concepts, clinicalDescription){

  cli::cli_inform("Reviewing {nrow(concepts)} concepts for {name}")

  systemPrompt <- getIncludedSytemPrompt(name, clinicalDescription)

  chat <- chat$clone()$set_turns(list())$set_system_prompt(systemPrompt)

  concept_review_schema <- ellmer::type_object(
    "Evaluation of whether an OMOP concept should be used in defining a study cohort in real-world data.",
    explanation = ellmer::type_string(
      "One short sentence (max 15 words) starting with 'Included because...', 'Excluded because...', or 'Uncertain because...'."
    ),
    score = ellmer::type_enum(
      values = c("include", "uncertain", "exclude"),
      description = "Classification matching the explanation: 'include', 'uncertain', or 'exclude'."
    )
  )

  prompts <- as.list(
    paste0("Concept: '", concepts$standard_concept, "' (mapped from source concept '",
           paste(concepts$source_concept_name),
           "')")
  )

  results <- ellmer::parallel_chat_structured(
    chat = chat,
    prompts = prompts,
    type = concept_review_schema
  )


concepts_reviewed <- dplyr::bind_cols(concepts, results) |>
  dplyr::mutate(
      explanation = stringr::str_extract(explanation, "^[^.!?]+[.!?]") |>
        dplyr::coalesce(.data$explanation) |>
        stringr::str_trim()
    )

  concepts_reviewed
}

getIncludedSytemPrompt <- function(name, clinicalDescription){

  cd <- clinicalDescription |>
    purrr::imap_chr(~ paste(.y, paste(.x, collapse = ","), sep = "-")) |>
    paste(collapse = " - ")

  prompt <- ellmer::interpolate(
    "You are a strict clinical epidemiologist reviewing candidate OMOP concepts to build a codelist for: {{target_phenotype}}.

Use the following clinical description as your source of truth for the clinical idea the cohort is meant to represent:
<clinical_description>
{{clinical_description}}
</clinical_description>

Classification Rules:
- 'include': Concepts that are EXACT clinical matches. They must specifically represent {{target_phenotype}}, true clinical synonyms, or direct included subtypes.
- 'exclude': Concepts that match exclusion criteria, or unrelated entities. STRICT RULES FOR EXCLUSION:
    1. Exclude comorbidities, complications, or risk factors (even if they frequently co-occur).
    2. Exclude conditions at anatomically distinct sites.
    3. Exclude pathologically distinct conditions at the same anatomical site (e.g., a sprain is NOT a fracture). Differential diagnoses or related injuries are NOT clinical synonyms.
- 'uncertain': Ambiguous concepts that could plausibly represent {{target_phenotype}}. STRICT RULES FOR UNCERTAIN:
    1. Isolated signs or symptoms. If a concept is a symptom that could be a clinical presentation or manifestation of {{target_phenotype}} but is not a definitive diagnosis, it MUST be scored as 'uncertain'.
    2. Broad or high-level concepts that require manual clinical review to decide on the sensitivity/specificity trade-off.

Formatting Rule: Write EXACTLY ONE short sentence (under 15 words) starting with 'Included because', 'Excluded because', or 'Uncertain because'.

Examples of format:
- explanation: 'Included because it is a standard clinical term specifically for {{target_phenotype}}.' -> score: 'include'
- explanation: 'Excluded because it represents an anatomically distinct condition or related comorbidity.' -> score: 'exclude'
- explanation: 'Excluded because it is a pathologically distinct condition, not a true synonym.' -> score: 'exclude'
- explanation: 'Uncertain because it is a symptom that could indicate {{target_phenotype}} but lacks diagnostic certainty.' -> score: 'uncertain'
- explanation: 'Uncertain because the term is broader than solely {{target_phenotype}}.' -> score: 'uncertain'",
    target_phenotype = name,
    clinical_description = cd
  )
}
