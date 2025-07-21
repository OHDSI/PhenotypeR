
#' Get cohort expectations using an LLM
#'
#' @param chat An ellmer chat
#' @param phenotpyes Either a vector of phenotype names or results from
#' PhenotypeR.
#'
#' @returns A tibble with expectations about the cohort.
#' @export
#'
getCohortExpectations <- function(chat, phenotpyes){

  # if summarised result, pull out cohort names
  if(isTRUE(inherits(phenotpyes, "summarised_result"))){
    phenotpyes <- phenotpyes |>
      omopgenerics::filterSettings(result_type == "summarise_cohort_attrition") |>
      dplyr::pull("group_level") |>
      unique()
  }
  # otherwise should be character vector
  omopgenerics::assertCharacter(phenotpyes)

  expectations <- list()
  for(i in seq_along(phenotpyes)){
    expectations[[i]] <- fetchExpectations(chat = chat,
                                            name = phenotpyes[[i]])
  }

  expectations |>
    dplyr::bind_rows()

}

# go and get expectations cohort by cohort
fetchExpectations <- function(chat, name){

  cli::cli_inform("Getting expectations for {name}")

  # start from a clean slate
  chat <- chat$clone()$set_turns(list())

  type_my_df <- ellmer::type_array(
    items = ellmer::type_object(
      clinical_description = ellmer::type_string(),
      median_age_incident = ellmer::type_number(),
      median_age_prevalent = ellmer::type_number(),
      proportion_male = ellmer::type_number(),
      one_year_survival = ellmer::type_number(),
      five_year_survival = ellmer::type_number(),
      comorbidities = ellmer::type_string(),
      signs_symptoms = ellmer::type_string(),
      medications = ellmer::type_string()
    )
  )

  chat$chat_structured(
    ellmer::interpolate(
      "Give a one or two sentence clinical description of {{name}}, with focus on disease aetiology.
       What is the median age for incident cases being diagnosed with {{name}}?
       What is the median age for prevalent cases with {{name}}?
       What proportion would you expect of {{name}} cases to be male (between 0 and 1)?
       What is expected all-cause mortality 1 year and 5 years after being diagnosed with with {{name}} (between 0 all died and 1 all survived)?
       Give up to 10 most common commorbidies in people with {{name}}.
       Give up to 10 most common signs and symptoms seen for people with {{name}} (use clinical terms).
       Give up to 10 most common medications taken by people with {{name}}.
       No decimal places for age. Two decimal places for survival. Give only full names for commorbidities, signs and symptoms, and medications (no abbreviations, no explanation)."),
    type = type_my_df)   %>%
    dplyr::mutate(proportion_male = paste0(proportion_male*100, "%"),
                  one_year_survival = paste0(one_year_survival*100, "%"),
                  five_year_survival = paste0(five_year_survival*100, "%")) |>
    dplyr::mutate_all(as.character) %>%
    dplyr::rename("Clinical description" = "clinical_description",
                  "Median age of incident cases" = "median_age_incident",
                  "Median age of prevalent cases" = "median_age_prevalent",
                  "Percentage male" = "proportion_male",
                  "Survival at one year" = "one_year_survival",
                  "Survival at five years" = "five_year_survival",
                  "Frequently seen comorbidities" = "comorbidities",
                  "Frequently seen signs and symptoms" = "signs_symptoms",
                  "Frequently seen medications" = "medications") |>
    tidyr::pivot_longer(cols = c("Clinical description",
                                 "Median age of incident cases",
                                 "Median age of prevalent cases",
                                 "Percentage male",
                                 "Survival at one year",
                                 "Survival at five years",
                                 "Frequently seen comorbidities",
                                 "Frequently seen signs and symptoms",
                                 "Frequently seen medications"),
                        names_to = "estimate") %>%
    dplyr::mutate(name = name) |>
    dplyr::relocate("name")

}


#' View cohort expectations
#'
#' @param expectations Data frame or tibble with cohort expectations
#' @param type Table type to view results. See visOmopResults::tableType()
#' for supported tables.
#'
#' @returns Summary of cohort expectations
#' @export
#'
viewCohortExpectations <- function(expectations, type = "gt"){

  rlang::check_installed("visOmopResults", version = "1.0.0")

  omopgenerics::assertChoice(type, c("narrative", visOmopResults::tableType()))

  if(type == "narrative"){
    cli::cli_abort("narrative summary not yet implemented")
  }

  visOmopResults::visTable(expectations,
                           groupColumn = "name",
                           rename = c("Characteristic" = "estimate",
                                      "Expectation" = "value"),
                           type = type)
}


