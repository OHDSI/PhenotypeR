
#' Get cohort expectations using an LLM
#'
#' @param chat An ellmer chat
#' @param phenotypes Either a vector of phenotype names or results from
#' PhenotypeR.
#'
#' @returns A tibble with expectations about the cohort.
#' @export
#'
getCohortExpectations <- function(chat, phenotypes){

  rlang::check_installed("ellmer")

  # if summarised result, pull out cohort names
  if(isTRUE(inherits(phenotypes, "summarised_result"))){
    phenotypes <- phenotypes |>
      omopgenerics::filterSettings(.data$result_type == "summarise_cohort_attrition") |>
      dplyr::pull("group_level") |>
      unique()
  }
  # otherwise should be character vector
  omopgenerics::assertCharacter(phenotypes)

  expectations <- list()
  for(i in seq_along(phenotypes)){
    working_phenotype <- phenotypes[[i]]
    if(length(phenotypes)>1){
    other_phenotype <- phenotypes[which(phenotypes!=working_phenotype)]
    } else {
    other_phenotype <- NULL
    }
    expectations[[i]] <- fetchExpectations(chat = chat,
                                           name = phenotypes[[i]],
                                           others = other_phenotype)
  }

  expectations |>
    dplyr::bind_rows() |>
    dplyr::rename("cohort_name" = "name") |>
    dplyr::mutate("source" = chat$get_model())
}

# go and get expectations cohort by cohort
fetchExpectations <- function(chat, name, others){

  cli::cli_inform("Getting expectations for {name}")

  # start from a clean slate
  chat <- chat$clone()$set_turns(list())

  system_prompt <- "You are a terse assistant helping a user (with equivalent medical knowelge to that of a well-informed member of the lay public) working with real-world health care data to build a set of expectations about the characteristics they should see for the study cohorts they create."
  system_prompt <- paste0(system_prompt,
                          "Study cohorts can include, but not limited to, people with a particular diagnosis, people having a routine lab test, people having a procedure, and people who are users of a medication.")
  system_prompt <- paste0(system_prompt,
                          "Unless otherwise specified, assume no additional eligibility criteria has been applied when identifying study cohorts.")
  system_prompt <- paste0(system_prompt,
                          "Unless specified, real world data being used may be drawn from different settings (such as primary care and hospital care) and types (such as electronic healthcare records or insurance data).")
  system_prompt <- paste0(system_prompt,
                          "For medications, use ATC classifications where appropriate, but otherwise use drug ingredient names, and avoid abbreviations.")
  system_prompt <- paste0(system_prompt,
                          "Use British spelling.")
  system_prompt <- paste0(system_prompt,
                          "When giving a set of most common characteristics, give this formatted as a sentence and only capitalise words where appropriate.")
  chat <- chat$set_system_prompt(value = system_prompt)

  if(is.null(others)){
    type_my_df <- ellmer::type_array(
      items = ellmer::type_object(
        clinical_description = ellmer::type_string(),
        frequently_seen = ellmer::type_string(),
        median_age_estimate_low = ellmer::type_number(),
        median_age_estimate_high = ellmer::type_number(),
        median_age_elaboration = ellmer::type_string(),
        proportion_male_estimate_low = ellmer::type_number(),
        proportion_male_estimate_high = ellmer::type_number(),
        proportion_male_elaboration = ellmer::type_string(),
        five_year_survival_estimate_low = ellmer::type_number(),
        five_year_survival_estimate_high = ellmer::type_number(),
        five_year_survival_elaboration = ellmer::type_string(),
        comorbidities = ellmer::type_string(),
        comorbidities_elaboration = ellmer::type_string(),
        signs_symptoms = ellmer::type_string(),
        signs_symptoms_elaboration = ellmer::type_string(),
        medications = ellmer::type_string(),
        medications_elaboration = ellmer::type_string()
      )
    )
  } else{
  type_my_df <- ellmer::type_array(
    items = ellmer::type_object(
      clinical_description = ellmer::type_string(),
      frequently_seen = ellmer::type_string(),
      median_age_estimate_low = ellmer::type_number(),
      median_age_estimate_high = ellmer::type_number(),
      median_age_elaboration = ellmer::type_string(),
      proportion_male_estimate_low = ellmer::type_number(),
      proportion_male_estimate_high = ellmer::type_number(),
      proportion_male_elaboration = ellmer::type_string(),
      five_year_survival_estimate_low = ellmer::type_number(),
      five_year_survival_estimate_high = ellmer::type_number(),
      five_year_survival_elaboration = ellmer::type_string(),
      comorbidities = ellmer::type_string(),
      comorbidities_elaboration = ellmer::type_string(),
      signs_symptoms = ellmer::type_string(),
      signs_symptoms_elaboration = ellmer::type_string(),
      medications = ellmer::type_string(),
      medications_elaboration = ellmer::type_string(),
      overlap = ellmer::type_string(),
      timing = ellmer::type_string()
    )
  )
  }

  prompt <- "Give a one or two sentence clinical description of {{name}}, with focus on disease aetiology.
       Give a one or two sentence terse summary of how frequently seen is {{name}} and whether we can expect to identify cases in different types of real-world health care data.
       What is the median age for incident cases presenting with {{name}} - give a range with a low and high plausible value? Provide sentence giving elaboration on age at which individuals typically present.
       What proportion would you expect of {{name}} cases to be male (between 0 and 1) - give a range with a low and high plausible value? Provide sentence giving elaboration on sex of individuals presenting.
       What is expected median survival 1 year and 5 years after presenting with with {{name}} (between 0 all died and 1 all survived) - give a range with a low and high plausible value? Provide one sentence giving elaboration on mortality of individuals presenting.
       Give up to 10 most common commorbidies in people with {{name}}. Provide one sentence providing elaboration for why we would expect to see these comorbidities among cases.
       Give up to 10 most common signs and symptoms seen for people with {{name}} (use clinical terms). Provide one sentence providing elaboration for why we would expect to see these signs and symptoms among cases.
       Give up to 10 most common medications taken by people with {{name}}. Provide one sentence providing elaboration for why we would expect to see these medications among cases."

  if(!is.null(others)){
    others <- paste0(others, collapse = ", ")
    prompt <- paste0(
      prompt,
      "In my real-world data I will create a study cohort of {{name}} and more cohorts for {{others}} (will call these the other cohorts). Only consider these specified other cohorts.
       For {{name}}, how much overlap (use ranges of percentages where possible) would you expect to see with the named other cohorts (in terms of people appearing in both?). Provide a sentence of elaboration.
       For people in {{name}} who also appear in other cohorts what would their relative timing of entry into other cohorts typically look like (which cohort would they enter first, or would they enter both at the same time?). Give estimates in days or years where appropriate. Provide a sentence of elaboration."
    )
  }

  prompt <- paste0(
    prompt,
   "No decimal places for age. Two decimal places for survival. Give only full names for commorbidities, signs and symptoms, and medications (no abbreviations, no explanation)."
   )

 chat_output <- chat$chat_structured(
    ellmer::interpolate(prompt),
    type = type_my_df,
    echo = "none")   |>
    dplyr::mutate(median_age = paste0(.data$median_age_estimate_low,
                                      " to ",
                                      .data$median_age_estimate_high,
                                      " (",
                                      .data$median_age_elaboration, ")"),
                  proportion_male = paste0(paste0(.data$proportion_male_estimate_low*100, "%"),
                                           " to ",
                                           paste0(.data$proportion_male_estimate_high*100, "%"),
                                           " (",
                                           .data$proportion_male_elaboration, ")"),
                  five_year_survival = paste0(paste0(.data$five_year_survival_estimate_low*100, "%"),
                                              " to ",
                                              paste0(.data$five_year_survival_estimate_high*100, "%"),
                                           " (",
                                           .data$five_year_survival_elaboration, ")"),
                  comorbidities = paste0(.data$comorbidities,
                                         " (",
                                         .data$comorbidities_elaboration, ")"),
                  signs_symptoms = paste0(.data$signs_symptoms,
                                         " (",
                                         .data$signs_symptoms_elaboration, ")"),
                  medications = paste0(.data$medications,
                                         " (",
                                       .data$medications_elaboration, ")")) |>
    dplyr::select(-c("median_age_estimate_low", "median_age_estimate_high", "median_age_elaboration",
                     "proportion_male_estimate_low", "proportion_male_estimate_high", "proportion_male_elaboration",
                     "five_year_survival_estimate_low", "five_year_survival_estimate_high", "five_year_survival_elaboration",
                     "comorbidities_elaboration", "signs_symptoms_elaboration", "medications_elaboration")) |>
    dplyr::mutate_all(as.character)

rename_map <- c(
  "Clinical description" = "clinical_description",
  "Frequency" = "frequently_seen",
  "Median age of incident cases" = "median_age",
  "Percentage male" = "proportion_male",
  "Survival at five years" = "five_year_survival",
  "Frequently seen comorbidities" = "comorbidities",
  "Frequently seen signs and symptoms" = "signs_symptoms",
  "Frequently seen medications" = "medications",
  "Cohort overlap" = "overlap",
  "Cohort timing" = "timing"
)
rename_map <- rename_map[rename_map %in% names(chat_output)]
chat_output <- chat_output |>
  dplyr::rename(!!!rlang::set_names(rename_map, names(rename_map)))

chat_output <- chat_output |>
  tidyr::pivot_longer(cols = dplyr::any_of(c("Clinical description",
                                 "Frequency",
                                 "Median age of incident cases",
                                 "Percentage male",
                                 "Survival at five years",
                                 "Cohort overlap",
                                 "Cohort timing",
                                 "Frequently seen comorbidities",
                                 "Frequently seen signs and symptoms",
                                 "Frequently seen medications")),
                        names_to = "estimate") |>
    dplyr::mutate(name = name) |>
    dplyr::relocate("name")

chat_output <- chat_output |>
  dplyr::mutate(
    diagnostics = dplyr::case_when(estimate == "Clinical description"  ~ "cohort_count",
                               estimate == "Frequency"  ~ "cohort_count",
                               estimate == "Frequency"  ~ "cohort_characteristics",
                               estimate == "Median age of incident cases"  ~ "cohort_characteristics",
                               estimate == "Percentage male"  ~ "cohort_characteristics",
                               estimate == "Survival at five years"  ~ "cohort_survival",
                               estimate == "Cohort overlap"  ~ "compare_cohorts",
                               estimate == "Cohort timing"  ~ "compare_cohorts",
                               estimate == "Frequently seen comorbidities"  ~ "large_scale_characteristics, compare_large_scale_characteristics",
                               estimate == "Frequently seen signs and symptoms"  ~ "large_scale_characteristics, compare_large_scale_characteristics",
                               estimate == "Frequently seen medications"  ~ "large_scale_characteristics, compare_large_scale_characteristics")
  )

chat_output

}


#' Create a table summarising cohort expectations
#'
#' @inheritParams expectationsDoc
#' @param type Table type to view results. See visOmopResults::tableType()
#' for supported tables.
#'
#' @returns Summary of cohort expectations
#' @export
#'
tableCohortExpectations <- function(expectations, type = "reactable"){

  omopgenerics::assertChoice(type, visOmopResults::tableType())
  if(isFALSE(all(
    c("cohort_name", "estimate", "value", "source") %in%
  colnames(expectations)))){
    cli::cli_abort("expectations must be a dataframe or tibble with the following columns: cohort_name, estimate, value, and source")
  }

  expectations <- expectations |>
    dplyr::select(dplyr::all_of(c("cohort_name", "estimate", "value", "source")))

  # custom reactable
  if(type == "reactable"){
  rlang::check_installed("reactable")
  leaders <- !duplicated(expectations$cohort_name)
  reactable::reactable(
    expectations[leaders, "cohort_name", drop = FALSE],
    bordered = FALSE,
    onClick = "expand",
    resizable = TRUE,
    wrap = FALSE,
    class = "packages-table",
    rowStyle = list(cursor = "pointer"),
    theme = reactable::reactableTheme(
      cellPadding = "8px 12px",
      headerStyle = list(display = "none")
    ),
    columns = list(
      cohort_name = reactable::colDef(
        name = NULL
      )
    ),
    details = function(index) {
      person <- expectations$cohort_name[leaders][index]
      rows <- expectations[expectations$cohort_name == person, ]
      lines <- lapply(seq_len(nrow(rows)), function(i) {
        htmltools::div(
          style = "
          padding: 6px 10px;
          margin-bottom: 6px;
          border-bottom: 1px solid #ccc;
        ",
          htmltools::tagList(
            htmltools::span(style = "font-weight: bold;", rows$estimate[i]),
            paste0(": ", rows$value[i]),
            htmltools::span(style = "font-style: italic;", " (Source: "),
            htmltools::span(style = "font-style: italic;", rows$source[i]),
            htmltools::span(style = "font-style: italic;", ")")
          )
        )
      })
      htmltools::tagList(
        htmltools::div(
          style = "padding: 10px; background-color: #f9f9f9;",
          lines
        )
      )
    }
  )
  } else {
    rlang::check_installed("visOmopResults", version = "1.0.0")
    visOmopResults::visTable(expectations,
                             groupColumn = "cohort_name",
                             rename = c("Characteristic" = "estimate",
                                        "Expectation" = "value"),
                             type = type)
  }

}


