# Run cohort-level diagnostics

Runs phenotypeR diagnostics on the cohort. The diganostics include: \*
Age groups and sex summarised. \* A summary of visits of everyone in the
cohort using visit_occurrence table. \* A summary of age and sex density
of the cohort. \* Attritions of the cohorts. \* Overlap between cohorts
(if more than one cohort is being used).

## Usage

``` r
cohortDiagnostics(
  cohort,
  survival = FALSE,
  cohortSample = 20000,
  matchedSample = 1000
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- survival:

  Boolean variable. Whether to conduct survival analysis (TRUE) or not
  (FALSE).

- cohortSample:

  The number of people to take a random sample for cohortDiagnostics. If
  \`cohortSample = NULL\`, no sampling will be performed,

- matchedSample:

  The number of people to take a random sample for matching. If
  \`matchedSample = NULL\`, no sampling will be performed. If
  \`matchedSample = 0\`, no matched cohorts will be created.

## Value

A summarised result

## Examples

``` r
# \donttest{
library(PhenotypeR)

cdm <- mockPhenotypeR()
#> Error in vec_data(data): `x` must be a vector, not a <tbl_df/tbl/data.frame/omop_table> object.

result <- cohortDiagnostics(cdm$my_cohort)
#> • Starting Cohort Diagnostics
#> Error: object 'cdm' not found

CDMConnector::cdmDisconnect(cdm = cdm)
#> Error: object 'cdm' not found
# }
```
