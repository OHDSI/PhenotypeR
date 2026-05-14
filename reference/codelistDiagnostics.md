# Run codelist-level diagnostics

`codelistDiagnostics()` runs phenotypeR diagnostics on the
cohort_codelist attribute on the cohort. Thus codelist attribute of the
cohort must be populated. If it is missing then it could be populated
using
[`addCodelistAttribute()`](https://ohdsi.github.io/PhenotypeR/reference/addCodelistAttribute.md)
function.

Furthermore `codelistDiagnostics()` requires achilles tables to be
present in the cdm so that concept counts could be derived.

## Usage

``` r
codelistDiagnostics(
  cohort,
  cohortId = NULL,
  achillesCodeUse = FALSE,
  orphanCodeUse = TRUE,
  cohortCodeUse = TRUE,
  drugDiagnostics = FALSE,
  drugDiagnosticsSample = 20000,
  measurementDiagnostics = FALSE,
  measurementDiagnosticsSample = 20000
)
```

## Arguments

- cohort:

  A cohort table in a cdm reference. The cohort_codelist attribute must
  be populated. The cdm reference must contain achilles tables as these
  will be used for deriving concept counts.

- cohortId:

  Specific cohort definition ID for which to run codelist diagnostics.

- achillesCodeUse:

  Whether to run
  [`CodelistGenerator::summariseAchillesCodeUse()`](https://darwin-eu.github.io/CodelistGenerator/reference/summariseAchillesCodeUse.html)
  (TRUE) or not (FALSE).

- orphanCodeUse:

  Whether to run `CodelistGenerator::summariseOrphanCodeUse()` (TRUE) or
  not (FALSE).

- cohortCodeUse:

  Whether to run
  [`CodelistGenerator::summariseCohortCodeUse()`](https://darwin-eu.github.io/CodelistGenerator/reference/summariseCohortCodeUse.html)
  (TRUE) or not (FALSE).

- drugDiagnostics:

  Whether to run drug diagnostics (TRUE) or not (FALSE). Note that, if
  set to TRUE, the diagnostics will only run if the cohort code list
  contains drug codes.

- drugDiagnosticsSample:

  The number of people to take a random sample for drug diagnostics. If
  `drugDiagnosticsSample = NULL`, no sampling will be performed. If
  `drugDiagnosticsSample = 0` drug diagnostics will not be run.

- measurementDiagnostics:

  Whether to run measurement diagnostics (TRUE) or not (FALSE). Note
  that, if set to TRUE, the diagnostics will only run if the cohort code
  list contains measurement codes.

- measurementDiagnosticsSample:

  The number of people to take a random sample for measurement
  diagnostics. If `measurementDiagnosticsSample = NULL`, no sampling
  will be performed. If `measurementDiagnosticsSample = 0` measurement
  diagnostics will not be run.

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
#> Warning: The CDM reference containing the cohort must also contain achilles tables.
#> Returning only index event breakdown.

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
