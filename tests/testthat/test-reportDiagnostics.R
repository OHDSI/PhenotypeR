# test_that("basic working example with one cohort", {
#
#   cdm_local <- omock::mockCdmReference() |>
#     omock::mockPerson(nPerson = 100) |>
#     omock::mockObservationPeriod() |>
#     omock::mockConditionOccurrence() |>
#     omock::mockDrugExposure() |>
#     omock::mockObservation() |>
#     omock::mockMeasurement() |>
#     omock::mockCohort(name = "my_cohort")
#   cdm_local$visit_occurrence <- dplyr::tibble(
#     person_id = 1L,
#     visit_occurrence_id = 1L,
#     visit_concept_id = 1L,
#     visit_start_date = as.Date("2000-01-01"),
#     visit_end_date = as.Date("2000-01-01"),
#     visit_type_concept_id = 1L
#   )
#   cdm_local$procedure_occurrence <- dplyr::tibble(
#     person_id = 1L,
#     procedure_occurrence_id = 1L,
#     procedure_concept_id = 1L,
#     procedure_date = as.Date("2000-01-01"),
#     procedure_type_concept_id = 1L
#   )
#
#   db <- DBI::dbConnect(duckdb::duckdb())
#   cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
#                                  schema ="main", overwrite = TRUE)
#   my_result <- cdm$my_cohort |> cohortDiagnostics()
#   expect_no_error(reportDiagnostics(result = my_result))
#
#   CDMConnector::cdm_disconnect(cdm )
#   })
#
# test_that("basic working example with two cohorts", {
#
#   cdm_local <- omock::mockCdmReference() |>
#     omock::mockPerson(nPerson = 100) |>
#     omock::mockObservationPeriod() |>
#     omock::mockConditionOccurrence() |>
#     omock::mockDrugExposure() |>
#     omock::mockObservation() |>
#     omock::mockMeasurement() |>
#     omock::mockCohort(name = "my_cohort",
#                       numberCohorts = 2)
#   cdm_local$visit_occurrence <- dplyr::tibble(
#     person_id = 1L,
#     visit_occurrence_id = 1L,
#     visit_concept_id = 1L,
#     visit_start_date = as.Date("2000-01-01"),
#     visit_end_date = as.Date("2000-01-01"),
#     visit_type_concept_id = 1L
#   )
#   cdm_local$procedure_occurrence <- dplyr::tibble(
#     person_id = 1L,
#     procedure_occurrence_id = 1L,
#     procedure_concept_id = 1L,
#     procedure_date = as.Date("2000-01-01"),
#     procedure_type_concept_id = 1L
#   )
#
#   db <- DBI::dbConnect(duckdb::duckdb())
#   cdm <- CDMConnector::copyCdmTo(con = db, cdm = cdm_local,
#                                  schema ="main", overwrite = TRUE)
#   my_result <- cdm$my_cohort |> cohortDiagnostics()
#   expect_no_error(reportDiagnostics(result = my_result))
#
#   CDMConnector::cdm_disconnect(cdm )
#
#
# })
