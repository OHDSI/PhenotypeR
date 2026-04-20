
#' Shiny app to create descriptions for contextualising diagnostic results
#'
#' @param directory Directory where to save shiny app
#' @param open If TRUE, the shiny app will be launched in a new session. If
#' FALSE, the shiny app will be created but not launched.
#'
#' @returns
#' @export
#'
#' @examples
#' \donttest{
#' shinyDescriptions(tempdir())
#' }
shinyDescriptions <- function(directory,
                             open = rlang::is_interactive()){

  folderName <- "descritpionShiny"

  # check if directory needs to be overwritten directory
  directory <- validateDirectory(directory, folderName)
  if (isTRUE(directory)) {
    return(cli::cli_inform(c("i" = "{.strong shiny} folder will not be overwritten. Stopping process.")))
  }

  cli::cli_inform(c("i" = "Creating shiny from provided data"))

  # copy files
  to <- file.path(directory, folderName)
  from <- system.file("clinical_description_shiny", package = "PhenotypeR")
  invisible(copyDirectory(from = from, to = to))

  # open project
  if (isTRUE(open)) {
    rlang::check_installed("usethis")
    usethis::proj_activate(path = to)
  }else{
    if(dir.exists(paste0(directory,"/", folderName))){
      cli::cli_inform(c("i" = "Shiny app created in {directory}/{folderName}"))
    }else{
      cli::cli_inform(c("i" = "Shiny app could not be created in {directory}. Please try again."))
    }
  }

  return(invisible())
}

