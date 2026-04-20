# Phenotype a cohort

This comprises all the diagnostics that are being offered in this
package, this includes:

- A diagnostic on the OMOP CDM dataset as a whole via
  `databaseDiagnostics`.

- A diagnostic on the codelists associated with cohorts via
  `codelistDiagnostics`.

- A diagnostic on the cohort itself via `cohortDiagnostics`.

- A diagnostic on the frequency of the cohort in the dataset population
  via `populationDiagnostics`.

## Usage

``` r
phenotypeDiagnostics(
  cohort,
  databaseDiagnostics = list(),
  codelistDiagnostics = list(),
  cohortDiagnostics = list(),
  populationDiagnostics = list(),
  stagingDirectory = NULL
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- databaseDiagnostics:

  A list of arguments that uses \`databaseDiagnostics\`. If the list is
  empty, the default values will be used. Example: In the following
  example, all diagnostics will be run except \*person table summary\*
  from databaseDiagnostics: \*databaseDiagnostics = list(
  "personTableSummary" = FALSE )

- codelistDiagnostics:

  A list of arguments that uses \`codelistDiagnostics\`. If the list is
  empty, the default values will be used. Example: In the below example,
  all diagnostics will be run, and a subsample of 1,000 participants
  will be used to run measurement diagnostics and another independent
  subsample of 500 participants will be used to run drug diagnostics:
  \*codelistDiagnostics = list( "measurementDiagnosticsSample" = 1000,
  "drugDiagnosticsSample" = 500 )

- cohortDiagnostics:

  A list of arguments that uses \`cohortDiagnostics\`. If the list is
  empty, the default values will be used. Example: \*cohortDiagnostics =
  list( "cohortSurvival" = TRUE )

- populationDiagnostics:

  A list of arguments that uses \`populationDiagnostics\`. If the list
  is empty, the default values will be used. Example: In the below
  example, all diagnostics will be run and a subsample of 100,000
  participants will be used to run populationDiagnostics.
  \*populationDiagnostics = list( "populationSample" = 100000 )

- stagingDirectory:

  Path to folder to save incremental results and log file

## Value

A summarised result

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
result <- phenotypeDiagnostics(cdm$warfarin)
#> Logging PhenotypeR progress in
#> /tmp/RtmpRuZHZP/phenotypeDiagnostics_log_{date}_{time}1c091f458429.txt
#> ℹ Creating log file:
#>   /tmp/RtmpRuZHZP/phenotypeDiagnostics_log_2026_04_20_10_59_121c091f458429.txt.
#> [2026-04-20 10:59:12] - Log file created
#> [2026-04-20 10:59:12] - Database diagnostics - getting CDM Snapshot
#> [2026-04-20 10:59:12] - Database diagnostics - summarising person table
#> ℹ The following estimates will be calculated:
#> • date_of_birth: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-20 10:59:16.333723
#> ✔ Summary finished, at 2026-04-20 10:59:16.396421
#> [2026-04-20 10:59:16] - Database diagnostics - summarising observation period
#> ℹ retrieving cdm object from cdm_table.
#> Warning: ! There are 2649 individuals not included in the person table.
#> ℹ The following estimates will be calculated:
#> • observation_period_start_date: density
#> • observation_period_end_date: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-20 10:59:19.573462
#> ✔ Summary finished, at 2026-04-20 10:59:19.645147
#> [2026-04-20 10:59:20] - Database diagnostics - summarising clinical tables -
#> summary
#> ℹ Adding variables of interest to drug_exposure.
#> ℹ Summarising records per person in drug_exposure.
#> ℹ Summarising subjects not in person table in drug_exposure.
#> ℹ Summarising records in observation in drug_exposure.
#> ℹ Summarising records with start before birth date in drug_exposure.
#> ℹ Summarising records with end date before start date in drug_exposure.
#> ℹ Summarising domains in drug_exposure.
#> ℹ Summarising standard concepts in drug_exposure.
#> ℹ Summarising source vocabularies in drug_exposure.
#> ℹ Summarising concept types in drug_exposure.
#> ℹ Summarising concept class in drug_exposure.
#> ℹ Summarising missing data in drug_exposure.
#> [2026-04-20 10:59:23] - Database diagnostics - summarising clinical tables -
#> trends
#> [2026-04-20 10:59:24] - Codelist diagnostics - index event breakdown
#> Getting counts of warfarin codes for cohort warfarin
#> [2026-04-20 10:59:26] - Codelist diagnostics - drug diagnostics
#> Returning entry cohort as the size of the cohorts to be sampled is equal or
#> smaller than `n`.
#> ℹ The following estimates will be calculated:
#> • exposure_duration: min, q01, q05, q25, median, q75, q95, q99, max,
#>   percentage_missing
#> • quantity: min, q01, q05, q25, median, q75, q95, q99, max, percentage_missing
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-20 10:59:27.85244
#> ✔ Summary finished, at 2026-04-20 10:59:28.659155
#> ℹ The following estimates will be calculated:
#> • days_to_next_record: min, q01, q05, q25, median, q75, q95, q99, max,
#>   percentage_missing
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-20 10:59:29.439036
#> ✔ Summary finished, at 2026-04-20 10:59:29.59129
#> ! No common ingredient found for codelist: `warfarin`.
#> ℹ Change ingredient threshold with options(PhenotypeR_ingredient_threshold),
#>   threshold = 0.8.
#> Warning: The CDM reference containing the cohort must also contain achilles tables.
#> Returning only index event breakdown.
#> [2026-04-20 10:59:33] - Cohort diagnostics - cohort attrition
#> [2026-04-20 10:59:33] - Cohort diagnostics - cohort count
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ✔ summariseCharacteristics finished!
#> → Skipping cohort sampling as all cohorts have less than 20000 individuals.
#> [2026-04-20 10:59:34] - Cohort diagnostics - matched cohorts
#> → Sampling cohort `tmp_036_sampled`
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
#> [2026-04-20 10:59:44] - Cohort diagnostics - cohort characteristics
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1
#> window names casted to snake_case:
#> • `-365 to -1` -> `365_to_1`
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ℹ summarising cohort warfarin_sampled
#> ℹ summarising cohort warfarin_matched
#> ✔ summariseCharacteristics finished!
#> [2026-04-20 10:59:49] - Cohort diagnostics - age density
#> ℹ The following estimates will be calculated:
#> • age: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-20 10:59:50.23914
#> ✔ Summary finished, at 2026-04-20 10:59:50.354373
#> Using defaults for windows for large scale characteristics: c(-365, -31),
#> c(-30, -1), c(0, 0), c(1, 30), and c(31, 365). These can be changed via passing
#> alternative windows as a global option
#> `PhenotypeR_summariseLargeScaleCharacteristics_window`
#> Using defaults for event tables for large scale characteristics:
#> condition_occurrence, visit_occurrence, measurement, procedure_occurrence,
#> device_exposure, and observation. These can be changed via passing alternative
#> windows as a global option
#> `PhenotypeR_summariseLargeScaleCharacteristics_eventInWindow`
#> Using defaults for episode tables for large scale characteristics:
#> drug_exposure and drug_era. These can be changed via passing alternative
#> windows as a global option
#> `PhenotypeR_summariseLargeScaleCharacteristics_episodeInWindow`
#> [2026-04-20 10:59:50] - Cohort diagnostics - large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 7)
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table visit_occurrence (2 of 7)
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table measurement (3 of 7)
#>  - getting characteristics from table measurement (3 of 7) for time window -365…
#>  - getting characteristics from table measurement (3 of 7) for time window -30 …
#>  - getting characteristics from table measurement (3 of 7) for time window 0 an…
#>  - getting characteristics from table measurement (3 of 7) for time window 1 an…
#>  - getting characteristics from table measurement (3 of 7) for time window 31 a…
#>  - getting characteristics from table procedure_occurrence (4 of 7)
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table observation (5 of 7)
#>  - getting characteristics from table observation (5 of 7) for time window -365…
#>  - getting characteristics from table observation (5 of 7) for time window -30 …
#>  - getting characteristics from table observation (5 of 7) for time window 0 an…
#>  - getting characteristics from table observation (5 of 7) for time window 1 an…
#>  - getting characteristics from table observation (5 of 7) for time window 31 a…
#>  - getting characteristics from table drug_exposure (6 of 7)
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 0 …
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 1 …
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 31…
#>  - getting characteristics from table drug_era (7 of 7)
#>  - getting characteristics from table drug_era (7 of 7) for time window -365 an…
#>  - getting characteristics from table drug_era (7 of 7) for time window -30 and…
#>  - getting characteristics from table drug_era (7 of 7) for time window 0 and 0
#>  - getting characteristics from table drug_era (7 of 7) for time window 1 and 30
#>  - getting characteristics from table drug_era (7 of 7) for time window 31 and …
#> Formatting result
#> 228 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 7)
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table visit_occurrence (2 of 7)
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table measurement (3 of 7)
#>  - getting characteristics from table measurement (3 of 7) for time window -365…
#>  - getting characteristics from table measurement (3 of 7) for time window -30 …
#>  - getting characteristics from table measurement (3 of 7) for time window 0 an…
#>  - getting characteristics from table measurement (3 of 7) for time window 1 an…
#>  - getting characteristics from table measurement (3 of 7) for time window 31 a…
#>  - getting characteristics from table procedure_occurrence (4 of 7)
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table observation (5 of 7)
#>  - getting characteristics from table observation (5 of 7) for time window -365…
#>  - getting characteristics from table observation (5 of 7) for time window -30 …
#>  - getting characteristics from table observation (5 of 7) for time window 0 an…
#>  - getting characteristics from table observation (5 of 7) for time window 1 an…
#>  - getting characteristics from table observation (5 of 7) for time window 31 a…
#>  - getting characteristics from table drug_exposure (6 of 7)
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 0 …
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 1 …
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 31…
#>  - getting characteristics from table drug_era (7 of 7)
#>  - getting characteristics from table drug_era (7 of 7) for time window -365 an…
#>  - getting characteristics from table drug_era (7 of 7) for time window -30 and…
#>  - getting characteristics from table drug_era (7 of 7) for time window 0 and 0
#>  - getting characteristics from table drug_era (7 of 7) for time window 1 and 30
#>  - getting characteristics from table drug_era (7 of 7) for time window 31 and …
#> Formatting result
#> 228 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> `cohort_sample` and `matched_sample` casted to character.
#> [2026-04-20 11:00:33] - Population diagnosics - denominator cohort
#> [2026-04-20 11:00:33] - Population diagnosics - sampling person table to 1e+05
#> people
#> ℹ Creating denominator cohorts
#> ✔ Cohorts created in 0 min and 5 sec
#> [2026-04-20 11:00:39] - Population diagnosics - incidence
#> ℹ Getting incidence for analysis 1 of 7
#> ℹ Getting incidence for analysis 2 of 7
#> ℹ Getting incidence for analysis 3 of 7
#> ℹ Getting incidence for analysis 4 of 7
#> ℹ Getting incidence for analysis 5 of 7
#> ℹ Getting incidence for analysis 6 of 7
#> ℹ Getting incidence for analysis 7 of 7
#> ✔ Overall time taken: 0 mins and 9 secs
#> [2026-04-20 11:00:49] - Population diagnosics - prevalence
#> ℹ Getting prevalence for analysis 1 of 7
#> ℹ Getting prevalence for analysis 2 of 7
#> ℹ Getting prevalence for analysis 3 of 7
#> ℹ Getting prevalence for analysis 4 of 7
#> ℹ Getting prevalence for analysis 5 of 7
#> ℹ Getting prevalence for analysis 6 of 7
#> ℹ Getting prevalence for analysis 7 of 7
#> ✔ Time taken: 0 mins and 5 secs
#> `populationDateStart`, `populationDateEnd`, and `populationSample` casted to
#> character.
#> `populationDateStart` and `populationDateEnd` eliminated from settings as all
#> elements are NA.
#> [2026-04-20 11:00:55] - Exporting log file

# }
```
