# Phenotype a cohort

This comprises all the diagnostics that are being offered in this
package, this includes:

\* A diagnostics on the database via \`databaseDiagnostics\`. \* A
diagnostics on the cohort_codelist attribute of the cohort via
\`codelistDiagnostics\`. \* A diagnostics on the cohort via
\`cohortDiagnostics\`. \* A diagnostics on the population via
\`populationDiagnostics\`.

## Usage

``` r
phenotypeDiagnostics(
  cohort,
  diagnostics = c("databaseDiagnostics", "codelistDiagnostics", "cohortDiagnostics",
    "populationDiagnostics"),
  survival = FALSE,
  cohortSample = 20000,
  matchedSample = 1000,
  populationSample = 1e+06,
  populationDateRange = as.Date(c(NA, NA))
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- diagnostics:

  Vector indicating which diagnostics to perform. Options include:
  \`databaseDiagnostics\`, \`codelistDiagnostics\`,
  \`cohortDiagnostics\`, and \`populationDiagnostics\`.

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

- populationSample:

  Number of people from the cdm to sample. If NULL no sampling will be
  performed. Sample will be within populationDateRange if specified.

- populationDateRange:

  Two dates. The first indicating the earliest cohort start date and the
  second indicating the latest possible cohort end date. If NULL or the
  first date is set as missing, the earliest observation_start_date in
  the observation_period table will be used for the former. If NULL or
  the second date is set as missing, the latest observation_end_date in
  the observation_period table will be used for the latter.

## Value

A summarised result

## Examples

``` r
# \donttest{
library(PhenotypeR)

cdm <- mockPhenotypeR()
#> Error in vec_data(data): `x` must be a vector, not a <tbl_df/tbl/data.frame/omop_table> object.

result <- phenotypeDiagnostics(cdm$my_cohort)
#> Error: object 'cdm' not found

CDMConnector::cdmDisconnect(cdm = cdm)
#> Error: object 'cdm' not found
# }
```
