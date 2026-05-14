
#' Data source description specification
#'
#' @param path If NULL, specification will be returned as an R object. If a
#' path to a directory is provided the specification will be exported.
#'
#' @returns JSON specification for data source descriptions
#' @export
dataSourceDescriptionSpecification <- function(path = NULL){

 database_description_spec <-  defineDataSourceSpec()

 if(!is.null(path)){
   jsonlite::write_json(
    database_description_spec,
    path = here::here("inst", "data_source_specification.json"),
    auto_unbox = TRUE,
    pretty = TRUE)
 }

  jsonlite::toJSON(
    database_description_spec,
    auto_unbox = TRUE,
    pretty = TRUE
  )
}

defineDataSourceSpec <- function() {
  list(
    title = "Data source description",
    description = "A specification for data source descriptions",
    type = "object",
    properties = list(

      administrative_details = list(
        type = "object",
        description = "Administrative metadata for the data source",
        properties = list(
          name_of_data_source = list(
            type = "string",
            description = "The full name of the data source"
          ),
          data_source_acronym = list(
            type = "string",
            description = "Short abbreviation for the database."
          ),
          data_source_countries = list(
            type = "string",
            description = "The URL of the official data source website."
          ),
          data_source_website = list(
            type = "string",
            description = "The URL of the official data source website."
          ),
          hma_ema_catalogue = list(
            type = "string",
            description = "The URL of the HMA-EMA Catalogue entry."
          ),
          main_references = list(
            type = "string",
            description = "References to publications describing the dataset."
          )
        ),
        required = c("name_of_data_source",
                     "data_source_acronym",
                     "data_source_countries"),
        additionalProperties = FALSE
      ),

      data_elements_collected = list(
        type = "object",
        description = "Information regarding the types of data captured.",
        properties = list(
          data_coverage_and_timespan = list(
            type = "string",
            description = "The calendar time covered by dataset and information of the population captured."
          ),
          healthcare_setting_type_of_data = list(
            type = "string",
            description = "The category of data (e.g., Registry, EHR, Claims)."
          ),
          data_collection_process = list(
            type = "string",
            description = "How data is captured"
          ),
          general_representativeness = list(
            type = "string",
            description = "Representativeness of the dataset compared to the underlying population."
          ),
          data_content_source_coding = list(
            type = "string",
            description = "What data elements are captured and what source vocabularies are used."
          ),
          data_harmonisation = list(
            type = "string",
            description = "Description of process of mapping source data to the OMOP Common Data Model"
          ),
          quality_control = list(
            type = "string",
            description = "Summary of quality control processes performed on source data and in mapping to the OMOP Common Data Model."
          ),
          linkage = list(
            type = "string",
            description = "Description of patient-level linkages for different datasets, if any."
          ),
          mortality = list(
            type = "string",
            description = "How are deaths captured for individuals included in the data source."
          ),
          limitations = list(
            type = "string",
            description = "Summary of limitations of the data source."
          )
        ),
        required = c("data_coverage_and_timespan",
                     "healthcare_setting_type_of_data",
                     "data_collection_process",
                     "general_representativeness",
                     "data_content_source_coding",
                     "data_harmonisation",
                     "quality_control",
                     "linkage",
                     "mortality",
                     "limitations"),
        additionalProperties = FALSE
      )
    ),
    required = c("administrative_details", "data_elements_collected")
  )
}
