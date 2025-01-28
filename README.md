
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PhenotypeR <img src="man/figures/logo.png" align="right" height="180"/>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/PhenotypeR)](https://CRAN.R-project.org/package=PhenotypeR)
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

You can install PhenotypeR from CRAN:

``` r
install.packages("PhenotypeR")
```

Or you can install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("OHDSI/PhenotypeR")
```

## Example usage

To illustrate the functionalities of PhenotypeR, let’s create two
cohorts using the Eunomia dataset. We’ll first load the required
packages and create the cdm reference for the data.

``` r

library(CDMConnector)
library(PhenotypeR)
library(CodelistGenerator)
library(CohortConstructor)
library(dplyr)
library(OmopSketch)
library(CohortCharacteristics)
```

``` r
# Connect to the database and create the cdm object
con <- DBI::dbConnect(duckdb::duckdb(), eunomiaDir("synpuf-1k", "5.3"))
cdm <- cdmFromCon(con = con, 
                  cdmSchema   = "main",
                  writeSchema = "main", 
                  achillesSchema = "main")

# Create a code lists
cond_codes <- list("gastrointestinal_hemorrhage" = c(192671, 4338544, 4100660, 4307661),
                   "asthma" = c(317009, 257581))
# Instantiate cohorts with CohortConstructor

cdm$conditions <- conceptCohort(cdm = cdm,
                                conceptSet = cond_codes, 
                                exit = "event_end_date",
                                overlap = "merge",
                                name = "conditions")
```

We can easily run all the analyses explained above (*database
diagnostics*, *codelist diagnostics*, *cohort diagnostics*, *matched
diagnostics*, and *population diagnostics*) using
`phenotypeDiagnostics()`:

``` r

result <- phenotypeDiagnostics(cdm$conditions)
#> • Getting codelists from cohorts
#> • Getting index event breakdown
#> Getting counts of asthma codes for cohort asthmaGetting counts of gastrointestinal_hemorrhage codes for cohort• Getting code counts in database based on achilles
#> Using achilles results from version 1.7.2 which was run on 2024-08-26• Getting orphan concepts
#> PHOEBE results not available
#> ℹ The concept_recommended table is not present in the cdm.Getting orphan codes for asthmaGetting orphan codes for gastrointestinal_hemorrhageUsing achilles results from version 1.7.2 which was run on 2024-08-26• Index cohort table
#> • Getting cohort summary
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1ℹ summarising data
#> ✔ summariseCharacteristics finished!
#> • Getting age density
#> • Getting cohort attrition
#> • Getting cohort overlap
#> • Getting cohort timing
#> ℹ The following estimates will be computed:
#> • days_between_cohort_entries: density→ Start summary of data, at 2025-01-28 15:37:16.379303
#> ✔ Summary finished, at 2025-01-28 15:37:16.513745• Creating denominator for incidence and prevalence
#> • Sampling person table to 1e+06
#> ℹ Creating denominator cohorts
#>  -- getting cohort dates for ■■■■■■■■■■■■■■                   3 of 7 cohorts -- getting cohort dates for ■■■■■■■■■■■■■■■■■■               4 of 7 cohorts -- getting cohort dates for ■■■■■■■■■■■■■■■■■■■■■■           5 of 7 cohorts -- getting cohort dates for ■■■■■■■■■■■■■■■■■■■■■■■■■■■      6 of 7 cohorts                                                                             ! cohort columns will be reordered to match the expected order:
#>   cohort_definition_id, subject_id, cohort_start_date, and cohort_end_date.✔ Cohorts created in 0 min and 15 sec
#> • Estimating incidence
#> ℹ Getting incidence for analysis 1 of 12
#> ℹ Getting incidence for analysis 2 of 12
#> ℹ Getting incidence for analysis 3 of 12
#> ℹ Getting incidence for analysis 4 of 12
#> ℹ Getting incidence for analysis 5 of 12
#> ℹ Getting incidence for analysis 6 of 12
#> ℹ Getting incidence for analysis 7 of 12
#> ℹ Getting incidence for analysis 8 of 12
#> ℹ Getting incidence for analysis 9 of 12
#> ℹ Getting incidence for analysis 10 of 12
#> ℹ Getting incidence for analysis 11 of 12
#> ℹ Getting incidence for analysis 12 of 12
#> ✔ Overall time taken: 0 mins and 13 secs
#> • Estimating prevalence
#> ℹ Getting prevalence for analysis 1 of 12
#> ℹ Getting prevalence for analysis 2 of 12
#> ℹ Getting prevalence for analysis 3 of 12
#> ℹ Getting prevalence for analysis 4 of 12
#> ℹ Getting prevalence for analysis 5 of 12
#> ℹ Getting prevalence for analysis 6 of 12
#> ℹ Getting prevalence for analysis 7 of 12
#> ℹ Getting prevalence for analysis 8 of 12
#> ℹ Getting prevalence for analysis 9 of 12
#> ℹ Getting prevalence for analysis 10 of 12
#> ℹ Getting prevalence for analysis 11 of 12
#> ℹ Getting prevalence for analysis 12 of 12
#> ✔ Time taken: 0 mins and 3 secs
#> • Sampling cohorts
#> • Generating a age and sex matched cohorts
#> Starting matchingℹ Creating copy of target cohort.• 2 cohorts to be matched.ℹ Creating controls cohorts.ℹ Excluding cases from controls• Matching by gender_concept_id and year_of_birth• Removing controls that were not in observation at index date• Excluding target records whose pair is not in observation• Adjusting ratioBinding cohorts✔ Done• Index matched cohort table
#> ℹ adding demographics columns
#> ℹ adding tableIntersectCount 1/1ℹ summarising data
#> ✔ summariseCharacteristics finished!
#> • Running large scale characterisation
#> ℹ Summarising large scale characteristics 
#>  - getting characteristics from table condition_occurrence (1 of 6) - getting characteristics from table visit_occurrence (2 of 6)     - getting characteristics from table measurement (3 of 6)      - getting characteristics from table procedure_occurrence (4 of 6) - getting characteristics from table observation (5 of 6)          - getting characteristics from table drug_exposure (6 of 6)                                                             

# See all the results generated:
result |> 
  settings() |>
  select("result_type")
#> # A tibble: 48 × 1
#>    result_type                 
#>    <chr>                       
#>  1 summarise_omop_snapshot     
#>  2 summarise_observation_period
#>  3 cohort_code_use             
#>  4 achilles_code_use           
#>  5 orphan_code_use             
#>  6 summarise_characteristics   
#>  7 summarise_table             
#>  8 summarise_cohort_attrition  
#>  9 summarise_cohort_attrition  
#> 10 summarise_cohort_overlap    
#> # ℹ 38 more rows
```

Once we have our results we can quickly view them in an interactive
application. This shiny app will be saved in a new directory and can be
further customised using the `directory` input.

``` r

shinyDiagnostics(result = result, directory = tempdir())
```

See the shiny app generated from the example cohort in
(here)\[<https://dpa-pde-oxford.shinyapps.io/Readme_PhenotypeR/>\].

## More information

To see more details regarding each one of the analyses, please refer to
the package vignettes.
