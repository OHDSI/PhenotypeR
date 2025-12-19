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
  expectations = NULL
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

## Value

A shiny app

## Examples

``` r
# \donttest{
library(omock)
library(CohortConstructor)
library(PhenotypeR)

cdm <- mockCdmFromDataset(source = "duckdb")
#> ℹ Reading GiBleed tables.
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
#>   /tmp/RtmpApsEMV/phenotypeDiagnostics_log_2025_12_19_21_30_561ede3651a001.txt.
#> [2025-12-19 21:30:56] - Log file created
#> [2025-12-19 21:30:56] - Started phenotypeDiagnostics
#> [2025-12-19 21:30:56] - Running database diagnostics
#> • Starting Database Diagnostics
#> → Getting CDM Snapshot
#> → Summarising Observation Period
#> ℹ retrieving cdm object from cdm_table.
#> Warning: ! There are 2649 individuals not included in the person table.
#> → Summarising OMOP tables
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
#> [2025-12-19 21:31:03] - Running codelist diagnostics
#> • Getting codelists from cohorts
#> • Getting index event breakdown
#> Getting counts of warfarin codes for cohort warfarin
#> Warning: The CDM reference containing the cohort must also contain achilles tables.
#> Returning only index event breakdown.
#> [2025-12-19 21:31:05] - Running cohort diagnostics
#> • Starting Cohort Diagnostics
#> → Getting cohort attrition
#> → Getting cohort count
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ✔ summariseCharacteristics finished!
#> → Skipping cohort sampling as all cohorts have less than 20000 individuals.
#> → Creating matching cohorts
#> → Sampling cohort `tmp_038_sampled`
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
#> → Summarising cohort characteristics
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1
#> window names casted to snake_case:
#> • `-365 to -1` -> `365_to_1`
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ℹ summarising cohort warfarin_sampled
#> ℹ summarising cohort warfarin_matched
#> ✔ summariseCharacteristics finished!
#> → Calculating age density
#> ℹ The following estimates will be computed:
#> • age: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2025-12-19 21:31:23.548276
#> ✔ Summary finished, at 2025-12-19 21:31:23.689444
#> → Run large scale characteristics
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 8)
#>  - getting characteristics from table condition_occurrence (1 of 8) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 8) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 8) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 8) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 8) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 8) for time wi…
#>  - getting characteristics from table condition_occurrence (1 of 8) for time wi…
#>  - getting characteristics from table visit_occurrence (2 of 8)
#>  - getting characteristics from table visit_occurrence (2 of 8) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 8) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 8) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 8) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 8) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 8) for time window…
#>  - getting characteristics from table visit_occurrence (2 of 8) for time window…
#>  - getting characteristics from table measurement (3 of 8)
#>  - getting characteristics from table measurement (3 of 8) for time window -Inf…
#>  - getting characteristics from table measurement (3 of 8) for time window -365…
#>  - getting characteristics from table measurement (3 of 8) for time window -30 …
#>  - getting characteristics from table measurement (3 of 8) for time window 0 an…
#>  - getting characteristics from table measurement (3 of 8) for time window 1 an…
#>  - getting characteristics from table measurement (3 of 8) for time window 31 a…
#>  - getting characteristics from table measurement (3 of 8) for time window 366 …
#>  - getting characteristics from table procedure_occurrence (4 of 8)
#>  - getting characteristics from table procedure_occurrence (4 of 8) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 8) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 8) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 8) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 8) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 8) for time wi…
#>  - getting characteristics from table procedure_occurrence (4 of 8) for time wi…
#>  - getting characteristics from table device_exposure (5 of 8)
#>  - getting characteristics from table device_exposure (5 of 8) for time window …
#>  - getting characteristics from table device_exposure (5 of 8) for time window …
#>  - getting characteristics from table device_exposure (5 of 8) for time window …
#>  - getting characteristics from table device_exposure (5 of 8) for time window …
#>  - getting characteristics from table device_exposure (5 of 8) for time window …
#>  - getting characteristics from table device_exposure (5 of 8) for time window …
#>  - getting characteristics from table device_exposure (5 of 8) for time window …
#>  - getting characteristics from table observation (6 of 8)
#>  - getting characteristics from table observation (6 of 8) for time window -Inf…
#>  - getting characteristics from table observation (6 of 8) for time window -365…
#>  - getting characteristics from table observation (6 of 8) for time window -30 …
#>  - getting characteristics from table observation (6 of 8) for time window 0 an…
#>  - getting characteristics from table observation (6 of 8) for time window 1 an…
#>  - getting characteristics from table observation (6 of 8) for time window 31 a…
#>  - getting characteristics from table observation (6 of 8) for time window 366 …
#>  - getting characteristics from table drug_exposure (7 of 8)
#>  - getting characteristics from table drug_exposure (7 of 8) for time window -I…
#>  - getting characteristics from table drug_exposure (7 of 8) for time window -3…
#>  - getting characteristics from table drug_exposure (7 of 8) for time window -3…
#>  - getting characteristics from table drug_exposure (7 of 8) for time window 0 …
#>  - getting characteristics from table drug_exposure (7 of 8) for time window 1 …
#>  - getting characteristics from table drug_exposure (7 of 8) for time window 31…
#>  - getting characteristics from table drug_exposure (7 of 8) for time window 36…
#>  - getting characteristics from table drug_era (8 of 8)
#>  - getting characteristics from table drug_era (8 of 8) for time window -Inf an…
#>  - getting characteristics from table drug_era (8 of 8) for time window -365 an…
#>  - getting characteristics from table drug_era (8 of 8) for time window -30 and…
#>  - getting characteristics from table drug_era (8 of 8) for time window 0 and 0
#>  - getting characteristics from table drug_era (8 of 8) for time window 1 and 30
#>  - getting characteristics from table drug_era (8 of 8) for time window 31 and …
#>  - getting characteristics from table drug_era (8 of 8) for time window 366 and…
#> Formatting result
#> 842 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> `cohort_sample` and `matched_sample` casted to character.
#> [2025-12-19 21:31:58] - Running population diagnostics
#> • Creating denominator for incidence and prevalence
#> • Sampling person table to 1e+06
#> ℹ Creating denominator cohorts
#> ✔ Cohorts created in 0 min and 5 sec
#> • Estimating incidence
#> ℹ Getting incidence for analysis 1 of 7
#> ℹ Getting incidence for analysis 2 of 7
#> ℹ Getting incidence for analysis 3 of 7
#> ℹ Getting incidence for analysis 4 of 7
#> ℹ Getting incidence for analysis 5 of 7
#> ℹ Getting incidence for analysis 6 of 7
#> ℹ Getting incidence for analysis 7 of 7
#> ✔ Overall time taken: 0 mins and 10 secs
#> • Estimating prevalence
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
#> 
#> [2025-12-19 21:32:21] - Exporting log file
#> 

expectations <- dplyr::tibble("cohort_name" = "warfarin",
                       "value" = c("Mean age",
                                   "Male percentage",
                                   "Survival probability after 5y"),
                       "estimate" = c("32", "74%",  "4%"),
                       "source" = c("AlbertAI"))

shinyDiagnostics(result, tempdir(), expectations = expectations)
#> ℹ Creating shiny from provided data
#> Warning: No achilles code use or orphan codes results in codelistDiagnostics. Removing
#> tabs from the shiny app.
#> Warning: No measurements present in the concept list. Removing tab from the shiny app.
#> Warning: No survival analysis present in cohortDiagnostics. Removing tab from the shiny
#> app.
#> Warning: '/tmp/RtmpApsEMV/PhenotypeRShiny/data/raw/expectations' already exists
#> ℹ Shiny app created in /tmp/RtmpApsEMV/PhenotypeRShiny

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
