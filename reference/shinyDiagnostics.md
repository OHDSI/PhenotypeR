# Create a shiny app summarising your phenotyping results

A shiny app that is designed for any diagnostics results from
phenotypeR, this includes:

- A diagnostics on the database via `databaseDiagnostics`.

- A diagnostics on the cohort_codelist attribute of the cohort via
  `codelistDiagnostics`.

- A diagnostics on the cohort via `cohortDiagnostics`.

- A diagnostics on the population via `populationDiagnostics`.

- A diagnostics on the matched cohort via `matchedDiagnostics`.

## Usage

``` r
shinyDiagnostics(
  result,
  directory,
  minCellCount = 5,
  open = rlang::is_interactive(),
  expectations = NULL,
  conceptReview = NULL,
  clinicalDescriptions = NULL,
  databaseDescriptions = NULL,
  removeEmptyTabs = TRUE
)
```

## Arguments

- result:

  A summarised result

- directory:

  Directory where to save report

- minCellCount:

  Minimum cell count for suppression when exporting results.

- open:

  If TRUE, the shiny app will be launched in a new session. If FALSE,
  the shiny app will be created but not launched.

- expectations:

  Expectations from
  [`getCohortExpectations()`](https://ohdsi.github.io/PhenotypeR/reference/getCohortExpectations.md)
  or
  [`importCohortExpectations()`](https://ohdsi.github.io/PhenotypeR/reference/importCohortExpectations.md)

- conceptReview:

  Concept review from
  [`reviewCohortConcepts()`](https://ohdsi.github.io/PhenotypeR/reference/reviewCohortConcepts.md)

- clinicalDescriptions:

  Clinical descriptions from
  [`draftClinicalDescription()`](https://ohdsi.github.io/PhenotypeR/reference/draftClinicalDescription.md)
  or
  [`importClinicalDescription()`](https://ohdsi.github.io/PhenotypeR/reference/importClinicalDescription.md)

- databaseDescriptions:

  Database descriptions from
  [`importDatabaseDescription()`](https://ohdsi.github.io/PhenotypeR/reference/importDatabaseDescription.md)

- removeEmptyTabs:

  Whether to remove tabs of those diagnostics that have not been
  performed or that were insufficient counts to produce a result (TRUE)
  or not (FALSE)

## Value

A shiny app

## Examples

``` r
# \donttest{
library(omock)
library(CohortConstructor)
library(PhenotypeR)

cdm <- mockCdmFromDataset(source = "duckdb")
#> ℹ Loading bundled GiBleed tables from package data.
#> ℹ Adding drug_strength table.
#> ℹ Creating local <cdm_reference> object.
#> ℹ Inserting <cdm_reference> into duckdb.
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp00jdvo/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
cdm$warfarin <- conceptCohort(cdm,
                              conceptSet =  list(warfarin = c(1310149L,
                                                              40163554L)),
                              name = "warfarin")
#> ℹ Subsetting table drug_exposure using 2 concepts with domain: drug.
#> ℹ Combining tables.
#> ℹ Creating cohort attributes.
#> ℹ Applying cohort requirements.
#> ℹ Merging overlapping records.
#> ✔ Cohort warfarin created.

result <- phenotypeDiagnostics(cdm$warfarin,
                               populationDiagnostics = list("populationSample" = 100000))
#> Logging PhenotypeR progress in
#> /tmp/Rtmp00jdvo/phenotypeDiagnostics_log_{date}_{time}1b4a37294c5e.txt
#> ℹ Creating log file:
#>   /tmp/Rtmp00jdvo/phenotypeDiagnostics_log_2026_10_22_14_27_441b4a37294c5e.txt.
#> [2026-10-22 14:27:44] - Log file created
#> [2026-10-22 14:27:44] - Database diagnostics - getting CDM Snapshot
#> [2026-10-22 14:27:44] - Database diagnostics - summarising person table
#> ℹ The following estimates will be calculated:
#> • date_of_birth: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side.
#> → Start summary of data, at 2026-10-22 14:27:48.927135
#> ✔ Summary finished, at 2026-10-22 14:27:49.000632
#> [2026-10-22 14:27:49] - Database diagnostics - summarising observation period
#> ℹ retrieving cdm object from cdm_table.
#> Warning: ! There are 2649 individuals not included in the person table.
#> ℹ The following estimates will be calculated:
#> • observation_period_start_date: density
#> • observation_period_end_date: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side.
#> → Start summary of data, at 2026-10-22 14:27:52.631719
#> ✔ Summary finished, at 2026-10-22 14:27:52.721461
#> [2026-10-22 14:27:53] - Codelist diagnostics - index event breakdown
#> Getting counts of warfarin codes for cohort warfarin
#> Warning: The CDM reference containing the cohort must also contain achilles tables.
#> Returning only index event breakdown.
#> [2026-10-22 14:27:55] - Cohort diagnostics - cohort attrition
#> [2026-10-22 14:27:56] - Cohort diagnostics - cohort count
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ✔ summariseCharacteristics finished!
#> → Skipping cohort sampling as all cohorts have less than 20000 individuals.
#> [2026-10-22 14:27:57] - Cohort diagnostics - matched cohorts
#> → Sampling cohort `tmp_038_sampled_independent`
#> Returning entry cohort as the size of the cohorts to be sampled is equal or
#> smaller than `n`.
#> • Generating an age and sex matched cohort for warfarin
#> Starting matching
#> ℹ Creating copy of target cohort.
#> • 1 cohort to be matched.
#> ℹ Creating controls cohorts.
#> ℹ Excluding cases from controls
#> • Matching by gender_concept_id and year_of_birth
#> • Removing controls that were not in observation at index date
#> • Excluding target records whose pair is not in observation
#> • Adjusting ratio
#> Binding cohorts
#> ✔ Done
#> → Getting cohorts and indexes
#> [2026-10-22 14:28:10] - Cohort diagnostics - cohort characteristics
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1
#> window names cast to snake_case:
#> • `-365 to -1` -> `365_to_1`
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ℹ summarising cohort warfarin_sampled
#> ℹ summarising cohort warfarin_matched
#> ✔ summariseCharacteristics finished!
#> [2026-10-22 14:28:16] - Cohort diagnostics - age density
#> ℹ The following estimates will be calculated:
#> • age: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side.
#> → Start summary of data, at 2026-10-22 14:28:17.259849
#> ✔ Summary finished, at 2026-10-22 14:28:17.420774
#> Using defaults for windows for large scale characteristics: c(-365, -31),
#> c(-30, -1), c(0, 0), c(1, 30), and c(31, 365). These can be changed via passing
#> alternative windows as a global option
#> `PhenotypeR_summariseLargeScaleCharacteristics_window`
#> Using defaults for event tables for large scale characteristics:
#> condition_occurrence, measurement, procedure_occurrence, device_exposure, and
#> observation. These can be changed via passing alternative windows as a global
#> option `PhenotypeR_summariseLargeScaleCharacteristics_eventInWindow`
#> Using defaults for episode tables for large scale characteristics:
#> drug_exposure, drug_era, and visit_occurrence. These can be changed via passing
#> alternative windows as a global option
#> `PhenotypeR_summariseLargeScaleCharacteristics_episodeInWindow`
#> [2026-10-22 14:28:18] - Cohort diagnostics - large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 7)
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table measurement (2 of 7)
#>  - getting characteristics from table measurement (2 of 7) for time window -365…
#>  - getting characteristics from table measurement (2 of 7) for time window -30 …
#>  - getting characteristics from table measurement (2 of 7) for time window 0 an…
#>  - getting characteristics from table measurement (2 of 7) for time window 1 an…
#>  - getting characteristics from table measurement (2 of 7) for time window 31 a…
#>  - getting characteristics from table procedure_occurrence (3 of 7)
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table observation (4 of 7)
#>  - getting characteristics from table observation (4 of 7) for time window -365…
#>  - getting characteristics from table observation (4 of 7) for time window -30 …
#>  - getting characteristics from table observation (4 of 7) for time window 0 an…
#>  - getting characteristics from table observation (4 of 7) for time window 1 an…
#>  - getting characteristics from table observation (4 of 7) for time window 31 a…
#>  - getting characteristics from table drug_exposure (5 of 7)
#>  - getting characteristics from table drug_exposure (5 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (5 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 0 …
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 1 …
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 31…
#>  - getting characteristics from table drug_era (6 of 7)
#>  - getting characteristics from table drug_era (6 of 7) for time window -365 an…
#>  - getting characteristics from table drug_era (6 of 7) for time window -30 and…
#>  - getting characteristics from table drug_era (6 of 7) for time window 0 and 0
#>  - getting characteristics from table drug_era (6 of 7) for time window 1 and 30
#>  - getting characteristics from table drug_era (6 of 7) for time window 31 and …
#>  - getting characteristics from table visit_occurrence (7 of 7)
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#> Formatting result
#> 235 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 7)
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table measurement (2 of 7)
#>  - getting characteristics from table measurement (2 of 7) for time window -365…
#>  - getting characteristics from table measurement (2 of 7) for time window -30 …
#>  - getting characteristics from table measurement (2 of 7) for time window 0 an…
#>  - getting characteristics from table measurement (2 of 7) for time window 1 an…
#>  - getting characteristics from table measurement (2 of 7) for time window 31 a…
#>  - getting characteristics from table procedure_occurrence (3 of 7)
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (3 of 7) for time wi…
#>  - getting characteristics from table observation (4 of 7)
#>  - getting characteristics from table observation (4 of 7) for time window -365…
#>  - getting characteristics from table observation (4 of 7) for time window -30 …
#>  - getting characteristics from table observation (4 of 7) for time window 0 an…
#>  - getting characteristics from table observation (4 of 7) for time window 1 an…
#>  - getting characteristics from table observation (4 of 7) for time window 31 a…
#>  - getting characteristics from table drug_exposure (5 of 7)
#>  - getting characteristics from table drug_exposure (5 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (5 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 0 …
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 1 …
#>  - getting characteristics from table drug_exposure (5 of 7) for time window 31…
#>  - getting characteristics from table drug_era (6 of 7)
#>  - getting characteristics from table drug_era (6 of 7) for time window -365 an…
#>  - getting characteristics from table drug_era (6 of 7) for time window -30 and…
#>  - getting characteristics from table drug_era (6 of 7) for time window 0 and 0
#>  - getting characteristics from table drug_era (6 of 7) for time window 1 and 30
#>  - getting characteristics from table drug_era (6 of 7) for time window 31 and …
#>  - getting characteristics from table visit_occurrence (7 of 7)
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (7 of 7) for time window…
#> Formatting result
#> 235 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> `cohort_sample` and `matched_sample` cast to character.
#> [2026-10-22 14:29:02] - Population diagnosics - denominator cohort
#> [2026-10-22 14:29:02] - Population diagnosics - sampling person table to 1e+05
#> people
#> ℹ Creating denominator cohorts
#> ✔ Cohorts created in 0 min and 4 sec
#> [2026-10-22 14:29:07] - Population diagnosics - incidence
#> ℹ Getting incidence for analysis 1 of 7
#> ℹ Getting incidence for analysis 2 of 7
#> ℹ Getting incidence for analysis 3 of 7
#> ℹ Getting incidence for analysis 4 of 7
#> ℹ Getting incidence for analysis 5 of 7
#> ℹ Getting incidence for analysis 6 of 7
#> ℹ Getting incidence for analysis 7 of 7
#> ✔ Overall time taken: 0 mins and 10 secs
#> [2026-10-22 14:29:18] - Population diagnosics - prevalence
#> ℹ Getting prevalence for analysis 1 of 7
#> ℹ Getting prevalence for analysis 2 of 7
#> ℹ Getting prevalence for analysis 3 of 7
#> ℹ Getting prevalence for analysis 4 of 7
#> ℹ Getting prevalence for analysis 5 of 7
#> ℹ Getting prevalence for analysis 6 of 7
#> ℹ Getting prevalence for analysis 7 of 7
#> ✔ Time taken: 0 mins and 7 secs
#> `populationDateStart`, `populationDateEnd`, and `populationSample` cast to
#> character.
#> `populationDateStart` and `populationDateEnd` eliminated from settings as all
#> elements are NA.
#> [2026-10-22 14:29:27] - Exporting log file

shinyDiagnostics(result,
                tempdir())
#> ℹ Creating shiny from provided data
#> Warning: The following tabs from databaseDiagnostics will be removed because they are
#> not present in the summarised result: clinical_records
#> Warning: The following tabs from codelistDiagnostics will be removed because they are
#> not present in the summarised result: achilles_code_use, orphan_code_use,
#> measurement_diagnostics, and drug_diagnostics
#> Warning: The following tabs from cohortDiagnostics will be removed because they are not
#> present in the summarised result: compare_cohorts and cohort_survival
#> Warning: Unknown or uninitialised column: `diagnostics`.
#> Warning: Expectations tab in cohort_count, cohort_characteristics,
#> large_scale_characteristics, and compare_large_scale_characteristics will be
#> removed, as none were provided.
#> ℹ Shiny app created in /tmp/Rtmp00jdvo/PhenotypeRShiny

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
