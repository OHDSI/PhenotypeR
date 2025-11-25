# Run codelist-level diagnostics

\`codelistDiagnostics()\` runs phenotypeR diagnostics on the
cohort_codelist attribute on the cohort. Thus codelist attribute of the
cohort must be populated. If it is missing then it could be populated
using \`addCodelistAttribute()\` function.

Furthermore \`codelistDiagnostics()\` requires achilles tables to be
present in the cdm so that concept counts could be derived.

## Usage

``` r
codelistDiagnostics(cohort)
```

## Arguments

- cohort:

  A cohort table in a cdm reference. The cohort_codelist attribute must
  be populated. The cdm reference must contain achilles tables as these
  will be used for deriving concept counts.

## Value

A summarised result

## Examples

``` r
# \donttest{
library(CohortConstructor)
library(PhenotypeR)

cdm <- mockPhenotypeR()
#> Error in vec_data(data): `x` must be a vector, not a <tbl_df/tbl/data.frame/omop_table> object.

cdm$arthropathies <- conceptCohort(cdm,
                                   conceptSet = list("arthropathies" = c(37110496)),
                                   name = "arthropathies")
#> Error: object 'cdm' not found

result <- codelistDiagnostics(cdm$arthropathies)
#> Error: object 'cdm' not found

CDMConnector::cdmDisconnect(cdm = cdm)
#> Error: object 'cdm' not found
# }
```
