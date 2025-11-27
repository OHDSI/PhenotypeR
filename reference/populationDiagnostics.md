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

dateStart <- cdm$my_cohort |>
  summarise(start = min(cohort_start_date, na.rm = TRUE)) |>
  pull("start")
dateEnd   <- cdm$my_cohort |>
  summarise(start = max(cohort_start_date, na.rm = TRUE)) |>
  pull("start")

result <- cdm$my_cohort |>
  populationDiagnostics(populationDateRange = c(dateStart, dateEnd))
#> • Creating denominator for incidence and prevalence
#> • Sampling person table to 1e+06
#> ℹ Creating denominator cohorts
#> ✔ Cohorts created in 0 min and 5 sec
#> • Estimating incidence
#> ℹ Getting incidence for analysis 1 of 14
#> ℹ Getting incidence for analysis 2 of 14
#> ℹ Getting incidence for analysis 3 of 14
#> ℹ Getting incidence for analysis 4 of 14
#> ℹ Getting incidence for analysis 5 of 14
#> ℹ Getting incidence for analysis 6 of 14
#> ℹ Getting incidence for analysis 7 of 14
#> ℹ Getting incidence for analysis 8 of 14
#> ℹ Getting incidence for analysis 9 of 14
#> ℹ Getting incidence for analysis 10 of 14
#> ℹ Getting incidence for analysis 11 of 14
#> ℹ Getting incidence for analysis 12 of 14
#> ℹ Getting incidence for analysis 13 of 14
#> ℹ Getting incidence for analysis 14 of 14
#> ✔ Overall time taken: 0 mins and 13 secs
#> • Estimating prevalence
#> ℹ Getting prevalence for analysis 1 of 14
#> ℹ Getting prevalence for analysis 2 of 14
#> ℹ Getting prevalence for analysis 3 of 14
#> ℹ Getting prevalence for analysis 4 of 14
#> ℹ Getting prevalence for analysis 5 of 14
#> ℹ Getting prevalence for analysis 6 of 14
#> ℹ Getting prevalence for analysis 7 of 14
#> ℹ Getting prevalence for analysis 8 of 14
#> ℹ Getting prevalence for analysis 9 of 14
#> ℹ Getting prevalence for analysis 10 of 14
#> ℹ Getting prevalence for analysis 11 of 14
#> ℹ Getting prevalence for analysis 12 of 14
#> ℹ Getting prevalence for analysis 13 of 14
#> ℹ Getting prevalence for analysis 14 of 14
#> ✔ Time taken: 0 mins and 7 secs
#> `populationDateStart`, `populationDateEnd`, and `populationSample` casted to
#> character.

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
