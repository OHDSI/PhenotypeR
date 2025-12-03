# Database diagnostics

phenotypeR diagnostics on the cdm object.

Diagnostics include: \* Summarise a cdm_reference object, creating a
snapshot with the metadata of the cdm_reference object. \* Summarise the
observation period table getting some overall statistics in a
summarised_result object.

## Usage

``` r
databaseDiagnostics(cdm)
```

## Arguments

- cdm:

  CDM reference

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
# }
```
