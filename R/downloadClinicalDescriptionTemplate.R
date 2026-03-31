#' Download a Clinical Description Template
#'
#' @param directory Directory where to download the clinical description.
#' @param name Name of the Word file.Note that the file must match the cohort names
#' used in PhenotypeR Diagnostics if you want to integrate the clinical description
#' into the PhenotypeR Shiny app.
#'
#' @return A Word document with the template of the clinical description.
#' @export
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#' library(here)
#'
#' downloadClinicalDescriptionTemplate(directory = here(),
#'                                     name = "metformin")
#'
#'
#' }

downloadClinicalDescriptionTemplate <- function(directory,
                                                name = "clinical_description_template") {

  internalDescriptionTemplates(type = "clinical description",
                               directory = directory,
                               name = name)
}
