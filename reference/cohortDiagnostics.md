# Run cohort-level diagnostics

Runs phenotypeR diagnostics on the cohort. The diganostics include: \*
Age groups and sex summarised. \* A summary of visits of everyone in the
cohort using visit_occurrence table. \* A summary of age and sex density
of the cohort. \* Attrition of the cohorts. \* Overlap between cohorts
(if more than one cohort is being used).

## Usage

``` r
cohortDiagnostics(
  cohort,
  cohortId = NULL,
  cohortCount = TRUE,
  cohortCharacteristics = TRUE,
  largeScaleCharacteristics = TRUE,
  compareCohorts = TRUE,
  cohortSurvival = FALSE,
  cohortSample = 20000,
  matchedSample = 1000
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- cohortId:

  Specific cohort definition ID for which to run cohort diagnostics.

- cohortCount:

  Whether to run \`CohortCharacteristics::summariseCohortCount()\` and
  \`CohortCharacteristics::summariseCohortAttrition()\` (TRUE) or not
  (FALSE).

- cohortCharacteristics:

  Whether to run \`CohortCharacteristics::summariseCharacteristics()\`
  and summarise age density (TRUE) or not (FALSE).

- largeScaleCharacteristics:

  Whether to run
  \`CohortCharacteristics::summariseLargeScaleCharacteristics()\` (TRUE)
  or not (FALSE).

- compareCohorts:

  Whether to run \`CohortCharacteristics::summariseCohortOverlap()\` and
  \`CohortCharacteristics::summariseCohortTiming()\` (TRUE) or not
  (FALSE). Notice that, if set to TRUE, the diagnostics will only be run
  when there are more than one cohort.

- cohortSurvival:

  Whether to run \`CohortSurvival::estimateSingleEventSurvival()\`
  (TRUE) or not (FALSE).

- cohortSample:

  The number of people to take a random sample for cohortDiagnostics. If
  \`cohortSample = NULL\`, no sampling will be performed.

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
library(CDMConnector)

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

result <- cohortDiagnostics(cdm$warfarin)
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ✔ summariseCharacteristics finished!
#> → Skipping cohort sampling as all cohorts have less than 20000 individuals.
#> → Sampling cohort `tmp_006_sampled`
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
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1
#> window names casted to snake_case:
#> • `-365 to -1` -> `365_to_1`
#> ℹ summarising data
#> ℹ summarising cohort warfarin
#> ℹ summarising cohort warfarin_sampled
#> ℹ summarising cohort warfarin_matched
#> ✔ summariseCharacteristics finished!
#> ℹ The following estimates will be calculated:
#> • age: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-20 10:57:50.139336
#> ✔ Summary finished, at 2026-04-20 10:57:50.264393
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
#> 225 estimates dropped as frequency less than 1%
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
#> 225 estimates dropped as frequency less than 1%
#> ✔ Summarising large scale characteristics
#> `cohort_sample` and `matched_sample` casted to character.

cdmDisconnect(cdm)
# }
```
