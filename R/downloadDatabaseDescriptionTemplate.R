#' Download a Clinical Description Template
#'
#' @param directory Directory where to download the database description template.
#' @param name Name of the Word file.Note that the file must match the database names
#' used in PhenotypeR Diagnostics if you want to integrate the database description
#' into the PhenotypeR Shiny app.
#'
#' @return A Word document with the template of the clinical description.
#' @export
#'
#' @examples
#' \donttest{
#' library(PhenotypeR)
#'
#' downloadDatabaseDescriptionTemplate(directory = tempdir(),
#'                                     name = "GiBleed")
#'
#'
#' }

downloadDatabaseDescriptionTemplate <- function(directory,
                                                name = "database_description_template") {

  internalDescriptionTemplates(type = "database description",
                               directory = directory,
                               name = name)
}

internalDescriptionTemplates <- function(type, directory, name, call = parent.frame()) {
  omopgenerics::assertCharacter(directory, length = 1, call = call)
  omopgenerics::assertCharacter(name, length = 1, call = call)

  if(!dir.exists(directory)){
    cli::cli_abort("Directory {directory} does not exist.", call = call)
  }

  if(file.exists(paste0(directory, "/", name, ".docx"))) {

    if (yesno("A file named {name}.docx exists in {directory}. Do you want to overwrite it?")) {
      cli::cli_inform(c("x" = "Aborting {type} template download."))
      return(invisible())
    }
  }

  to <- file.path(paste0(directory, "/", name, ".docx"))

  if(type == "clinical description"){
    from <- system.file("shiny", "data", "raw", "clinical_descriptions", "template", package = "PhenotypeR")
  } else if (type == "database description") {
    from <- system.file("shiny", "data", "raw", "database_descriptions", "template", package = "PhenotypeR")
  }

  invisible(file.copy(from = from, to = to))

  cli::cli_inform(c("v" = "{stringr::str_to_sentence(type)} template download correctly!"))
}
