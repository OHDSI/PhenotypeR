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

  omopgenerics::assertCharacter(directory, length = 1)
  omopgenerics::assertCharacter(name, length = 1)

  if(!dir.exists(directory)){
    cli::cli_abort("Directory {directory} does not exist.")
  }

  if(file.exists(paste0(directory, "/", name, ".docx"))) {

    if (yesno("A file named {name}.docx exists in {directory}. Do you want to overwrite it?")) {
      cli::cli_inform(c("x" = "Aborting clinical description download."))
      return(invisible())
    }
  }

  to <- file.path(paste0(directory, "/", name, ".docx"))
  from <- system.file("shiny/data/raw/clinical_descriptions/template.docx", package = "PhenotypeR")
  invisible(file.copy(from = from, to = to))

  cli::cli_inform(c("v" = "Clinical description download correctly."))
}
