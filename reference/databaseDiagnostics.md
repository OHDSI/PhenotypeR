# Database diagnostics

PhenotypeR diagnostics on the cdm object.

Diagnostics include:

- Summarise a cdm_reference object, creating a snapshot with the
  metadata of the cdm_reference object

- Summarise the observation period table getting some overall statistics
  in a summarised_result object.

- Summarise the person table including demographics (sex, race,
  ethnicity, year of birth) and related statistics.

- Summarise the OMOP clinical tables where the codes associated with
  your cohort are found.

## Usage

``` r
databaseDiagnostics(
  cohort,
  cohortId = NULL,
  snapshot = TRUE,
  personTableSummary = TRUE,
  observationPeriodsSummary = TRUE,
  clinicalRecordsSummary = FALSE
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- cohortId:

  Specific cohort definition ID for which to run database diagnostics.
  This will only affect the clinical tables summary results.

- snapshot:

  Whether to run
  [`OmopSketch::summariseOmopSnapshot()`](https://OHDSI.github.io/OmopSketch/reference/summariseOmopSnapshot.html)
  (TRUE) or not (FALSE).

- personTableSummary:

  Whether to run
  [`OmopSketch::summarisePerson()`](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.html)
  (TRUE) or not (FALSE).

- observationPeriodsSummary:

  Whether to run
  [`OmopSketch::summariseObservationPeriod()`](https://OHDSI.github.io/OmopSketch/reference/summariseObservationPeriod.html)
  (TRUE) or not (FALSE).

- clinicalRecordsSummary:

  Whether to run
  [`OmopSketch::summariseClinicalRecords()`](https://OHDSI.github.io/OmopSketch/reference/summariseClinicalRecords.html)
  on those clinical tables where the codes associated with your cohort
  are found (TRUE) or not (FALSE).

## Value

A summarised result

## Examples

``` r
# \donttest{
library(omock)
library(PhenotypeR)
library(CohortConstructor)
library(CDMConnector)

cdm <- mockCdmFromDataset(source = "duckdb")
#> ℹ Loading bundled GiBleed tables from package data.
#> ℹ Adding drug_strength table.
#> ℹ Creating local <cdm_reference> object.
#> ℹ Inserting <cdm_reference> into duckdb.
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpiOjD2E/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$new_cohort <- conceptCohort(cdm,
                                conceptSet = list("codes" = c(40213201L, 4336464L)),
                                name = "new_cohort")
#> ℹ Subsetting table drug_exposure using 1 concept with domain: drug.
#> ℹ Subsetting table procedure_occurrence using 1 concept with domain: procedure.
#> ℹ Combining tables.
#> ℹ Creating cohort attributes.
#> ℹ Applying cohort requirements.
#> ℹ Merging overlapping records.
#> ✔ Cohort new_cohort created.

 result <- databaseDiagnostics(cohort = cdm$new_cohort)
#> ℹ The following estimates will be calculated:
#> • date_of_birth: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side.
#> → Start summary of data, at 2026-10-16 10:28:20.39267
#> ✔ Summary finished, at 2026-10-16 10:28:20.456219
#> ℹ retrieving cdm object from cdm_table.
#> Warning: ! There are 2649 individuals not included in the person table.
#> ℹ The following estimates will be calculated:
#> • observation_period_start_date: density
#> • observation_period_end_date: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side.
#> → Start summary of data, at 2026-10-16 10:28:23.701922
#> ✔ Summary finished, at 2026-10-16 10:28:23.782936

 cdmDisconnect(cdm = cdm)
# }
```
