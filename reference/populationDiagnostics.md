# Population-level diagnostics

phenotypeR diagnostics on the cohort of input with relation to a
denomination population. Diagnostics include:

\* Incidence \* Prevalence

## Usage

``` r
populationDiagnostics(
  cohort,
  populationSample = 1e+06,
  populationDateRange = as.Date(c(NA, NA))
)
```

## Arguments

- cohort:

  Cohort table in a cdm reference

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
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

cdm <- mockPhenotypeR()
#> Error in vec_data(data): `x` must be a vector, not a <tbl_df/tbl/data.frame/omop_table> object.

dateStart <- cdm$my_cohort |>
  summarise(start = min(cohort_start_date, na.rm = TRUE)) |>
  pull("start")
#> Error: object 'cdm' not found
dateEnd   <- cdm$my_cohort |>
  summarise(start = max(cohort_start_date, na.rm = TRUE)) |>
  pull("start")
#> Error: object 'cdm' not found

result <- cdm$my_cohort |>
  populationDiagnostics(populationDateRange = c(dateStart, dateEnd))
#> Error: object 'cdm' not found

CDMConnector::cdmDisconnect(cdm = cdm)
#> Error: object 'cdm' not found
# }
```
