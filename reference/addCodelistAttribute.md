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

cohort <- addCodelistAttribute(cohort = cdm$my_cohort, codelist = list("cohort_1" = 1L))
attr(cohort, "cohort_codelist")
#> # Source:   table<my_cohort_codelist> [?? x 4]
#> # Database: DuckDB 1.4.2 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>   cohort_definition_id codelist_name concept_id codelist_type
#>                  <int> <chr>              <int> <chr>        
#> 1                    1 cohort_1               1 index event  

CDMConnector::cdmDisconnect(cdm)
# }
```
