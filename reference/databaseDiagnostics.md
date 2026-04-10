# Database diagnostics

PhenotypeR diagnostics on the cdm object.

Diagnostics include: \* Summarise a cdm_reference object, creating a
snapshot with the metadata of the cdm_reference object. \* Summarise the
observation period table getting some overall statistics in a
summarised_result object. \* Summarise the person table including
demographics (sex, race, ethnicity, year of birth) and related
statistics. \* Summarise the OMOP clinical tables where the codes
associated with your cohort are found.

## Usage

``` r
databaseDiagnostics(
  cohort,
  snapshot = TRUE,
  personTableSummary = TRUE,
  observationPeriodsSummary = TRUE,
  clinicalRecordsSummary = TRUE
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- snapshot:

  Whether to run \`OmopSketch::summariseOmopSnapshot()\` (TRUE) or not
  (FALSE).

- personTableSummary:

  Whether to run \`OmopSketch::summarisePerson()\` (TRUE) or not
  (FALSE).

- observationPeriodsSummary:

  Whether to run \`OmopSketch::summariseObservationPeriod()\` (TRUE) or
  not (FALSE).

- clinicalRecordsSummary:

  Whether to run \`OmopSketch::summariseClinicalRecords()\` on those
  clinical tables where the codes associated with your cohort are found
  (TRUE) or not (FALSE).

## Value

A summarised result

## Examples

``` r
# \donttest{
library(omock)
library(PhenotypeR)
library(CohortConstructor)

cdm <- mockCdmFromDataset(source = "duckdb")
#> ℹ Loading bundled GiBleed tables from package data.
#> ℹ Adding drug_strength table.
#> ℹ Creating local <cdm_reference> object.
#> ℹ Inserting <cdm_reference> into duckdb.

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
#>   the database side
#> → Start summary of data, at 2026-04-10 19:02:09.969598
#> ✔ Summary finished, at 2026-04-10 19:02:10.03481
#> ℹ retrieving cdm object from cdm_table.
#> Warning: ! There are 2649 individuals not included in the person table.
#> ℹ The following estimates will be calculated:
#> • observation_period_start_date: density
#> • observation_period_end_date: density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-04-10 19:02:13.275753
#> ✔ Summary finished, at 2026-04-10 19:02:13.341723
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
#> ℹ Adding variables of interest to procedure_occurrence.
#> ℹ Summarising records per person in procedure_occurrence.
#> ℹ Summarising subjects not in person table in procedure_occurrence.
#> ℹ Summarising records in observation in procedure_occurrence.
#> ℹ Summarising records with start before birth date in procedure_occurrence.
#> ℹ Summarising records with end date before start date in procedure_occurrence.
#> ℹ Summarising domains in procedure_occurrence.
#> ℹ Summarising standard concepts in procedure_occurrence.
#> ℹ Summarising source vocabularies in procedure_occurrence.
#> ℹ Summarising concept types in procedure_occurrence.
#> ℹ Summarising missing data in procedure_occurrence.

 CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
