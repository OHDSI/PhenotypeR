#' Create a report summarising your phenotyping results
#'
#' @inheritParams resultDoc
#' @inheritParams directoryDoc
#'
#' @return A report
#' @noRd
reportDiagnostics <- function(result,
                              directory = here::here()){

    input <- system.file("rmd", "phenotype_report.Rmd",
                         package = "PhenotypeR")

    cohortNames <- result |>
      visOmopResults::addSettings() |>
      omopgenerics::filter(.data$result_type == "summarised_characteristics") |>
      dplyr::filter(.data$group_level != "overall") |>
      dplyr::select("group_level") |>
      dplyr::distinct() |>
      dplyr::pull()
    cohortNames <- paste0(cohortNames, collapse = "; ")
    workingTitle <- paste('PhenotypeR results for cohort', cohortNames)

    rmarkdown::render(input = input,
                      params = list(title = workingTitle,
                                    result = result),
                      output_file = "report.html",
                      output_dir = directory,
                      clean = TRUE)
}
