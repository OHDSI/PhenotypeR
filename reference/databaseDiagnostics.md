# Database diagnostics

phenotypeR diagnostics on the cdm object.

Diagnostics include: \* Summarise a cdm_reference object, creating a
snapshot with the metadata of the cdm_reference object. \* Summarise the
observation period table getting some overall statistics in a
summarised_result object. \* Summarise the person table including
demographics (sex, race, ethnicity, year of birth) and related
statistics.

## Usage

``` r
databaseDiagnostics(cohort)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

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

# }
```
