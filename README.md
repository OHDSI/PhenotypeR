
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PhenotypeR <img src="man/figures/logo.png" align="right" height="180"/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/ohdsi/PhenotypeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ohdsi/PhenotypeR/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

The PhenotypeR package helps us to assess the research-readiness of a
set of cohorts we have defined. This assessment includes:

- ***Database diagnostics*** which help us to better understand the
  database in which they have been created. This includes information
  about the size of the data, the time period covered, the number of
  people in the data as a whole. More granular information that may
  influence analytic decisions, such as the number of observation
  periods per person, is also described.  
- ***Codelist diagnostics*** which help to answer questions like what
  concepts from our codelist are used in the database? What concepts
  were present led to individuals’ entry in the cohort? Are there any
  concepts being used in the database that we didn’t include in our
  codelist but maybe we should have?  
- ***Cohort diagnostics*** which help to answer questions like how many
  individuals did we include in our cohort and how many were excluded
  because of our inclusion criteria? If we have multiple cohorts, is
  there overlap between them and when do people enter one cohort
  relative to another? What is the incidence of cohort entry and what is
  the prevalence of the cohort in the database?  
- ***Matched diagnostics*** which compares our study cohorts to the
  overall population in the database. By matching people in the cohorts
  to people with a similar age and sex in the database we can see how
  our cohorts differ from the general database population.  
- ***Population diagnostics*** which estimates the frequency of our
  study cohorts in the database in terms of their incidence rates and
  prevalence.

## Installation

You can install PhenotypeR from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("ohdsi/PhenotypeR")
```

## Example usage

``` r
library(omopgenerics)
library(CDMConnector)
library(PhenotypeR)
library(CohortConstructor)
library(dplyr)

con <- DBI::dbConnect(duckdb::duckdb(dbdir = CDMConnector::eunomiaDir()))
cdm <- CDMConnector::cdm_from_con(con = con,
                      cdm_schema = "main",
                      write_schema = "main")

cdm$gibleed <- conceptCohort(cdm = cdm,
                                   conceptSet = list(gibleed = 192671L),
                                   name = "gibleed")

result <- cdm$gibleed |>
   phenotypeDiagnostics()
```

``` r
summary(result)
#> A summarised_result object with 18179 rows, 49 different result_id, 1 different
#> cdm names, and 24 settings.
#> CDM names: Synthea synthetic health database.
#> Settings: package_name, package_version, result_type, timing, table_name,
#> cohort_definition_id, cdm_version, vocabulary_version,
#> analysis_outcome_washout, analysis_repeated_events, analysis_interval,
#> analysis_complete_database_intervals, denominator_age_group, denominator_sex,
#> denominator_days_prior_observation, denominator_start_date,
#> denominator_end_date, denominator_target_cohort_name, …, type, and analysis.
```

Once we have our results we can quickly view them in an interactive
application. This shiny app will be saved in a new directory and can be
further customised.

``` r
shinyDiagnostics(result = result)
```
