# Adds the cohort_codelist attribute to a cohort

\`addCodelistAttribute()\` allows the users to add a codelist to a
cohort in OMOP CDM.

This is particularly important for the use of \`codelistDiagnostics()\`,
as the underlying assumption is that the cohort that is fed into
\`codelistDiagnostics()\` has a cohort_codelist attribute attached to
it.

## Usage

``` r
addCodelistAttribute(cohort, codelist, cohortName = names(codelist))
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- codelist:

  Named list of concepts

- cohortName:

  For each element of the codelist, the name of the cohort in \`cohort\`
  to which the codelist refers

## Value

A cohort

## Examples

``` r
# \donttest{
library(PhenotypeR)

cdm <- mockPhenotypeR()
#> Error in vec_data(data): `x` must be a vector, not a <tbl_df/tbl/data.frame/omop_table> object.

cohort <- addCodelistAttribute(cohort = cdm$my_cohort, codelist = list("cohort_1" = 1L))
#> Error: object 'cdm' not found
attr(cohort, "cohort_codelist")
#> Error: object 'cohort' not found

CDMConnector::cdmDisconnect(cdm)
#> Error: object 'cdm' not found
# }
```
