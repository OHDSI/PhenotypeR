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
library(omock)
library(CohortConstructor)
library(PhenotypeR)

cdm <- mockCdmFromDataset(source = "duckdb")
#> ℹ Reading GiBleed tables.
#> ℹ Adding drug_strength table.
#> ℹ Creating local <cdm_reference> object.
#> ℹ Inserting <cdm_reference> into duckdb.
cdm$warfarin <- conceptCohort(cdm,
                              conceptSet =  list(warfarin = c(1310149L,
                                                              40163554L)),
                              name = "warfarin")
#> ℹ Subsetting table drug_exposure using 2 concepts with domain: drug.
#> ℹ Combining tables.
#> ℹ Creating cohort attributes.
#> ℹ Applying cohort requirements.
#> ℹ Merging overlapping records.
#> ✔ Cohort warfarin created.

result <- cdm$warfarin |>
  populationDiagnostics()
#> • Creating denominator for incidence and prevalence
#> • Sampling person table to 1e+06
#> ℹ Creating denominator cohorts
#> ✔ Cohorts created in 0 min and 6 sec
#> • Estimating incidence
#> ℹ Getting incidence for analysis 1 of 7
#> ℹ Getting incidence for analysis 2 of 7
#> ℹ Getting incidence for analysis 3 of 7
#> ℹ Getting incidence for analysis 4 of 7
#> ℹ Getting incidence for analysis 5 of 7
#> ℹ Getting incidence for analysis 6 of 7
#> ℹ Getting incidence for analysis 7 of 7
#> ✔ Overall time taken: 0 mins and 10 secs
#> • Estimating prevalence
#> ℹ Getting prevalence for analysis 1 of 7
#> ℹ Getting prevalence for analysis 2 of 7
#> ℹ Getting prevalence for analysis 3 of 7
#> ℹ Getting prevalence for analysis 4 of 7
#> ℹ Getting prevalence for analysis 5 of 7
#> ℹ Getting prevalence for analysis 6 of 7
#> ℹ Getting prevalence for analysis 7 of 7
#> ✔ Time taken: 0 mins and 6 secs
#> `populationDateStart`, `populationDateEnd`, and `populationSample` casted to
#> character.
#> `populationDateStart` and `populationDateEnd` eliminated from settings as all
#> elements are NA.

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
