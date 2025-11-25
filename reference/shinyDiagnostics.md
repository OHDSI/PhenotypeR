# Create a shiny app summarising your phenotyping results

A shiny app that is designed for any diagnostics results from
phenotypeR, this includes:

\* A diagnostics on the database via \`databaseDiagnostics\`. \* A
diagnostics on the cohort_codelist attribute of the cohort via
\`codelistDiagnostics\`. \* A diagnostics on the cohort via
\`cohortDiagnostics\`. \* A diagnostics on the population via
\`populationDiagnostics\`. \* A diagnostics on the matched cohort via
\`matchedDiagnostics\`.

## Usage

``` r
shinyDiagnostics(
  result,
  directory,
  minCellCount = 5,
  open = rlang::is_interactive(),
  expectations = NULL
)
```

## Arguments

- result:

  A summarised result

- directory:

  Directory where to save report

- minCellCount:

  Minimum cell count for suppression when exporting results.

- open:

  If TRUE, the shiny app will be launched in a new session. If FALSE,
  the shiny app will be created but not launched.

- expectations:

  Data frame or tibble with cohort expectations. It must contain the
  following columns: cohort_name, estimate, value, and source.

## Value

A shiny app

## Examples

``` r
# \donttest{
library(PhenotypeR)
library(dplyr)

cdm <- mockPhenotypeR()
#> Error in vec_data(data): `x` must be a vector, not a <tbl_df/tbl/data.frame/omop_table> object.

result <- phenotypeDiagnostics(cdm$my_cohort)
#> Error: object 'cdm' not found
expectations <- tibble("cohort_name" = rep(c("cohort_1", "cohort_2"),3),
                       "value" = c(rep(c("Mean age"),2),
                                   rep("Male percentage",2),
                                   rep("Survival probability after 5y",2)),
                       "estimate" = c("32", "54", "25%", "74%", "95%", "21%"),
                       "source" = rep(c("AlbertAI"),6))

shinyDiagnostics(result, tempdir(), expectations = expectations)
#> Error: object 'result' not found

CDMConnector::cdmDisconnect(cdm = cdm)
#> Error: object 'cdm' not found
# }
```
