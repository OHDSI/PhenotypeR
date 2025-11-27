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

cdm$arthropathies <- conceptCohort(cdm,
                                   conceptSet = list("arthropathies" = c(37110496)),
                                   name = "arthropathies")
#> Warning: ! `codelist` casted to integers.
#> ℹ Subsetting table condition_occurrence using 1 concept with domain: condition.
#> ℹ Combining tables.
#> ℹ Creating cohort attributes.
#> ℹ Applying cohort requirements.
#> ℹ Merging overlapping records.
#> ✔ Cohort arthropathies created.

result <- codelistDiagnostics(cdm$arthropathies)
#> • Getting codelists from cohorts
#> • Getting index event breakdown
#> Getting counts of arthropathies codes for cohort arthropathies
#> • Getting code counts in database based on achilles
#> 
#> • Getting orphan concepts
#> PHOEBE results not available
#> ℹ The concept_recommended table is not present in the cdm.
#> Getting orphan codes for arthropathies
#> 

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
