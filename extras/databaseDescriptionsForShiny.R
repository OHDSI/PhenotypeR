library(jsonlite)


empty_details <- list(
  data_coverage_and_timespan = "N/A (synthetic data)",
  healthcare_setting_type_of_data = "N/A (synthetic data)",
  data_collection_process = "N/A (synthetic data)",
  general_representativeness = "N/A (synthetic data)",
  data_content_source_coding = "N/A (synthetic data)",
  data_harmonisation = "N/A (synthetic data)",
  quality_control = "N/A (synthetic data)",
  linkage = "N/A (synthetic data)",
  mortality = "N/A (synthetic data)",
  limitations = "N/A (synthetic data)"
)


list(
  administrative_details = list(
    name_of_data_source = "GiBleed synthetic database",
    data_source_acronym = "GiBleed",
    data_source_countries = "N/A (synthetic data)"
  ),
  data_elements_collected = empty_details) |>
  write_json(
    path = here::here("extras", "database_descriptions", "GIBleed.json"),
    pretty = TRUE,
    auto_unbox = TRUE)

list(
  administrative_details = list(
    name_of_data_source = "synput-1k synthetic database",
    data_source_acronym = "synput-1k",
    data_source_countries = "N/A (synthetic data)"
  ),
  data_elements_collected = empty_details) |>
  write_json(
    path = here::here("extras", "database_descriptions", "synput-1k.json"),
    pretty = TRUE,
    auto_unbox = TRUE)

list(
  administrative_details = list(
    name_of_data_source = "synthea-covid19-200k synthetic database",
    data_source_acronym = "synthea-covid19-200k",
    data_source_countries = "N/A (synthetic data)"
  ),
  data_elements_collected = empty_details) |>
  write_json(
    path = here::here("extras", "database_descriptions", "synthea-covid19-200k.json"),
    pretty = TRUE,
    auto_unbox = TRUE)

# check if will pass validation
# importDatabaseDescription(here::here("extras", "database_descriptions"))
