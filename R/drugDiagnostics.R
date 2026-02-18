
summariseDrugUse <- function(cdm,
                             codes,
                             byConcept = TRUE,
                             byYear = FALSE,
                             bySex = FALSE,
                             ageGroup = NULL,
                             dateRange = as.Date(c(NA, NA)),
                             personSample = 20000,
                             checks = c("missing", "exposureDuration",
                                        "type", "route", "dose",
                                        "quantity", "daysBetween")) {
  # validate personSample
  cdm <- omopgenerics::validateCdmArgument(cdm = cdm)
  omopgenerics::assertNumeric(personSample, integerish = TRUE, min = 1, null = TRUE, length = 1)
  if (!is.null(personSample)) {
    nm <- omopgenerics::uniqueTableName()
    cohort <- CohortConstructor::demographicsCohort(cdm = cdm, name = nm) |>
      CohortConstructor::sampleCohorts(n = personSample)
    on.exit(omopgenerics::dropSourceTable(cdm = cdm, name = nm))
    subsetName <- paste0(personSample, " random individuals")
  } else {
    cohort <- NULL
    subsetName <- "None"
  }

  summariseDrugUseInternal(
    cdm = cdm,
    codes = codes,
    cohort = cohort,
    subsetName = subsetName,
    timing = "any",
    byConcept = byConcept,
    byYear = byYear,
    bySex = bySex,
    ageGroup = ageGroup,
    dateRange = dateRange,
    checks = checks
  )
}

summariseCohortDrugUse <- function(cohort,
                                   codes = NULL,
                                   timing = "during",
                                   byConcept = TRUE,
                                   byYear = FALSE,
                                   bySex = FALSE,
                                   ageGroup = NULL,
                                   dateRange = as.Date(c(NA, NA)),
                                   checks = c("missing", "exposureDuration",
                                              "type", "route", "dose",
                                              "quantity", "daysBetween")) {
  if (is.null(codes)) {
    codes <- omopgenerics::newCodelist(attr(cohort, "cohort_codelist"))
  }
  summariseDrugUseInternal(
    cdm = omopgenerics::cdmReference(cohort),
    codes = codes,
    cohort = cohort,
    subsetName = omopgenerics::tableName(cohort),
    timing = timing,
    byConcept = byConcept,
    byYear = byYear,
    bySex = bySex,
    ageGroup = ageGroup,
    dateRange = dateRange,
    checks = checks
  )
}

summariseDrugUseInternal <- function(cdm,
                                     codes,
                                     cohort,
                                     subsetName,
                                     timing,
                                     byConcept,
                                     byYear,
                                     bySex,
                                     ageGroup,
                                     dateRange,
                                     checks,
                                     call = parent.frame()) {
  # initial checks
  omopgenerics::validateCdmArgument(cdm = cdm, call = call)
  codes <- omopgenerics::validateConceptSetArgument(conceptSet = codes, call = call)
  cdm <- omopgenerics::cdmReference(table = cohort)
  omopgenerics::assertChoice(timing, choices = c("any", "during", "cohort_start_date"), call = call)
  omopgenerics::assertLogical(byConcept, length = 1, call = call)
  omopgenerics::assertLogical(byYear, length = 1, call = call)
  omopgenerics::assertLogical(bySex, length = 1, call = call)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup = ageGroup, call = call)
  if (is.null(dateRange)) {
    dateRange <- c(NA, NA)
  }
  dateRange <- as.Date(dateRange)
  omopgenerics::assertDate(dateRange, length = 2, na = TRUE, call = call)
  omopgenerics::assertChoice(checks, choices = c("missing", "exposureDuration", "type", "route", "dose", "quantity", "daysBetween"), call = call)

  # prepare subset
  nm <- omopgenerics::uniqueTableName()
  drugRecords <- subsetDrugRecords(
    cdm = cdm,
    codes = codes,
    cohort = cohort,
    timing = timing,
    dateRange = dateRange,
    name = nm
  )
  on.exit(omopgenerics::dropSourceTable(cdm = cdm, name = nm))

  # add stratifications
  drugRecords <- addStratifications(drugRecords, byConcept, byYear, bySex, ageGroup,
                                    type = TRUE,
                                    route = TRUE,
                                    name = nm)
  if(isFALSE(byConcept)){
    cols <- c("drug_type", "route")
    combinations <- expand.grid(replicate(length(cols),
                                          c(TRUE, FALSE),
                                          simplify = FALSE))
    colnames(combinations) <- cols
    combinations$codelist_name <- TRUE
    combinations <- combinations |>
      dplyr::select(c("codelist_name",
                      "drug_type",
                      "route"))
    group <- apply(combinations, 1, function(row) {
      names(row)[as.logical(row)]
    })
  } else {
    cols <- c("concept_name",  "drug_type", "route")
    combinations <- expand.grid(replicate(length(cols),
                                          c(TRUE, FALSE),
                                          simplify = FALSE))
    colnames(combinations) <- cols
    combinations$source_concept_name <- combinations$concept_name
    combinations$codelist_name <- TRUE
    combinations <- combinations |>
      dplyr::select(c("codelist_name",
                      "concept_name",
                      "source_concept_name",
                      "drug_type",
                      "route")) |>
      dplyr::arrange(.data$concept_name, .data$drug_type, .data$route)

    group <- apply(combinations, 1, function(row) {
      names(row)[as.logical(row)]
    })
  }
  strata <- c("year"[byYear], "sex"[bySex], names(ageGroup)) |>
    as.list()

  drugRecordsDf <- drugRecords |>
    dplyr::collect()
  attr(drugRecordsDf, "tbl_source") <- omopgenerics::newLocalSource()

  result <- list(empty = omopgenerics::emptySummarisedResult())
  for(i in seq_along(group)){
  result[[paste0("counts_", i)]] <- summariseCounts(drugRecords, group, strata) |>
    drugResultSettings(subset = subsetName, check = "counts", timing = timing)
  }

  # # missing
  # if ("missing" %in% checks) {
  #   result$missing <- summariseMissing(drugRecords, group, strata) |>
  #     drugResultSettings(subset = subsetName, check = "missing", timing = timing)
  # }

  #  exposureDuration
  if ("exposureDuration" %in% checks) {
   for(i in seq_along(group)){
     result[[paste0("exposureDuration_", i)]] <- summariseExposureDuration(drugRecordsDf, group[[i]], strata) |>
       drugResultSettings(subset = subsetName, check = "exposureDuration", timing = timing)
   }
  }

  # # type
  # if ("type" %in% checks) {
  #   result$type <- summariseType(drugRecords, group, strata) |>
  #     drugResultSettings(subset = subsetName, check = "type", timing = timing)
  # }
  #
  # # route
  # if ("route" %in% checks) {
  #   result$route <- summariseRoute(drugRecords, group, strata) |>
  #     drugResultSettings(subset = subsetName, check = "route", timing = timing)
  # }
  #
  # # quantity
  if ("quantity" %in% checks) {
    for(i in seq_along(group)){
      result[[paste0("quantity", i)]] <- summariseQuantity(drugRecordsDf, group[[i]], strata) |>
      drugResultSettings(subset = subsetName, check = "quantity", timing = timing)
    }
  }
  # dose
  if ("dose" %in% checks) {
    ingredient <- findIngredient(codes = codes, cdm = cdm) |>
      reportIngredient()
    if (nrow(ingredient) > 0) {
      for(i in seq_along(group)){
        result[[paste0("dose", i)]] <- summariseDose(drugRecords, group[[i]], strata, ingredient) |>
        drugResultSettings(subset = subsetName, check = "dose", timing = timing)
      }
    }
  }

  # daysBetween
  if ("daysBetween" %in% checks) {
    for(i in seq_along(group)){
      result[[paste0("daysBetween_", i)]] <- summariseDaysBetween(drugRecordsDf, group[[i]], strata) |>
        drugResultSettings(subset = subsetName, check = "daysBetween", timing = timing)
    }
    }

  omopgenerics::bind(result)
}
subsetDrugRecords <- function(cdm, codes, cohort, timing, dateRange, name) {

  nm <- omopgenerics::uniqueTableName()
  codes <- dplyr::as_tibble(codes) |>
    dplyr::rename("drug_concept_id" = "concept_id")
  cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = codes)
  on.exit(omopgenerics::dropSourceTable(cdm = cdm, name = nm))
  # TODO add index
  drugRecords <- cdm$drug_exposure |>
    dplyr::inner_join(cdm[[nm]], by = "drug_concept_id")

  if (!is.null(cohort)) {
    if (timing == "any") {
      drugRecords <- drugRecords |>
        dplyr::inner_join(
          cohort |>
            dplyr::select("person_id" = "subject_id") |>
            dplyr::distinct(),
          by = "person_id"
        )
    } else if (timing == "during") {
      drugRecords <- drugRecords |>
        dplyr::inner_join(
          cohort |>
            dplyr::select(
              "person_id" = "subject_id",
              "cohort_start_date",
              "cohort_end_date"
            ),
          by = "person_id"
        ) |>
        dplyr::filter(
          .data$drug_exposure_start_date >= .data$cohort_start_date &
            .data$drug_exposure_start_date <= .data$cohort_end_date
        ) |>
        dplyr::select(!c("cohort_start_date", "cohort_end_date"))
    } else if (timing == "cohort_start_date") {
      drugRecords <- drugRecords |>
        dplyr::inner_join(
          cohort |>
            dplyr::select(
              "person_id" = "subject_id",
              "drug_exposure_start_date" = "cohort_start_date"
            ) |>
            dplyr::distinct(),
          by = c("person_id", "drug_exposure_start_date")
        )
    }
  }

  startDate <- dateRange[1]
  endDate <- dateRange[2]
  if (is.na(startDate)) {
    if (!is.na(endDate)) {
      drugRecords <- drugRecords |>
        dplyr::filter(.data$drug_exposure_start_date <= .env$endDate)
    }
  } else {
    if (is.na(endDate)) {
      drugRecords <- drugRecords |>
        dplyr::filter(.data$drug_exposure_start_date >= .env$startDate)
    } else {
      drugRecords <- drugRecords |>
        dplyr::filter(
          .data$drug_exposure_start_date >= .env$startDate &
            .data$drug_exposure_start_date <= .env$endDate
        )
    }
  }

  drugRecords |>
    dplyr::compute(name = name)
}
addStratifications <- function(drugRecords, byConcept, byYear, bySex, ageGroup, type, route, name) {
  cdm <- omopgenerics::cdmReference(drugRecords)
  compute <- FALSE

  if (byConcept) {
    compute <- TRUE
    drugRecords <- drugRecords |>
      PatientProfiles::addConceptName(
        column = "drug_concept_id",
        nameStyle = "concept_name"
      ) |>
      PatientProfiles::addConceptName(
        column = "drug_source_concept_id",
        nameStyle = "source_concept_name"
      )
  }

  if (byYear) {
    compute <- TRUE
    drugRecords <- drugRecords |>
      dplyr::mutate(year = clock::get_year(.data$drug_exposure_start_date))
  }

  if (bySex | length(ageGroup) > 0) {
    compute <- TRUE
    drugRecords <- drugRecords |>
      PatientProfiles::addDemographicsQuery(
        indexDate = "drug_exposure_start_date",
        age = FALSE,
        ageGroup = ageGroup,
        sex = bySex,
        futureObservation = FALSE,
        priorObservation = FALSE,
        dateOfBirth = FALSE
      )
  }

  if (type) {
    compute <- TRUE
    drugRecords <- drugRecords |>
      PatientProfiles::addConceptName(
        column = "drug_type_concept_id",
        nameStyle = "drug_type"
      ) |>
      dplyr::mutate(drug_type = paste0(
        dplyr::coalesce(.data$drug_type, "unknown"), " (",
        .data$drug_type_concept_id, ")"
      ))
  }

  if (route) {
    compute <- TRUE
    drugRecords <- drugRecords |>
    PatientProfiles::addConceptName(
      column = "route_concept_id",
      nameStyle = "route"
    ) |>
    dplyr::mutate(route = paste0(
      dplyr::coalesce(.data$route, "unknown"), " (",
      .data$route_concept_id, ")"
    ))
  }

  if (compute) {
    drugRecords <- drugRecords |>
      dplyr::compute(name = name)
  }

  return(drugRecords)
}
drugResultSettings <- function(result, subset, check, timing) {
  resId <- unique(result$result_id)
  result |>
    omopgenerics::newSummarisedResult(
      settings = dplyr::tibble(
        result_id = resId,
        result_type = "summarise_drug_use",
        package_name = "PhenotypeR",
        package_version = as.character(utils::packageVersion("PhenotypeR")),
        check = check,
        subset = subset,
        timing = timing
      )
    )
}
summariseCounts <- function(drugRecords, group, strata) {
  cols <- omopgenerics::omopColumns("drug_exposure") |>
    purrr::keep(\(x) x %in% colnames(drugRecords))
  PatientProfiles::summariseResult(
    table = drugRecords,
    includeOverallGroup = FALSE,
    group = group,
    includeOverallStrata = TRUE,
    strata = strata,
    variables = character(),
    counts = TRUE
  ) |>
    suppressMessages()
}
summariseMissing <- function(drugRecords, group, strata) {
  cols <- omopgenerics::omopColumns("drug_exposure") |>
    purrr::keep(\(x) x %in% colnames(drugRecords))
  PatientProfiles::summariseResult(
    table = drugRecords,
    includeOverallGroup = FALSE,
    group = group,
    includeOverallStrata = TRUE,
    strata = strata,
    variables = list(cols),
    estimates = list(c("count_missing", "percentage_missing")),
    counts = FALSE
  ) |>
    suppressMessages()
}
summariseExposureDuration <- function(drugRecords, group, strata) {
  drugRecords |>
    dplyr::mutate(exposure_duration = as.integer(clock::date_count_between(
      start = .data$drug_exposure_start_date,
      end = .data$drug_exposure_end_date,
      precision = "day"
    )) + 1L) |>
    PatientProfiles::summariseResult(
      includeOverallGroup = FALSE,
      group = group,
      includeOverallStrata = TRUE,
      strata = strata,
      variables = list("exposure_duration"),
      estimates = list(c(
        "min", "q01", "q05", "q25", "median", "q75", "q95", "q99", "max",
        "percentage_missing"
        # ,
        # "percentage_positive", "percentage_0", "percentage_negative",
        # "percentage_missing"
      )),
      counts = FALSE
    ) |>
    dplyr::filter(!variable_name %in% c("number records", "number subjects")) |>
    suppressMessages()
}
summariseType <- function(drugRecords, group, strata) {
  drugRecords |>
    PatientProfiles::addConceptName(
      column = "drug_type_concept_id",
      nameStyle = "drug_type"
    ) |>
    dplyr::mutate(drug_type = paste0(
      dplyr::coalesce(.data$drug_type, "unknown"), " (",
      .data$drug_type_concept_id, ")"
    )) |>
    PatientProfiles::summariseResult(
      group = group,
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "drug_type",
      estimates = c("count", "percentage", "count_person")
    ) |>
    suppressMessages()
}
summariseRoute <- function(drugRecords, group, strata) {
  drugRecords |>
    PatientProfiles::addConceptName(
      column = "route_concept_id",
      nameStyle = "route"
    ) |>
    dplyr::mutate(route = paste0(
      dplyr::coalesce(.data$route, "unknown"), " (",
      .data$route_concept_id, ")"
    )) |>
    PatientProfiles::summariseResult(
      group = group,
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "route",
      estimates = c("count", "percentage", "count_person")
    ) |>
    suppressMessages()
}
summariseQuantity <- function(drugRecords, group, strata) {
  drugRecords |>
    # PatientProfiles::addConceptName(
    #   column = "route_concept_id",
    #   nameStyle = "route"
    # ) |>
    # dplyr::mutate(route = paste0(
    #   dplyr::coalesce(.data$route, "unknown"), " (",
    #   .data$route_concept_id, ")"
    # )) |>
    PatientProfiles::summariseResult(
      group = group,
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "quantity",
      estimates = c("min", "q01", "q05", "q25", "median", "q75", "q95", "q99", "max",
                    "percentage_missing")
    ) |>
    dplyr::filter(!variable_name %in% c("number records", "number subjects")) |>
    suppressMessages()
}
summariseDose <- function(drugRecords, group, strata, ingredient) {
  cdm <- omopgenerics::cdmReference(table = drugRecords)

  result <- list()

  for (i in seq_len(nrow(ingredient))) {
    nm <- omopgenerics::uniqueTableName()
    id <- ingredient$ingredient_concept_id[i]
    idName <- ingredient$ingredient_name[i]

    result[[i]] <- drugRecords |>
      dplyr::select(
        "drug_concept_id", "drug_exposure_start_date", "drug_exposure_end_date",
        "quantity", dplyr::all_of(unique(unlist(c(strata, group))))
      ) |>
      DrugUtilisation::addDailyDose(ingredientConceptId = id, name = nm) |>
      PatientProfiles::summariseResult(
        group = group,
        includeOverallGroup = FALSE,
        strata = strata,
        includeOverallStrata = TRUE,
        variables = "daily_dose",
        estimates = c("min", "q01", "q05", "q25", "median", "q75", "q95", "q99", "max",
                      "percentage_missing")
      ) |>
      dplyr::filter(!variable_name %in% c("number records", "number subjects")) |>
      suppressMessages() |>
      omopgenerics::splitAdditional() |>
      dplyr::mutate(
        ingredient_concept_id = sprintf("%.0f", .env$id),
        ingredient_name = .env$idName
      ) |>
      omopgenerics::uniteAdditional(cols = c("ingredient_concept_id", "ingredient_name"))

    cdm <- omopgenerics::dropSourceTable(cdm = cdm, name = nm)
  }

  return(omopgenerics::bind(result))
}
summariseDaysBetween <- function(drugRecords, group, strata) {
  # cdm <- omopgenerics::cdmReference(drugRecords)
  # nm <- omopgenerics::uniqueTableName()

  result <- drugRecords |>
    dplyr::select(
      "person_id", "drug_concept_id", "drug_exposure_start_date",
      dplyr::all_of(unique(unlist(c(strata, group))))
    ) |>
    dplyr::group_by(.data$person_id, .data$drug_concept_id) |>
    dplyr::arrange(drug_exposure_start_date) |>
    dplyr::mutate(days_to_next_record = as.integer(clock::date_count_between(
      start = .data$drug_exposure_start_date,
      end = dplyr::lead(.data$drug_exposure_start_date),
      precision = "day"
    ))) |>
    dplyr::compute(name = nm) |>
    PatientProfiles::summariseResult(
      group = group,
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "days_to_next_record",
      estimates = c("min", "q01", "q05", "q25", "median", "q75", "q95", "q99", "max",
                    "percentage_missing")
    ) |>
    dplyr::filter(!variable_name %in% c("number records", "number subjects")) |>
    suppressMessages()
  # omopgenerics::dropSourceTable(cdm = cdm, name = nm)

  return(result)
}
findIngredient <- function(codes, cdm) {
  threshold <- min(1, as.numeric(getOption("PhenotypeR_ingredient_threshold", "0.8")))

  if (length(codes) == 0) {
    return(dplyr::tibble(
      codelist_name = character(),
      ingredient_concept_id = integer(),
      ingredient_name = character()
    ))
  }

  conceptsTib <- dplyr::as_tibble(codes)

  nm <- omopgenerics::uniqueTableName()
  cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = conceptsTib)

  x <- cdm$concept_ancestor |>
    dplyr::inner_join(
      cdm$concept |>
        dplyr::filter(.data$concept_class_id == "Ingredient") |>
        dplyr::select(
          "ancestor_concept_id" = "concept_id",
          "ingredient_name" = "concept_name"
        ),
      by = "ancestor_concept_id"
    ) |>
    dplyr::inner_join(
      cdm[[nm]] |>
        dplyr::select("codelist_name", "descendant_concept_id" = "concept_id"),
      by = "descendant_concept_id"
    ) |>
    dplyr::group_by(.data$codelist_name, .data$ancestor_concept_id, .data$ingredient_name) |>
    dplyr::summarise(n = as.numeric(dplyr::n()), .groups = "drop") |>
    dplyr::collect()

  omopgenerics::dropSourceTable(cdm = cdm, name = nm)

  conceptsTib |>
    dplyr::group_by(.data$codelist_name) |>
    dplyr::summarise(den = as.numeric(dplyr::n())) |>
    dplyr::inner_join(x, by = "codelist_name") |>
    dplyr::mutate(freq = .data$n / .data$den) |>
    dplyr::filter(.data$freq >= .env$threshold) |>
    dplyr::select(
      "codelist_name",
      "ingredient_concept_id" = "ancestor_concept_id",
      "ingredient_name"
    )
}
reportIngredient <- function(conceptTib) {
  mes <- c(i = "Change ingredient threshold with options(PhenotypeR_ingredient_threshold).")
  if (nrow(conceptTib) == 0) {
    cli::cli_inform(c("!" = "No common ingredient found.", mes))
  } else {
    x <- paste0("codelist_name: `", conceptTib$codelist_name, "`; ingredient: `", conceptTib$ingredient_name, "`")
    cli::cli_inform(c("v" = "Dose calculated for the following codelists and ingredients:", x,  mes))
  }
  return(conceptTib)
}

#' Visusalise the results in a table object
#'
#' @param result A summarised_result object.
#' @param check The check to visualise in the table.
#' @param header A vector specifying the elements to include in the header. The
#' order of elements matters, with the first being the topmost header. Elements
#' in header can be:
#' - Any of the columns returned by tableColumns(result) to create a header for
#' these columns.
#' - Any other input to create an overall header.
#' @param groupColumn Columns to use as group labels, to see options use
#' tableColumns(result). By default, the name of the new group will be the tidy*
#' column names separated by ";". To specify a custom group name, use a named
#' list such as: list("newGroupName" = c("variable_name", "variable_level")).
#' *tidy: The tidy format applied to column names replaces "_" with a space an
#' converts to sentence case. Use rename to customise specific column names.
#' @param hide Columns to drop from the output table.
#' @param type Character string specifying the desired output table format. See
#' `visOmopResults::tableType()` for supported table types. If `type = NULL`,
#' global options (set via `visOmopResults::setGlobalTableOptions()`) will be
#' used if available; otherwise, a default 'gt' table is created.
#' @param style Defines the visual formatting of the table. This argument can be
#' provided in one of the following ways:
#' 1. **Pre-defined style**: Use the name of a built-in style (e.g., "darwin").
#' See tableStyle() for available options.
#' 2. **YAML file path**: Provide the path to an existing .yml file defining a
#' new style.
#' 3. **List of custome R code**: Supply a block of custom R code or a named
#' list describing styles for each table section. This code must be specific to
#' the selected table type. If `style = NULL`, the function will use global
#' options (see `visOmopResults::setGlobalTableOptions()`) or an existing
#' `_brand.yml` file (if found); otherwise, the default style is applied. For
#' more details, see the Styles vignette on the package website.
#'
#' @return A table visualisation.
#' @noRd
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset()
#'
#' result <- summariseDrugExposureDiagnostics(cdm = cdm, ingredient = 1125315L)
#'
#' tableDrugExposureDiagnostics(result = result)
#' }
#'
tableDrugExposureDiagnostics <- function(result,
                                         check = "standardConcept",
                                         header = NULL,
                                         groupColumn = NULL,
                                         hide = NULL,
                                         type = NULL,
                                         style = NULL) {
  rlang::check_installed("visOmopResults")
  # input check
  result <- omopgenerics::validateResultArgument(result)
  opts <- c("standardConcept", getAllCheckOptions())
  omopgenerics::assertChoice(check, opts)
  check <- omopgenerics::toSnakeCase(check)

  # filter
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_drug_exposure_diagnostics" &
        .data$check == .env$check
    )

  if (nrow(result) == 0) {
    return(visOmopResults::emptyTable(type = type, style = style))
  }

  # update defaults
  header <- header %||% headerDeafult[[check]]
  groupColumn <- groupColumn %||% groupColumnDeafult[[check]]
  hide <- hide %||% hideDeafult[[check]]

  visOmopResults::visOmopTable(
    result = result,
    estimateName = estimateName[[check]],
    rename = rename[[check]],
    header = header,
    groupColumn = groupColumn,
    hide = hide,
    type = type,
    style = style
  )
}

# defaults
rename <- list(
  "standard_concept" = character(),
  "missing" = c("Column" = "variable_name")
)
estimateName <- list(
  "standard_concept" = character(),
  "missing" = c("missing N (%)" = "<count_missing> (<percentage_missing>%)", "N" = "<count>")
)
headerDeafult <- list(
  "standard_concept" = c("cdm_name", "variable_name"),
  "missing" = c("cdm_name")
)
groupColumnDeafult <- list(
  "standard_concept" = c("codelist_name"),
  "missing" = "codelist_name"
)
hideDeafult <- list(
  "standard_concept" = c("variable_level", "estimate_name"),
  "missing" = "variable_level"
)
getAllCheckOptions <- function() {
  return(c("missing", "exposureDuration", "type", "route", "sourceConcept",
           "daysSupply", "verbatimEndDate", "dose", "sig", "quantity", "daysBetween",
           "diagnosticsSummary"))
}
