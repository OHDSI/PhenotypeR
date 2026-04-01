# Create a shiny app summarising your phenotyping results

A shiny app that is designed for any diagnostics results from
phenotypeR, this includes:

\* A diagnostics on the database via \`databaseDiagnostics\`. \* A
diagnostics on the cohort_codelist attribute of the cohort via
\`codelistDiagnostics\`. \* A diagnostics on the cohort via
\`cohortDiagnostics\`. \* A diagnostics on the population via
\`populationDiagnostics\`. \* A diagnostics on the matched cohort via
\`matchedDiagnostics\`.

## Usage

``` r
shinyDiagnostics(
  result,
  directory,
  minCellCount = 5,
  open = rlang::is_interactive(),
  expectations = NULL,
  clinicalDescriptionsDir = NULL,
  databaseDescriptionsDir = NULL,
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

  Data frame or tibble with cohort expectations. It must contain the
  following columns: cohort_name, estimate, value, and source.

- clinicalDescriptionsDir:

  Directory where to find the clinical descriptions word documents.

- databaseDescriptionsDir:

  Directory where to find the clinical descriptions word documents.

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
                               populationSample = 100000)
#> ℹ Creating log file:
#>   /tmp/RtmphC4rnn/phenotypeDiagnostics_log_2026_04_01_16_50_231e4d459a43f8.txt.
#> [2026-04-01 16:50:23] - Log file created
#> [2026-04-01 16:50:23] - Database diagnostics - getting CDM Snapshot
#> [2026-04-01 16:50:24] - Database diagnostics - summarising person table
#> ℹ The following estimates will be calculated:
#> • date_of_birth: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-01 16:50:28.417965
#> ✔ Summary finished, at 2026-04-01 16:50:28.475105
#> [2026-04-01 16:50:28] - Database diagnostics - summarising observation period
#> ℹ retrieving cdm object from cdm_table.
#> Warning: ! There are 2649 individuals not included in the person table.
#> ℹ The following estimates will be calculated:
#> • observation_period_start_date: density
#> • observation_period_end_date: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-01 16:50:31.682171
#> ✔ Summary finished, at 2026-04-01 16:50:31.745693
#> [2026-04-01 16:50:32] - Database diagnostics - summarising clinical tables -
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
#> [2026-04-01 16:50:36] - Database diagnostics - summarising clinical tables -
#> trends
#> [2026-04-01 16:50:36] - Codelist diagnostics - index event breakdown
#> Getting counts of warfarin codes for cohort warfarin
#> [2026-04-01 16:50:38] - Codelist diagnostics - drug diagnostics
#> Returning entry cohort as the size of the cohorts to be sampled is equal or
#> smaller than `n`.
#> ℹ The following estimates will be calculated:
#> • exposure_duration: min, q01, q05, q25, median, q75, q95, q99, max,
#>   percentage_missing
#> • quantity: min, q01, q05, q25, median, q75, q95, q99, max, percentage_missing
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-01 16:50:40.105854
#> ✔ Summary finished, at 2026-04-01 16:50:40.940423
#> ℹ The following estimates will be calculated:
#> • days_to_next_record: min, q01, q05, q25, median, q75, q95, q99, max,
#>   percentage_missing
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-01 16:50:41.578895
#> ✔ Summary finished, at 2026-04-01 16:50:41.745217
#> ! No common ingredient found for codelist: `warfarin`.
#> ℹ Change ingredient threshold with options(PhenotypeR_ingredient_threshold),
#>   threshold = 0.8.
#> Warning: The CDM reference containing the cohort must also contain achilles tables.
#> Returning only index event breakdown.
#> [2026-04-01 16:50:45] - Cohort diagnostics - cohort attrition
#> [2026-04-01 16:50:45] - Cohort diagnostics - cohort count
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ✔ summariseCharacteristics finished!
#> → Skipping cohort sampling as all cohorts have less than 20000 individuals.
#> [2026-04-01 16:50:46] - Cohort diagnostics - matched cohorts
#> → Sampling cohort `tmp_050_sampled`
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
#> [2026-04-01 16:50:57] - Cohort diagnostics - cohort characteristics
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1
#> window names casted to snake_case:
#> • `-365 to -1` -> `365_to_1`
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ℹ summarising cohort warfarin_sampled
#> ℹ summarising cohort warfarin_matched
#> ✔ summariseCharacteristics finished!
#> [2026-04-01 16:51:02] - Cohort diagnostics - age density
#> ℹ The following estimates will be calculated:
#> • age: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-01 16:51:03.283484
#> ✔ Summary finished, at 2026-04-01 16:51:03.405102
#> [2026-04-01 16:51:03] - Cohort diagnostics - large scale characteristics
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
#> 498 estimates dropped as frequency less than 1%
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
#> 498 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> `cohort_sample` and `matched_sample` casted to character.
#> [2026-04-01 16:52:04] - Population diagnosics - denominator cohort
#> [2026-04-01 16:52:04] - Population diagnosics - sampling person table to1e+05
#> ℹ Creating denominator cohorts
#> ✔ Cohorts created in 0 min and 5 sec
#> [2026-04-01 16:52:09] - Population diagnosics - incidence
#> ℹ Getting incidence for analysis 1 of 7
#> ℹ Getting incidence for analysis 2 of 7
#> ℹ Getting incidence for analysis 3 of 7
#> ℹ Getting incidence for analysis 4 of 7
#> ℹ Getting incidence for analysis 5 of 7
#> ℹ Getting incidence for analysis 6 of 7
#> ℹ Getting incidence for analysis 7 of 7
#> ✔ Overall time taken: 0 mins and 10 secs
#> [2026-04-01 16:52:20] - Population diagnosics - prevalence
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
#> [2026-04-01 16:52:26] - Phenotype diagnostics - exporting results
#> [2026-04-01 16:52:26] - Exporting log file

expectations <- dplyr::tibble("cohort_name" = "warfarin",
                       "estimate" = c("Mean age",
                                   "Male percentage",
                                   "Frequently seen comorbidities"),
                       "value" = c("32", "74%",  "Atrial fibrillation, heart failure, hypertension and ischaemic heart disease"),
                       "diagnostics" = c("cohort_characteristics", "cohort_characteristics", "compare_large_scale_characteristics"),
                       "source" = c("AlbertAI"))

shinyDiagnostics(result,
                tempdir(),
                expectations = expectations)
#> ℹ Creating shiny from provided data
#> Warning: No achilles code use or orphan codes results in codelistDiagnostics. Removing
#> tabs from the shiny app.
#> Warning: No measurements present in the concept list. Removing tab from the shiny app.
#> Warning: Only one cohort present in cohortDiagnostics. Removing Compare Cohorts tab from
#> the shiny app.
#> Warning: No survival analysis present in cohortDiagnostics. Removing tab from the shiny
#> app.
#> Warning: No expectations for cohort count. Removing tab from the shiny app.
#> Warning: No expectations for large scale characteristics. Removing tab from the shiny
#> app.
#> Warning: '/tmp/RtmphC4rnn/PhenotypeRShiny/data/raw/expectations' already exists
#> ℹ Shiny app created in /tmp/RtmphC4rnn/PhenotypeRShiny

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
