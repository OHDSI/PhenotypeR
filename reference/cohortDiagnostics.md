# Run cohort-level diagnostics

Runs phenotypeR diagnostics on the cohort. The diganostics include: \*
Age groups and sex summarised. \* A summary of visits of everyone in the
cohort using visit_occurrence table. \* A summary of age and sex density
of the cohort. \* Attritions of the cohorts. \* Overlap between cohorts
(if more than one cohort is being used).

## Usage

``` r
cohortDiagnostics(
  cohort,
  survival = FALSE,
  cohortSample = 20000,
  matchedSample = 1000
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- survival:

  Boolean variable. Whether to conduct survival analysis (TRUE) or not
  (FALSE).

- cohortSample:

  The number of people to take a random sample for cohortDiagnostics. If
  \`cohortSample = NULL\`, no sampling will be performed,

- matchedSample:

  The number of people to take a random sample for matching. If
  \`matchedSample = NULL\`, no sampling will be performed. If
  \`matchedSample = 0\`, no matched cohorts will be created.

## Value

A summarised result

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

result <- cohortDiagnostics(cdm$warfarin)
#> • Starting Cohort Diagnostics
#> → Getting cohort attrition
#> → Getting cohort count
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ✔ summariseCharacteristics finished!
#> → Skipping cohort sampling as all cohorts have less than 20000 individuals.
#> → Creating matching cohorts
#> → Sampling cohort `tmp_004_sampled`
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
#> → Start summary of data, at 2025-12-03 15:32:23.310636
#> ✔ Summary finished, at 2025-12-03 15:32:23.454847
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
#> 886 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> `cohort_sample` and `matched_sample` casted to character.
# }
```
