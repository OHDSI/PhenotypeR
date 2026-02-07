
summariseDrugUse <- function(cdm,
                             codes,
                             byConcept = TRUE,
                             byYear = FALSE,
                             bySex = FALSE,
                             ageGroup = NULL,
                             dateRange = as.Date(c(NA, NA)),
                             personSample = 20000,
                             checks = c("missing", "exposureDuration", "type", "route", "dose", "quantity", "daysBetween")) {
  # validate personSample
  cdm <- omopgenerics::validateCdmArgument(cdm = cdm)
  omopgenerics::assertNumeric(personSample, integerish = TRUE, min = 1, null = TRUE, length = 1)
  if (!is.null(personSample)) {
    nm <- omopgenerics::uniqueTableName()
    cdm[[nm]] <- CohortConstructor::demographicsCohort(cdm = cdm, name = nm) |>
      CohortConstructor::sampleCohorts(n = personSample)
    on.exit(omopgenerics::dropSourceTable(cdm = cdm, name = nm))
  } else {
    nm <- NULL
  }

  summariseDrugUseInternal(
    cdm = cdm,
    codes = codes,
    subsetTable = nm,
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
                                   checks = c("missing", "exposureDuration", "type", "route", "dose", "quantity", "daysBetween")) {
  if (is.null(codes)) {
    codes <- omopgenerics::newCodelist(attr(cohort, "cohort_codelist"))
  }
  summariseDrugUseInternal(
    cdm = omopgenerics::cdmReference(cohort),
    codes = codes,
    subsetTable = omopgenerics::tableName(cohort),
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
                                     subsetTable,
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
  if (is.null(subsetTable)) {
    cohort <- NULL
  } else {
    cohort <- cdm[[subsetTable]]
  }
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
    subsetTable = subsetTable,
    timing = timing,
    dateRange = dateRange,
    name = nm
  )

  # add stratifications
  drugRecords <- addStratifications(drugRecords, byConcept, byYear, bySex, ageGroup)
  group <- list(c("codelist_name", c("concept_name", "source_concept_name")[byConcept]))
  strata <- c("year"[byYear], "sex"[bySex], names(ageGroup)) |>
    as.list()

  result <- list()

  # missing
  if ("missing" %in% checks) {
    result$missing <- summariseMissing(drugRecords, group, strata) |>
      drugResultSettings(subset = subsetName, check = "missing")
  }

  # variables of interest

  #  exposureDuration

  # type

  # route

  # quantity

  # dose

  # daysBetween


}
subsetDrugRecords <- function(cdm, subsetTable, timing, dateRange, name) {

}
addStratifications <- function(drugRecords, byConcept, byYear, bySex, ageGroup, name) {
  cdm <- omopgenerics::cdmReference(drugRecords)
  if (byConcept) {
    compute <- TRUE
    drugRecords <- drugRecords |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select("drug_concept_id" = "concept_id", "concept_name"),
        by = "drug_concept_id"
      ) |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select(
            "drug_source_concept_id" = "concept_id",
            "source_concept_name" = "concept_name"
          ),
        by = "drug_source_concept_id"
      )
  }

  drugRecords |>
    PatientProfiles::addDemographicsQuery(
      indexDate = "drug_exposure_start_date",
      age = FALSE,
      ageGroup = ageGroup,
      sex = bySex,
    )
}
drugResultSettings <- function(result, subset, check) {
  resId <- unique(result$result_id)
  result |>
    omopgenerics::newSummarisedResult(
      settings = dplyr::tibble(
        result_id = resId,
        result_type = "summarise_drug_use",
        package_name = "PhenotypeR",
        package_version = as.character(packageVersion("PhenotypeR")),
        subset = subset,
        check = check
      )
    )
}
summariseMissing <- function(drugRecords, group, strata) {
  cols <- omopgenerics::omopColumns("drug_exposure") |>
    purrr::keep(\(x) x %in% colnames(drugRecords))
  result <- PatientProfiles::summariseResult(
    table = drugRecords,
    includeOverallGroup = FALSE,
    group = group,
    includeOverallStrata = TRUE,
    strata = strata,
    variables = list(cols),
    estimates = list(c("count_missing", "percentage_missing")),
    counts = FALSE
  )
}

#' Summarise diagnostics of the drug exposure table for a given concept set
#' and/or ingredient
#'
#' @param cdm A cdm_reference object.
#' @param ingredient An ingredient concept ID.
#' @param conceptSet A concept set.
#' @param checks the checks to be executed, by default the missing values, the
#' exposure duration and the quantity. Possible options are "missing",
#' "exposureDuration", "type", "route", "sourceConcept", "daysSupply",
#' "verbatimEndDate", "dose", "sig", "quantity", "daysBetween" and
#' "diagnosticsSummary". Note "standardConcept" check is always performed.
#' @param sample Number of records to use for the checks. Note 'overall' and
#' 'sourceConcept' checks will be performed with the
#' @param dateRange Range to use the records
#' @param byConcept Whether to stratify results by concept id.
#'
#' @return A summarised_result object with the checks.
#' @noRd
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset()
#'
#' summariseDrugExposureDiagnostics(cdm = cdm, ingredient = 1125315L)
#' }
#'
summariseDrugExposureDiagnostics <- function(cdm,
                                             ingredient = NULL,
                                             conceptSet = NULL,
                                             checks = c("missing", "exposureDuration", "quantity"),
                                             sample = 10000,
                                             dateRange = c("2010-01-01", NA),
                                             byConcept = FALSE) {
  # input check
  cdm <- omopgenerics::validateCdmArgument(cdm = cdm)
  omopgenerics::assertNumeric(ingredient, integerish = TRUE, null = TRUE)
  if (length(conceptSet) == 0) {
    if (is.null(ingredient)) {
      cli::cli_abort(c(x = "`ingredient` and `conceptSet` not provided. At least one of them must be provided."))
    } else {
      conceptSet <- getIngredientConceptSet(ingredient = ingredient, cdm = cdm)
    }
  } else {
    nms <- names(conceptSet)
    conceptSet <- omopgenerics::validateConceptSetArgument(conceptSet = conceptSet, cdm = cdm)
    if (length(ingredient) > 0) {
      if (length(ingredient) != length(conceptSet)) {
        if (length(ingredient) == 1) {
          ingredient <- rep(ingredient, length(conceptSet))
        } else {
          cli::cli_abort(c(x = "`ingredient` and `conceptSet` have different lengths please provide consistent arguments."))
        }
      } else {
        # to account that validate concept set sorts names
        id <- match(names(conceptSet), nms)
        ingredient <- ingredient[id]
      }
    }
  }
  omopgenerics::assertChoice(checks, getAllCheckOptions(), unique = TRUE)
  omopgenerics::assertNumeric(sample, integerish = TRUE, length = 1, null = TRUE)
  if (is.null(dateRange)) {
    dateRange <- as.Date(c(NA, NA))
  } else if (is.character(dateRange)) {
    dateRange <- as.Date(dateRange)
  }
  omopgenerics::assertDate(dateRange, length = 2, na = TRUE)
  omopgenerics::assertLogical(byConcept, length = 1)

  # remove dose check if ingredient is NULL
  if (length(ingredient) == 0 & "dose" %in% checks) {
    cli::cli_warn(c(x = "Ingredient not provided, `dose` check removed."))
    checks <- checks[!checks %in% "dose"]
  }

  # prepare options
  cols <- colnames(cdm$drug_exposure)
  exposureDuration <- any(c("exposureDuration", "daysSupply") %in% checks)
  daysBetween <- "daysBetween" %in% checks
  if (byConcept) {
    strata <- list("drug_concept_id")
  } else {
    strata <- list()
  }

  # perform checks
  result <- seq_along(conceptSet) |>
    purrr::map(\(k) {
      name <- names(conceptSet)[k]
      ing <- as.integer(ingredient[k])
      start <- Sys.time()
      cli::cli_inform(c(i = "{.emph {time()}} Starting DrugExposureDiagnostics for {.pkg {name}}."))

      # get records
      id <- cli::cli_status(msg = "{.emph {time()}} Retrieving records.")
      nm <- omopgenerics::uniqueTableName()
      table <- getRecords(cdm, conceptSet[[k]], dateRange, nm) |>
        dplyr::mutate(codelist_name = .env$name)

      # settings
      set <- dplyr::tibble(
        result_id = 1L,
        result_type = "summarise_drug_exposure_diagnostics",
        package_name = "PhenotypeR",
        package_version = as.character(utils::packageVersion(pkg = "PhenotypeR")),
        check = "",
        sample = as.character(sample %||% "Inf")
      )

      result <- list()

      # counts overall
      cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'standardConcept'}.")
      result$overall <- summariseCheckConcept(table, set, ing)

      # sourceConcept
      if ("sourceConcept" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'sourceConcept'}.")
        result$sourceConcept <- summariseCheckConceptSource(table, set)
      }

      # add data and sample
      cli::cli_status_update(id = id, msg = "{.emph {time()}} Adding needed variables and sampling.")
      table <- table |>
        addDaysBetween(daysBetween, nm) |>
        sampleRecords(sample, nm) |>
        addExposureDuration(exposureDuration, nm)

      # missing
      if ("missing" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'missing'}.")
        result$missing <- summariseCheckMissing(table, strata, cols, set)
      }

      # sig
      if ("sig" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'sig'}.")
        result$sig <- summariseCheckSig(table, strata, set)
      }

      # exposureDuration
      if ("exposureDuration" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'exposureDuration'}.")
        result$exposureDuration <- summariseCheckExposureDuration(table, strata, set)
      }

      # type
      if ("type" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'type'}.")
        result$type <- summariseCheckType(table, strata, set)
      }

      # route
      if ("route" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'route'}.")
        result$route <- summariseCheckRoute(table, strata, set)
      }

      # daysSupply
      if ("daysSupply" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'daysSupply'}.")
        result$route <- summariseCheckDaysSupply(table, strata, set)
      }

      # verbatimEndDate
      if ("verbatimEndDate" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'verbatimEndDate'}.")
        result$verbatimEndDate <- summariseCheckVerbatimEndDate(table, strata, set)
      }

      # quantity
      if ("quantity" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'quantity'}.")
        result$quantity <- summariseCheckQuantity(table, strata, set)
      }

      # dose
      if ("dose" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'dose'}.")
        result$dose <- summariseCheckDose(table, strata, set, ing)
      }

      # daysBetween
      if ("daysBetween" %in% checks) {
        cli::cli_status_update(id = id, msg = "{.emph {time()}} Starting check: {.strong 'daysBetween'}.")
        result$daysBetween <- summariseCheckDaysBetween(table, strata, set)
      }

      # drop table
      omopgenerics::dropSourceTable(cdm = cdm, name = nm)

      # bind final result
      finalResult <- omopgenerics::bind(result)

      # inform
      end <- Sys.time()
      td <- difftime(time1 = end, time2 = start, units = "secs") |>
        as.numeric() |>
        round()
      cli::cli_status_clear(id = id)
      cli::cli_inform(c(v = "{.emph {time()}} DrugExposureDiagnostics for concept {.pkg {name}} finalised in {td} seconds."))

      return(finalResult)
    }) |>
    omopgenerics::bind()

  # diagnosticsSummary
  if ("diagnosticsSummary" %in% checks) {
    # TODO
  }

  return(result)
}

time <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}
getIngredientConceptSet <- function(ingredient, cdm) {
  x <- cdm$concept |>
    dplyr::filter(
      .data$concept_id %in% .env$ingredient &
        .data$concept_class_id == "Ingredient"
    ) |>
    dplyr::select("concept_id", "concept_name") |>
    dplyr::collect()
  if (nrow(x) == 0) {
    cli::cli_abort(c(x = "Ingredients not found in `concept` table."))
  }
  notPresent <- ingredient[!ingredient %in% x$concept_id]
  if (length(notPresent) > 0) {
    cli::cli_warn(c("!" = "Ingredients not found in `concept` table: {notPresent}."))
  }
  as.list(x$concept_id) |>
    rlang::set_names(nm = x$concept_name) |>
    purrr::map(\(x) {
      CodelistGenerator::getDescendants(cdm = cdm, conceptId = x)$concept_id
    }) |>
    omopgenerics::newCodelist()
}
getRecords <- function(cdm, concepts, dateRange, nm) {

  x <- cdm$drug_exposure |>
    dplyr::inner_join(
      cdm$concept |>
        dplyr::filter(.data$concept_id %in% .env$concepts) |>
        dplyr::select("drug_concept_id" = "concept_id"),
      by = "drug_concept_id"
    )

  # subset dates
  startDate <- dateRange[1]
  endDate <- dateRange[2]
  if (!is.na(startDate)) {
    if (!is.na(endDate)) {
      x <- x |>
        dplyr::filter(
          .data$drug_exposure_start_date >= .env$startDate &
            .data$drug_exposure_start_date <= .env$endDate
        )
    } else {
      x <- x |>
        dplyr::filter(.data$drug_exposure_start_date >= .env$startDate)
    }
  } else if (!is.na(endDate)) {
    x <- x |>
      dplyr::filter(.data$drug_exposure_start_date <= .env$endDate)
  }

  x <- x |>
    dplyr::compute(name = nm)

  return(x)
}
addDaysBetween <- function(x, daysBetween, nm) {
  if (daysBetween) {
    x <- x |>
      dplyr::group_by(.data$person_id) |>
      dplyr::mutate(
        days_between_records = clock::date_count_between(
          start = .data$drug_exposure_start_date,
          end = dplyr::lead(.data$drug_exposure_start_date, order_by = .data$drug_exposure_start_date),
          precision = "day"
        )
      ) |>
      dplyr::ungroup() |>
      dplyr::compute(name = nm)
  }
  return(x)
}
sampleRecords <- function(x, sample, nm) {
  if (!is.null(sample) & !is.infinite(sample)) {
    x <- x |>
      dplyr::slice_sample(n = sample) |>
      dplyr::compute(name = nm)
  }
  return(x)
}
addExposureDuration <- function(x, exposureDuration, nm) {
  if (exposureDuration) {
    x <- x |>
      dplyr::mutate(exposure_duration = clock::date_count_between(
        start = .data$drug_exposure_start_date,
        end = .data$drug_exposure_end_date,
        precision = "day"
      )) |>
      dplyr::compute(name = nm)
  }
  return(x)
}
summariseCheckConcept <- function(table, set, ingredient) {
  cdm <- omopgenerics::cdmReference(table = table)
  nm <- omopgenerics::uniqueTableName()
  result <- table |>
    dplyr::group_by(.data$codelist_name, .data$drug_concept_id) |>
    dplyr::summarise(
      record_count = as.integer(dplyr::n()),
      subject_count = as.integer(dplyr::n_distinct(.data$person_id))
    ) |>
    dplyr::compute(name = nm) |>
    dplyr::inner_join(
      cdm$concept |>
        dplyr::rename(
          drug_concept_id = "concept_id",
          drug_concept_name = "concept_name"
        ),
      by = "drug_concept_id"
    )

  if (length(ingredient) > 0) {
    result <- result |>
      dplyr::compute(name = nm) |>
      dplyr::left_join(
        cdm$drug_strength |>
          dplyr::filter(.data$ingredient_concept_id == .env$ingredient) |>
          PatientProfiles::addConceptName(
            column = "ingredient_concept_id",
            nameStyle = "ingredient_name"
          ) |>
          PatientProfiles::addConceptName(
            column = "amount_unit_concept_id",
            nameStyle = "amount_unit"
          ) |>
          PatientProfiles::addConceptName(
            column = "numerator_unit_concept_id",
            nameStyle = "numerator_unit"
          ) |>
          PatientProfiles::addConceptName(
            column = "denominator_unit_concept_id",
            nameStyle = "denominator_unit"
          ) |>
          dplyr::select(
            "drug_concept_id", "ingredient_concept_id", "ingredient_name",
            "amount_value", "amount_unit", "numerator_value", "numerator_unit",
            "denominator_value", "denominator_unit"
          ),
        by = "drug_concept_id"
      )
  }

  result <- dplyr::collect(result)

  # add dose form
  concepts <- unique(result$drug_concept_id)
  doseForm <- cdm$concept_relationship |>
    dplyr::filter(
      .data$relationship_id == "RxNorm has dose form" &
        .data$concept_id_1 %in% .env$concepts
    ) |>
    PatientProfiles::addConceptName(
      column = "concept_id_2",
      nameStyle = "dose_form"
    ) |>
    dplyr::select("drug_concept_id" = "concept_id_1", "dose_form") |>
    dplyr::collect() |>
    dplyr::arrange(.data$dose_form) |>
    dplyr::group_by(.data$drug_concept_id) |>
    dplyr::summarise(dose_form = paste0(.data$dose_form, collapse = "; "))

  result <- result |>
    dplyr::left_join(doseForm, by = "drug_concept_id") |>
    dplyr::mutate(dose_form = dplyr::coalesce(.data$dose_form, "missing"))

  # drop table
  omopgenerics::dropSourceTable(cdm = cdm, name = nm)

  # format result
  set <- set |>
    dplyr::select(!"result_id") |>
    dplyr::mutate(check = "standard_concept")
  colsEstimate <- c("record_count", "subject_count")
  colsGroup <- c("codelist_name")
  colsStrata <- c("drug_concept_name", "drug_concept_id")
  colsAdditional <- colnames(result) |>
    purrr::keep(\(x) !x %in% c(colsEstimate, colsGroup, colsStrata))
  colsSettings <- colnames(set)
  result |>
    dplyr::mutate(
      cdm_name = omopgenerics::cdmName(cdm),
      variable_name = "overall",
      variable_level = "overall"
    ) |>
    dplyr::mutate(dplyr::across(
      .cols = !dplyr::all_of(colsEstimate),
      .fns = \(x) as.character(x) |> dplyr::coalesce("-")
    )) |>
    dplyr::cross_join(set) |>
    omopgenerics::transformToSummarisedResult(
      group = colsGroup,
      strata = colsStrata,
      additional = colsAdditional,
      estimates = colsEstimate,
      settings = colsSettings
    ) |>
    dplyr::mutate(
      variable_name = dplyr::if_else(
        .data$estimate_name == "record_count", "Number records", "Number subjects"
      ),
      estimate_name = "count"
    )
}
summariseCheckConceptSource <- function(table, set) {
  cdm <- omopgenerics::cdmReference(table = table)
  nm <- omopgenerics::uniqueTableName()
  result <- table |>
    dplyr::group_by(
      .data$codelist_name,
      .data$drug_concept_id,
      .data$drug_source_value,
      .data$drug_source_concept_id
    ) |>
    dplyr::summarise(
      record_count = as.integer(dplyr::n()),
      subject_count = as.integer(dplyr::n_distinct(.data$person_id))
    ) |>
    dplyr::compute(name = nm) |>
    PatientProfiles::addConceptName(
      column = "drug_concept_id",
      nameStyle = "drug_concept_name"
    ) |>
    PatientProfiles::addConceptName(
      column = "drug_source_concept_id",
      nameStyle = "drug_source_concept_name"
    ) |>
    dplyr::collect()

  # drop table
  omopgenerics::dropSourceTable(cdm = cdm, name = nm)

  # format result
  set <- set |>
    dplyr::select(!"result_id") |>
    dplyr::mutate(check = "concept_source")
  colsEstimate <- c("record_count", "subject_count")
  colsGroup <- c("codelist_name")
  colsStrata <- c(
    "drug_concept_name", "drug_concept_id", "drug_source_value",
    "drug_source_concept_name", "drug_source_concept_id"
  )
  colsSettings <- colnames(set)
  result |>
    dplyr::mutate(
      cdm_name = omopgenerics::cdmName(cdm),
      variable_name = "overall",
      variable_level = "overall"
    ) |>
    dplyr::mutate(dplyr::across(!dplyr::all_of(colsEstimate), as.character)) |>
    dplyr::cross_join(set) |>
    omopgenerics::transformToSummarisedResult(
      group = colsGroup,
      strata = colsStrata,
      additional = character(),
      estimates = colsEstimate,
      settings = colsSettings
    ) |>
    dplyr::mutate(
      variable_name = dplyr::if_else(
        .data$estimate_name == "record_count", "Number records", "Number subjects"
      ),
      estimate_name = "count"
    )
}
summariseCheckMissing <- function(table, strata, cols, set) {
  PatientProfiles::summariseResult(
    table = table,
    group = list("codelist_name"),
    includeOverallGroup = FALSE,
    strata = strata,
    includeOverallStrata = TRUE,
    variables = cols,
    estimates = c("count_missing", "percentage_missing")
  ) |>
    suppressMessages() |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "missing")
    )
}
summariseCheckSig <- function(table, strata, set) {
  PatientProfiles::summariseResult(
    table = table,
    group = list("codelist_name"),
    includeOverallGroup = FALSE,
    strata = strata,
    includeOverallStrata = TRUE,
    variables = "sig",
    estimates = c("count", "percentage", "count_person")
  ) |>
    suppressMessages() |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "sig")
    )
}
summariseCheckExposureDuration <- function(table, strata, set) {
  table |>
    PatientProfiles::summariseResult(
      group = list("codelist_name"),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "exposure_duration",
      estimates = c("min", "q05", "q10", "q25", "median", "q75", "q90", "q95", "max", "percentage_positive", "percentage_0", "percentage_negative")
    ) |>
    suppressMessages() |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "exposure_duration")
    )
}
summariseCheckType <- function(table, strata, set) {
  table |>
    PatientProfiles::addConceptName(
      column = "drug_type_concept_id",
      nameStyle = "drug_type"
    ) |>
    dplyr::select(dplyr::all_of(c(
      "codelist_name", unlist(strata), "person_id", "drug_type",
      "drug_type_concept_id"
    ))) |>
    dplyr::collect() |>
    dplyr::mutate(drug_type = paste0(
      dplyr::coalesce(.data$drug_type, "unknown"), " (",
      .data$drug_type_concept_id, ")"
    )) |>
    PatientProfiles::summariseResult(
      group = list("codelist_name"),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "drug_type",
      estimates = c("count", "percentage", "count_person")
    ) |>
    suppressMessages() |>
    dplyr::mutate(cdm_name = omopgenerics::cdmName(table)) |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "type")
    )
}
summariseCheckRoute <- function(table, strata, set) {
  table |>
    PatientProfiles::addConceptName(
      column = "route_concept_id",
      nameStyle = "route"
    ) |>
    dplyr::select(dplyr::all_of(c(
      "codelist_name", unlist(strata), "person_id", "route", "route_concept_id"
    ))) |>
    dplyr::collect() |>
    dplyr::mutate(route = paste0(
      dplyr::coalesce(.data$route, "unknown"), " (",
      .data$route_concept_id, ")"
    )) |>
    PatientProfiles::summariseResult(
      group = list("codelist_name"),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "route",
      estimates = c("count", "percentage", "count_person")
    ) |>
    suppressMessages() |>
    dplyr::mutate(cdm_name = omopgenerics::cdmName(table)) |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "route")
    )
}
summariseCheckDaysSupply <- function(table, strata, set) {
  table |>
    dplyr::mutate(days_supply_equal_exposure_duration = dplyr::if_else(
      as.integer(.data$days_supply) == as.integer(.data$exposure_duration), 0, 1
    )) |>
    PatientProfiles::summariseResult(
      group = list("codelist_name"),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = list("days_supply", "days_supply_equal_exposure_duration"),
      estimates = list(
        c("min", "q05", "q10", "q25", "median", "q75", "q90", "q95", "max", "percentage_positive", "percentage_0", "percentage_negative"),
        c("count", "percentage")
      )
    ) |>
    suppressMessages() |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "days_supply")
    )
}
summariseCheckVerbatimEndDate <- function(table, strata, set) {
  table |>
    dplyr::mutate(verbatim_equal_end = dplyr::if_else(
      .data$verbatim_end_date == .data$drug_exposure_end_date, 1, 0
    )) |>
    PatientProfiles::summariseResult(
      group = list("codelist_name"),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = list("verbatim_end_date", "verbatim_equal_end"),
      estimates = list(
        c("min", "max", "count_missing", "percentage_missing"),
        c("count", "percentage")
      )
    ) |>
    suppressMessages() |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "verbatim_end_date")
    )
}
summariseCheckQuantity <- function(table, strata, set) {
  table |>
    PatientProfiles::summariseResult(
      group = list("codelist_name"),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "quantity",
      estimates = c("min", "q05", "q10", "q25", "median", "q75", "q90", "q95", "max")
    ) |>
    suppressMessages() |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "quantity")
    )
}
summariseCheckDose <- function(table, strata, set, ingredient) {
  nm <- omopgenerics::uniqueTableName()
  cdm <- omopgenerics::cdmReference(table = table)
  ingredientName <- cdm$concept |>
    dplyr::filter(.data$concept_id == .env$ingredient) |>
    dplyr::pull("concept_name")
  result <- table |>
    DrugUtilisation::addDailyDose(ingredientConceptId = ingredient, name = nm) |>
    PatientProfiles::summariseResult(
      group = list("codelist_name"),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "daily_dose",
      estimates = c("min", "q05", "q10", "q25", "median", "q75", "q90", "q95", "max", "count_missing", "percentage_missing")
    ) |>
    suppressMessages() |>
    omopgenerics::splitAdditional() |>
    dplyr::mutate(
      ingredient_concept_id = as.integer(ingredient),
      ingredient_name = .env$ingredientName
    ) |>
    omopgenerics::uniteAdditional(cols = c("ingredient_concept_id", "ingredient_name")) |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "dose")
    )
  cdm <- omopgenerics::dropSourceTable(cdm = cdm, name = nm)
  return(result)
}
summariseCheckDaysBetween <- function(table, strata, set) {
  table |>
    PatientProfiles::summariseResult(
      group = list("codelist_name"),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = TRUE,
      variables = "days_between_records",
      estimates = c("min", "q05", "q10", "q25", "median", "q75", "q90", "q95", "max")
    ) |>
    suppressMessages() |>
    omopgenerics::newSummarisedResult(
      settings = set |>
        dplyr::mutate(check = "days_between")
    )
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

findIngredient <- function(codes, cdm) {
  threshold <- min(1, as.numeric(getOption("PhenotypeR_ingredient_threshold", "0.8")))

  if (length(codes) == 0) {
    return(dplyr::tibble(
      codelist_name = character(),
      ingredient_concept_id = integer()
    ))
  }

  conceptsTib <- dplyr::as_tibble(codes)

  nm <- omopgenerics::uniqueTableName()
  cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = conceptsTib)

  x <- cdm$concept_ancestor |>
    dplyr::inner_join(
      cdm$concept |>
        dplyr::filter(.data$concept_class_id == "Ingredient") |>
        dplyr::select("ancestor_concept_id" = "concept_id"),
      by = "ancestor_concept_id"
    ) |>
    dplyr::inner_join(
      cdm[[nm]] |>
        dplyr::select("codelist_name", "descendant_concept_id" = "concept_id"),
      by = "descendant_concept_id"
    ) |>
    dplyr::group_by(.data$codelist_name, .data$ancestor_concept_id) |>
    dplyr::summarise(n = as.numeric(dplyr::n()), .groups = "drop") |>
    dplyr::collect()

  omopgenerics::dropSourceTable(cdm = cdm, name = nm)

  conceptsTib |>
    dplyr::group_by(.data$codelist_name) |>
    dplyr::summarise(den = as.numeric(dplyr::n())) |>
    dplyr::inner_join(x, by = "codelist_name") |>
    dplyr::mutate(freq = .data$n / .data$den) |>
    dplyr::filter(.data$freq >= .env$threshold) |>
    dplyr::select("codelist_name", "ingredient_concept_id" = "ancestor_concept_id")
}
