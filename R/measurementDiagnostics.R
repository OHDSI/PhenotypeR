#' Diagnostics of a conceptSet of measurement codes
#'
#'
#' @param cdm A reference to the cdm object.
#' @param codes A codelist of measurement codes for which to perform diagnostics.
#' @param cohort A cohort in which to perfom the diagnostics of the measurement
#' codes provided. If NULL, the cohort will be set to everyone in observation in
#' the database.
#' @param timing Three options: 1) "any" if the interest is on measurement
#' recorded any time, 2) "during", if interested in measurements while the
#' subject is in the cohort (or in observation if cohort = NULL), and 3)
#' "cohort_start_date" for measurements ocurring at cohort start date (or at
#' "observation_period_start_date if cohort = NULL).
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#'
#' cdm <- mockPhenotypeR()
#'
#' # diagnostics in the database for measurements occurring while patients are
#' # in observation
#' result <- measurementDiagnostics(
#'   cdm = cdm, codes = list("test_codelist" = c(3001467L, 45875977L)),
#'   timing = "during"
#' )
#'
#' # diagnostics subsetted to "my_cohort" for measurements occurring at cohort
#' # start date
#' result_subset <- measurementDiagnostics(
#'   cdm = cdm, codes = list("test_codelist" = c(3001467L, 45875977L)),
#'   cohort = cdm$my_cohort, timing = "cohort_start_date"
#' )
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
measurementDiagnostics <- function(cdm,
                                   codes,
                                   cohort = NULL,
                                   timing = "during") {
  # check inputs
  codes <- omopgenerics::validateConceptSetArgument(codes)
  timing <- omopgenerics::assertChoice(timing, choices = c("any", "during", "cohort_start_date"))
  prefix <- omopgenerics::tmpPrefix()
  if (is.null(cohort)) {
    cli::cli_inform(c(">" = "Creating cohort from observation period table."))
    cohort <- cdm$observation_period |>
      dplyr::mutate(cohort_definition_id = 1L) |>
      dplyr::select(dplyr::all_of(c(
        "cohort_definition_id", "subject_id" = "person_id",
        "cohort_start_date" = "observation_period_start_date",
        "cohort_end_date" = "observation_period_end_date"
      ))) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix)) |>
      omopgenerics::newCohortTable(.softValidation = TRUE)
    cohortName <- NULL
  } else {
    cohort <- omopgenerics::validateCohortArgument(cohort)
    cohortName <- omopgenerics::tableName(cohort)
  }
  installedVersion <- as.character(utils::packageVersion("PhenotypeR"))

  ## measurement cohort
  # settings
  measurementSettings <- purrr::imap_dfr(
    .x = codes,
    .f = ~ dplyr::tibble(cohort_name = paste0(.y, "_", .x), codelist_name = .y, concept_id = .x)
  ) |>
    dplyr::mutate(cohort_definition_id = dplyr::row_number())
  settingsTableName <- omopgenerics::uniqueTableName(prefix = prefix)
  cdm <- omopgenerics::insertTable(
    cdm = cdm,
    name = settingsTableName,
    table = measurementSettings
  )
  cdm[[settingsTableName]] <- cdm[[settingsTableName]] |>
    dplyr::left_join(
      cdm$concept |> dplyr::select(dplyr::all_of(c("concept_id", "concept_name", "domain_id"))),
      by = "concept_id"
    )
  nStart <- dplyr::pull(dplyr::tally(cdm[[settingsTableName]]))
  cdm[[settingsTableName]] <- cdm[[settingsTableName]] |>
    dplyr::filter(tolower(.data$domain_id) == "measurement") |>
    dplyr::compute(name = settingsTableName, temporary = FALSE)
  nEnd <- dplyr::pull(dplyr::tally(cdm[[settingsTableName]]))
  if (nStart != nEnd) cli::cli_inform(c(">" = "{nStart-nEnd} concept{?s} excluded for not being in the measurement domain"))
  addIndex(cdm[[settingsTableName]], cols = "concept_id")

  # cohort
  cli::cli_inform(c(">" = "Subsetting measurement table to the subjects and timing of interest."))
  measurementCohortName <- omopgenerics::uniqueTableName(prefix = prefix)
  # subset to cohort and timing
  measurement <- subsetMeasurementTable(cdm, cohort, timing, measurementCohortName)
  cli::cli_inform(c(">" = "Getting measurement records based on measurement codes."))
  measurement <- measurement |>
    dplyr::rename("concept_id" = "measurement_concept_id") |>
    dplyr::inner_join(
      cdm[[settingsTableName]] |>
        dplyr::select(dplyr::all_of(c("cohort_definition_id", "concept_id", "codelist_name"))),
      by = "concept_id"
    ) |>
    dplyr::select(
      cohort_definition_id,
      subject_id = person_id,
      cohort_start_date = measurement_date,
      measurement_id,
      codelist_name,
      concept_id,
      unit_concept_id,
      value_as_number,
      value_as_concept_id
    ) |>
    dplyr::mutate(cohort_end_date = .data$cohort_start_date) |>
    dplyr::compute(name = measurementCohortName, temporary = FALSE) |>
    omopgenerics::newCohortTable(
      cohortSetRef = measurementSettings,
      .softValidation = TRUE # allow overlap
    ) |>
    PatientProfiles::addDemographics(
      ageGroup = list(c(0, 17), c(18, 64), c(65, 150)),
      priorObservation = FALSE,
      futureObservation = FALSE,
      name = measurementCohortName
    )

  cli::cli_inform(c(">" = "Getting counts for each concept."))
  measurementCounts <- omopgenerics::cohortCount(measurement) |>
    dplyr::inner_join(
      cdm[[settingsTableName]] |> dplyr::collect(), by = "cohort_definition_id"
    ) |>
    omopgenerics::uniteGroup(cols = c("codelist_name", "concept_name")) |>
    omopgenerics::uniteStrata() |>
    omopgenerics::uniteAdditional(cols = "concept_id") |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("number_"),
      names_to = "variable_name",
      values_to = "estimate_value"
    ) |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = CDMConnector::cdmName(cdm),
      variable_name = gsub("_", " ", variable_name),
      variable_level = NA_character_,
      estimate_name = "count",
      estimate_type = "integer",
      estimate_value = as.character(estimate_value)
    ) |>
    dplyr::select(omopgenerics::resultColumns()) |>
    omopgenerics::newSummarisedResult(
      settings = dplyr::tibble(
        result_id = 1L,
        result_type = "measurement_code_count",
        package_name = "PhenotypeR",
        package_version = installedVersion,
        cohort = cohortName,
        timing = timing
      )
    )

  if (dplyr::pull(dplyr::tally(measurement)) == 0) {
    cli::cli_warn("No records with the measurement codes were found.")
    return(measurementCounts)
  }

  ## measurements per subject
  cli::cli_inform(c(">" = "Getting time between records per person."))
  measurementTiming <- measurement |>
    dplyr::group_by(.data$cohort_definition_id, .data$subject_id) |>
    dplyr::arrange(.data$cohort_start_date) |>
    dplyr::mutate(previous_measurement = dplyr::lag(.data$cohort_start_date)) %>%
    dplyr::mutate(time = !!CDMConnector::datediff("previous_measurement", "cohort_start_date")) |>
    dplyr::ungroup() |>
    dplyr::collect() |>
    PatientProfiles::summariseResult(
      group = list(c("codelist_name", "concept_id")),
      includeOverallGroup = FALSE,
      strata = list("sex", "age_group", c("age_group", "sex")),
      includeOverallStrata = TRUE,
      variables = "time",
      estimates = c("min", "q25", "median", "q75", "max"),
      counts = TRUE
    ) |>
    suppressMessages() |>
    groupIdToName(newSet = cdm[[settingsTableName]] |> dplyr::collect()) |>
    dplyr::select(!dplyr::starts_with("additional")) |>
    omopgenerics::uniteAdditional(cols = c("concept_id")) |>
    dplyr::select(omopgenerics::resultColumns())
  measurementTiming <- measurementTiming |>
    omopgenerics::newSummarisedResult(
      settings = omopgenerics::settings(measurementTiming) |>
        dplyr::mutate(
          result_type = "measurements_taken",
          package_name = "PhenotypeR",
          package_version = installedVersion,
          group = "codelist_name &&& concept_name",
          additional = "concept_id",
          timing = timing,
          cohort = cohortName
        )
    )

  ## measurement value
  cli::cli_inform(c(">" = "Summarising measurement results - value as number."))
  # as numeric
  # 1) summarise numbers by unit
  measurementNumeric <- measurement |>
    dplyr::select(!"value_as_concept_id") |>
    dplyr::collect() %>%
    split(.$concept_id) |>
    purrr::map(.f = \(x){
      unitsCode <- x |> dplyr::pull("unit_concept_id") |> unique() |> as.character()
      unitsCode[is.na(unitsCode)] <- "NA"
      x |>
        tidyr::pivot_wider(names_from = "unit_concept_id", values_from = "value_as_number") |>
        PatientProfiles::summariseResult(
          group = list(c("codelist_name", "concept_id")),
          includeOverallGroup = FALSE,
          strata = list("sex", "age_group", c("age_group", "sex")),
          includeOverallStrata = TRUE,
          variables = unitsCode,
          estimates = c("min", "q25", "median", "q75", "max", "count_missing", "percentage_missing"),
          counts = FALSE,
          weights = NULL
        ) |>
        suppressMessages()
    }) |>
    omopgenerics::bind() |>
    transformMeasurementValue(
      cdm = cdm, newSet = cdm[[settingsTableName]] |> dplyr::collect(),
      cohortName = cohortName, installedVersion = installedVersion, timing = timing
    )
  # 2) counts of units
  measurementUnit <- measurement |>
    dplyr::mutate(unit_concept_id = as.character(unit_concept_id)) |>
    PatientProfiles::summariseResult(
      group = list(c("codelist_name", "concept_id")),
      includeOverallGroup = FALSE,
      strata = list("sex", "age_group", c("age_group", "sex")),
      includeOverallStrata = TRUE,
      variables = c("unit_concept_id"),
      estimates = c("count", "percentage"),
      counts = FALSE,
      weights = NULL
    ) |>
    suppressMessages() |>
    transformMeasurementConcept(
      cdm = cdm, newSet = cdm[[settingsTableName]] |> dplyr::collect(),
      variableName = "unit_as_concept_id", cohortName = cohortName,
      installedVersion = installedVersion, timing = timing
    )

  # counts of as concept
  cli::cli_inform(c(">" = "Summarising measurement results - value as concept"))
  measurementConcept <- measurement |>
    dplyr::mutate(value_as_concept_id = as.character(value_as_concept_id)) |>
    PatientProfiles::summariseResult(
      group = list(c("codelist_name", "concept_id")),
      includeOverallGroup = FALSE,
      strata = list("sex", "age_group", c("age_group", "sex")),
      includeOverallStrata = TRUE,
      variables = "value_as_concept_id",
      estimates = c("count", "percentage"),
      counts = FALSE,
      weights = NULL
    ) |>
    suppressMessages() |>
    transformMeasurementConcept(
      cdm = cdm, newSet = cdm[[settingsTableName]] |> dplyr::collect(),
      variableName = "value_as_concept_id", cohortName = cohortName,
      installedVersion = installedVersion, timing = timing
    )

  cli::cli_inform(c(">" = "Binding all diagnostic results"))
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))
  return(
    omopgenerics::bind(
      measurementCounts, measurementTiming, measurementNumeric, measurementUnit,
      measurementConcept
    )
  )
}


groupIdToName <- function(x, newSet) {
  x |>
    visOmopResults::splitGroup() |>
    dplyr::inner_join(
      newSet |>
        dplyr::select(dplyr::all_of(c("concept_id", "concept_name"))) |>
        dplyr::mutate(concept_id = as.character(.data$concept_id)),
      by = "concept_id"
    ) |>
    visOmopResults::uniteGroup(cols = c("codelist_name", "concept_name"))
}

subsetMeasurementTable <- function(cdm, cohort, timing, name) {
  # if ANY : no need to filter for dates
  # if DURING : needs to be in observation / in cohort
  # if COHORT_START_DATE : cohort_start_date/observation_period_start_date = measurement date
  if (is.null(cohort) & timing == "any") {
    return(
      cdm$measurement |>
        dplyr::compute(name = name, temporary = FALSE)
    )
  }
  cohort <- CohortConstructor::addCohortTableIndex(cohort)
  if (timing == "during") {
    measurement <- cdm$measurement |>
      dplyr::inner_join(
        cohort |>
          dplyr::select(
            "person_id" = "subject_id", "cohort_start_date", "cohort_end_date"
          ),
        by = "person_id",
        relationship = "many-to-many"
      ) |>
      dplyr::filter(
        .data$measurement_date >= .data$cohort_start_date,
        .data$measurement_date <= .data$cohort_end_date
      ) |>
      dplyr::select(!dplyr::starts_with("cohort_")) |>
      dplyr::compute(name = name, temporary = FALSE)
  }
  if (timing == "cohort_start_date") {
    measurement <-   measurement <- cdm$measurement |>
      dplyr::inner_join(
        cohort |>
          dplyr::select(
            "person_id" = "subject_id", "measurement_date" = "cohort_start_date"
          ),
        by = c("person_id", "measurement_date"),
        relationship = "many-to-many"
      ) |>
      dplyr::compute(name = name, temporary = FALSE)
  }
  if (timing == "any") {
    measurement <-   measurement <- cdm$measurement |>
      dplyr::inner_join(
        cohort |>
          dplyr::select("person_id" = "subject_id") |>
          dplyr::distinct(),
        by = c("person_id")
      ) |>
      dplyr::compute(name = name, temporary = FALSE)
  }
  return(measurement)
}

addIndex <- function(cohort, cols) {
  # From CohortConstructor
  cdm <- omopgenerics::cdmReference(cohort)
  name <- omopgenerics::tableName(cohort)

  tblSource <- attr(cohort, "tbl_source")
  if(is.null(tblSource)){
    return(invisible(NULL))
  }
  dbType <- attr(tblSource, "source_type")
  if(is.null(dbType)){
    return(invisible(NULL))
  }

  if (dbType == "postgresql") {
    con <- attr(cdm, "dbcon")
    schema <- attr(cdm, "write_schema")
    if(length(schema) > 1){
      prefix <- attr(cdm, "write_schema")["prefix"]
      schema <- attr(cdm, "write_schema")["schema"]
    } else {
      prefix <- NULL
    }

    existingIndex <- DBI::dbGetQuery(con,
                                     paste0("SELECT * FROM pg_indexes WHERE",
                                            " schemaname = '",
                                            schema,
                                            "' AND tablename = '",
                                            paste0(prefix, name),
                                            "';"))
    if(nrow(existingIndex) > 0){
      cli::cli_inform("Index already existing so no new index added.")
      return(invisible(NULL))
    } else {
      cli::cli_inform("Adding indexes to table")
    }

    cols <- paste0(cols, collapse = ",")

    query <- paste0(
      "CREATE INDEX ON ",
      paste0(schema, ".", prefix, name),
      " (",
      cols,
      ");"
    )
    suppressMessages(DBI::dbExecute(con, query))
  }

  return(invisible(NULL))
}

transformMeasurementValue <- function(x, cdm, newSet, cohortName, installedVersion, timing) {
  x |>
    dplyr::select(!c("variable_level", "additional_name", "additional_level")) |>
    dplyr::left_join(
      cdm$concept |>
        dplyr::select(
          "variable_name" = "concept_id",
          "variable_level" = "concept_name"
        ) |>
        dplyr::mutate(variable_name = as.character(variable_name)) |>
        dplyr::collect(),
      by = "variable_name"
    ) |>
    dplyr::mutate(
      unit_as_concept_id = variable_name,
      variable_name = "unit_as_concept_name"
    ) |>
    groupIdToName(newSet = newSet) |>
    omopgenerics::uniteAdditional(cols = c("concept_id", "unit_as_concept_id")) |>
    dplyr::select(omopgenerics::resultColumns()) |>
    omopgenerics::newSummarisedResult(
      settings = omopgenerics::settings(x) |>
        dplyr::mutate(
          result_type = "measurement_value_as_numeric",
          package_name = "PhenotypeR",
          package_version = installedVersion,
          group = "codelist_name &&& concept_name",
          additional = "concept_id &&& unit_as_concept_id",
          timing = timing,
          cohort = cohortName
        )
    )
}

transformMeasurementConcept <- function(x, cdm, newSet, variableName, cohortName,
                                        installedVersion, timing) {
  if (variableName == "value_as_concept_id") {
    resultType <- "measurement_value_as_concept"
  } else {
    resultType <- "measurement_value_as_numeric"
  }
  x |>
    dplyr::select(!c("additional_name", "additional_level")) |>
    dplyr::rename(!!variableName := "variable_level") |>
    dplyr::left_join(
      cdm$concept |>
        dplyr::select(
          "variable_level" = "concept_name",
          !!variableName := "concept_id"
        ) |>
        dplyr::mutate(!!variableName := as.character(.data[[variableName]])) |>
        dplyr::collect(),
      by = variableName
    ) |>
    dplyr::mutate(
      variable_name = gsub("_id", "_name", variableName)
    ) |>
    groupIdToName(newSet = newSet) |>
    omopgenerics::uniteAdditional(cols = c("concept_id", variableName)) |>
    dplyr::select(omopgenerics::resultColumns()) |>
    omopgenerics::newSummarisedResult(
      settings = omopgenerics::settings(x) |>
        dplyr::mutate(
          result_type = resultType,
          package_name = "PhenotypeR",
          package_version = installedVersion,
          group = "codelist_name &&& concept_name",
          additional = paste0("concept_id &&& ", variableName),
          timing = timing,
          cohort = cohortName
        )
    )
}
