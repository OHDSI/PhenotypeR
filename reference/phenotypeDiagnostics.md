# Phenotype a cohort

This comprises all the diagnostics that are being offered in this
package, this includes:

\* A diagnostics on the database via \`databaseDiagnostics\`. \* A
diagnostics on the cohort_codelist attribute of the cohort via
\`codelistDiagnostics\`. \* A diagnostics on the cohort via
\`cohortDiagnostics\`. \* A diagnostics on the population via
\`populationDiagnostics\`.

## Usage

``` r
phenotypeDiagnostics(
  cohort,
  diagnostics = c("databaseDiagnostics", "codelistDiagnostics", "cohortDiagnostics",
    "populationDiagnostics"),
  measurementSample = 20000,
  survival = FALSE,
  cohortSample = 20000,
  matchedSample = 1000,
  populationSample = 1e+06,
  populationDateRange = as.Date(c(NA, NA))
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- diagnostics:

  Vector indicating which diagnostics to perform. Options include:
  \`databaseDiagnostics\`, \`codelistDiagnostics\`,
  \`cohortDiagnostics\`, and \`populationDiagnostics\`.

- measurementSample:

  The number of people to take a random sample for measurement
  diagnostics. If \`measurementSample = NULL\`, no sampling will be
  performed. If \`measurementSample = 0\` measurement diagnostics will
  not be run.

- survival:

  Boolean variable. Whether to conduct survival analysis (TRUE) or not
  (FALSE).

- cohortSample:

  The number of people to take a random sample for cohortDiagnostics. If
  \`cohortSample = NULL\`, no sampling will be performed.

- matchedSample:

  The number of people to take a random sample for matching. If
  \`matchedSample = NULL\`, no sampling will be performed. If
  \`matchedSample = 0\`, no matched cohorts will be created.

- populationSample:

  Number of people from the cdm to sample. If NULL no sampling will be
  performed. Sample will be within populationDateRange if specified.

- populationDateRange:

  Two dates. The first indicating the earliest cohort start date and the
  second indicating the latest possible cohort end date. If NULL or the
  first date is set as missing, the earliest observation_start_date in
  the observation_period table will be used for the former. If NULL or
  the second date is set as missing, the latest observation_end_date in
  the observation_period table will be used for the latter.

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
#> ℹ Creating log file:
#>   /tmp/Rtmpc9CESL/phenotypeDiagnostics_log_2026_02_18_07_07_531d252eb900a6.txt.
#> [2026-02-18 07:07:53] - Log file created
#> [2026-02-18 07:07:53] - Phenotype diagnostics - input validation
#> [2026-02-18 07:07:53] - Database diagnostics - input validation
#> [2026-02-18 07:07:53] - Database diagnostics - getting CDM Snapshot
#> [2026-02-18 07:07:53] - Database diagnostics - summarising person table
#> ℹ The following estimates will be calculated:
#> • date_of_birth: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-18 07:07:57.629706
#> ✔ Summary finished, at 2026-02-18 07:07:57.684945
#> [2026-02-18 07:07:57] - Database diagnostics - summarising observation period
#> ℹ retrieving cdm object from cdm_table.
#> Warning: ! There are 2649 individuals not included in the person table.
#> ℹ The following estimates will be calculated:
#> • observation_period_start_date: density
#> • observation_period_end_date: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-18 07:08:00.919434
#> ✔ Summary finished, at 2026-02-18 07:08:00.994497
#> [2026-02-18 07:08:01] - Database diagnostics - summarising clinical tables -
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
#> [2026-02-18 07:08:05] - Database diagnostics - summarising clinical tables -
#> trends
#> [2026-02-18 07:08:05] - Codelist diagnostics - input validation
#> [2026-02-18 07:08:06] - Codelist diagnostics - index event breakdown
#> Getting counts of warfarin codes for cohort warfarin
#> • Getting diagnostics for drug concepts
#> ✔ Dose calculated for the following codelists and ingredients:
#> codelist_name: `warfarin`; ingredient: `Warfarin`
#> ℹ Change ingredient threshold with options(PhenotypeR_ingredient_threshold).
#> Warning: The CDM reference containing the cohort must also contain achilles tables.
#> Returning only index event breakdown.
#> [2026-02-18 07:08:17] - Cohort diagnostics - input validation
#> [2026-02-18 07:08:17] - Cohort diagnostics - cohort attrition
#> [2026-02-18 07:08:17] - Cohort diagnostics - cohort count
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ✔ summariseCharacteristics finished!
#> → Skipping cohort sampling as all cohorts have less than 20000 individuals.
#> [2026-02-18 07:08:18] - Cohort diagnostics - matched cohorts
#> → Sampling cohort `tmp_028_sampled`
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
#> [2026-02-18 07:08:29] - Cohort diagnostics - cohort characteristics
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1
#> window names casted to snake_case:
#> • `-365 to -1` -> `365_to_1`
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ℹ summarising cohort warfarin_sampled
#> ℹ summarising cohort warfarin_matched
#> ✔ summariseCharacteristics finished!
#> [2026-02-18 07:08:34] - Cohort diagnostics - age density
#> ℹ The following estimates will be calculated:
#> • age: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-18 07:08:34.85837
#> ✔ Summary finished, at 2026-02-18 07:08:34.982161
#> [2026-02-18 07:08:35] - Cohort diagnostics - large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 7)
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
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
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table measurement (3 of 7)
#>  - getting characteristics from table measurement (3 of 7) for time window -Inf…
#>  - getting characteristics from table measurement (3 of 7) for time window -365…
#>  - getting characteristics from table measurement (3 of 7) for time window -30 …
#>  - getting characteristics from table measurement (3 of 7) for time window 0 an…
#>  - getting characteristics from table measurement (3 of 7) for time window 1 an…
#>  - getting characteristics from table measurement (3 of 7) for time window 31 a…
#>  - getting characteristics from table measurement (3 of 7) for time window 366 …
#>  - getting characteristics from table procedure_occurrence (4 of 7)
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table observation (5 of 7)
#>  - getting characteristics from table observation (5 of 7) for time window -Inf…
#>  - getting characteristics from table observation (5 of 7) for time window -365…
#>  - getting characteristics from table observation (5 of 7) for time window -30 …
#>  - getting characteristics from table observation (5 of 7) for time window 0 an…
#>  - getting characteristics from table observation (5 of 7) for time window 1 an…
#>  - getting characteristics from table observation (5 of 7) for time window 31 a…
#>  - getting characteristics from table observation (5 of 7) for time window 366 …
#>  - getting characteristics from table drug_exposure (6 of 7)
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -I…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 0 …
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 1 …
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 31…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 36…
#>  - getting characteristics from table drug_era (7 of 7)
#>  - getting characteristics from table drug_era (7 of 7) for time window -Inf an…
#>  - getting characteristics from table drug_era (7 of 7) for time window -365 an…
#>  - getting characteristics from table drug_era (7 of 7) for time window -30 and…
#>  - getting characteristics from table drug_era (7 of 7) for time window 0 and 0
#>  - getting characteristics from table drug_era (7 of 7) for time window 1 and 30
#>  - getting characteristics from table drug_era (7 of 7) for time window 31 and …
#>  - getting characteristics from table drug_era (7 of 7) for time window 366 and…
#> Formatting result
#> 486 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 7)
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 7) for time wi…
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
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 7) for time window…
#>  - getting characteristics from table measurement (3 of 7)
#>  - getting characteristics from table measurement (3 of 7) for time window -Inf…
#>  - getting characteristics from table measurement (3 of 7) for time window -365…
#>  - getting characteristics from table measurement (3 of 7) for time window -30 …
#>  - getting characteristics from table measurement (3 of 7) for time window 0 an…
#>  - getting characteristics from table measurement (3 of 7) for time window 1 an…
#>  - getting characteristics from table measurement (3 of 7) for time window 31 a…
#>  - getting characteristics from table measurement (3 of 7) for time window 366 …
#>  - getting characteristics from table procedure_occurrence (4 of 7)
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 7) for time wi…
#>  - getting characteristics from table observation (5 of 7)
#>  - getting characteristics from table observation (5 of 7) for time window -Inf…
#>  - getting characteristics from table observation (5 of 7) for time window -365…
#>  - getting characteristics from table observation (5 of 7) for time window -30 …
#>  - getting characteristics from table observation (5 of 7) for time window 0 an…
#>  - getting characteristics from table observation (5 of 7) for time window 1 an…
#>  - getting characteristics from table observation (5 of 7) for time window 31 a…
#>  - getting characteristics from table observation (5 of 7) for time window 366 …
#>  - getting characteristics from table drug_exposure (6 of 7)
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -I…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window -3…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 0 …
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 1 …
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 31…
#>  - getting characteristics from table drug_exposure (6 of 7) for time window 36…
#>  - getting characteristics from table drug_era (7 of 7)
#>  - getting characteristics from table drug_era (7 of 7) for time window -Inf an…
#>  - getting characteristics from table drug_era (7 of 7) for time window -365 an…
#>  - getting characteristics from table drug_era (7 of 7) for time window -30 and…
#>  - getting characteristics from table drug_era (7 of 7) for time window 0 and 0
#>  - getting characteristics from table drug_era (7 of 7) for time window 1 and 30
#>  - getting characteristics from table drug_era (7 of 7) for time window 31 and …
#>  - getting characteristics from table drug_era (7 of 7) for time window 366 and…
#> Formatting result
#> 486 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> `cohort_sample` and `matched_sample` casted to character.
#> [2026-02-18 07:09:34] - Population diagnosics - input validation
#> [2026-02-18 07:09:34] - Population diagnosics - denominator cohort
#> [2026-02-18 07:09:34] - Population diagnosics - sampling person table to1e+06
#> ℹ Creating denominator cohorts
#> ✔ Cohorts created in 0 min and 5 sec
#> [2026-02-18 07:09:40] - Population diagnosics - incidence
#> ℹ Getting incidence for analysis 1 of 7
#> ℹ Getting incidence for analysis 2 of 7
#> ℹ Getting incidence for analysis 3 of 7
#> ℹ Getting incidence for analysis 4 of 7
#> ℹ Getting incidence for analysis 5 of 7
#> ℹ Getting incidence for analysis 6 of 7
#> ℹ Getting incidence for analysis 7 of 7
#> ✔ Overall time taken: 0 mins and 10 secs
#> [2026-02-18 07:09:50] - Population diagnosics - prevalence
#> ℹ Getting prevalence for analysis 1 of 7
#> ℹ Getting prevalence for analysis 2 of 7
#> ℹ Getting prevalence for analysis 3 of 7
#> ℹ Getting prevalence for analysis 4 of 7
#> ℹ Getting prevalence for analysis 5 of 7
#> ℹ Getting prevalence for analysis 6 of 7
#> ℹ Getting prevalence for analysis 7 of 7
#> ✔ Time taken: 0 mins and 6 secs
#> `populationDateStart`, `populationDateEnd`, and `populationSample` casted to
#> character.
#> `populationDateStart` and `populationDateEnd` eliminated from settings as all
#> elements are NA.
#> [2026-02-18 07:09:57] - Phenotype diagnostics - exporting results
#> [2026-02-18 07:09:57] - Exporting log file
# }
```
