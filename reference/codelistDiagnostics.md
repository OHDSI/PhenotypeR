# Run codelist-level diagnostics

\`codelistDiagnostics()\` runs phenotypeR diagnostics on the
cohort_codelist attribute on the cohort. Thus codelist attribute of the
cohort must be populated. If it is missing then it could be populated
using \`addCodelistAttribute()\` function.

Furthermore \`codelistDiagnostics()\` requires achilles tables to be
present in the cdm so that concept counts could be derived.

## Usage

``` r
codelistDiagnostics(
  cohort,
  achillesCodeUse = TRUE,
  orphanCodeUse = TRUE,
  cohortCodeUse = TRUE,
  drugDiagnostics = TRUE,
  measurementDiagnostics = TRUE,
  measurementDiagnosticsSample = 20000,
  drugDiagnosticsSample = 20000
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference. The cohort_codelist attribute must
  be populated. The cdm reference must contain achilles tables as these
  will be used for deriving concept counts.

- achillesCodeUse:

  Whether to run \`CodelistGenerator::summariseAchillesCodeUse()\`
  (TRUE) or not (FALSE).

- orphanCodeUse:

  Whether to run \`CodelistGenerator::summariseOrphanCodeUse()\` (TRUE)
  or not (FALSE).

- cohortCodeUse:

  Whether to run \`CodelistGenerator::summariseCohortCodeUse()\` (TRUE)
  or not (FALSE).

- drugDiagnostics:

  Whether to run drug diagnostics (TRUE) or not (FALSE). Note that, if
  set to TRUE, the diagnostics will only run if the cohort code list
  contains drug codes.

- measurementDiagnostics:

  Whether to run measurement diagnostics (TRUE) or not (FALSE). Note
  that, if set to TRUE, the diagnostics will only run if the cohort code
  list contains measurement codes.

- measurementDiagnosticsSample:

  The number of people to take a random sample for measurement
  diagnostics. If \`measurementDiagnosticsSample = NULL\`, no sampling
  will be performed. If \`measurementDiagnosticsSample = 0\` measurement
  diagnostics will not be run.

- drugDiagnosticsSample:

  The number of people to take a random sample for drug diagnostics. If
  \`drugDiagnosticsSample = NULL\`, no sampling will be performed. If
  \`drugDiagnosticsSample = 0\` drug diagnostics will not be run.

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
result <- codelistDiagnostics(cdm$warfarin)
#> Getting counts of warfarin codes for cohort warfarin
#> Returning entry cohort as the size of the cohorts to be sampled is equal or
#> smaller than `n`.
#> ℹ The following estimates will be calculated:
#> • exposure_duration: min, q01, q05, q25, median, q75, q95, q99, max,
#>   percentage_missing
#> • quantity: min, q01, q05, q25, median, q75, q95, q99, max, percentage_missing
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-09 10:01:28.744096
#> ✔ Summary finished, at 2026-04-09 10:01:29.615626
#> ℹ The following estimates will be calculated:
#> • days_to_next_record: min, q01, q05, q25, median, q75, q95, q99, max,
#>   percentage_missing
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-09 10:01:30.291495
#> ✔ Summary finished, at 2026-04-09 10:01:30.460017
#> ! No common ingredient found for codelist: `warfarin`.
#> ℹ Change ingredient threshold with options(PhenotypeR_ingredient_threshold),
#>   threshold = 0.8.
#> Warning: The CDM reference containing the cohort must also contain achilles tables.
#> Returning only index event breakdown.

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
