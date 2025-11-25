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
library(PhenotypeR)

cdm <- mockPhenotypeR()
#> Error in vec_data(data): `x` must be a vector, not a <tbl_df/tbl/data.frame/omop_table> object.

result <- databaseDiagnostics(cdm)
#> Error: object 'cdm' not found

CDMConnector::cdmDisconnect(cdm = cdm)
#> Error: object 'cdm' not found
# }
```
