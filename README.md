
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

To illustrate the functionality of PhenotypeR, let’s create a cohort
using the Eunomia Synpuf dataset. We’ll first load the required packages
and create the cdm reference for the data.

``` r
library(dplyr)
library(CohortConstructor)
library(PhenotypeR)
```

``` r
# Connect to the database and create the cdm object
con <- DBI::dbConnect(duckdb::duckdb(), 
                      CDMConnector::eunomiaDir("synpuf-1k", "5.3"))
cdm <- CDMConnector::cdmFromCon(con = con, 
                                cdmName = "Eunomia Synpuf",
                                cdmSchema   = "main",
                                writeSchema = "main", 
                                achillesSchema = "main")
```

Note that we’ve included achilles results in our cdm reference. Where we
can we’ll use these precomputed counts to speed up our analysis.

``` r
cdm
#> 
#> ── # OMOP CDM reference (duckdb) of Eunomia Synpuf ─────────────────────────────
#> • omop tables: person, observation_period, visit_occurrence, visit_detail,
#> condition_occurrence, drug_exposure, procedure_occurrence, device_exposure,
#> measurement, observation, death, note, note_nlp, specimen, fact_relationship,
#> location, care_site, provider, payer_plan_period, cost, drug_era, dose_era,
#> condition_era, metadata, cdm_source, concept, vocabulary, domain,
#> concept_class, concept_relationship, relationship, concept_synonym,
#> concept_ancestor, source_to_concept_map, drug_strength, cohort_definition,
#> attribute_definition
#> • cohort tables: -
#> • achilles tables: achilles_analysis, achilles_results, achilles_results_dist
#> • other tables: -
```

``` r
# Create a code lists
codes <- list("warfarin" = c(1310149, 40163554),
              "acetaminophen" = c(1125315, 1127078, 1127433, 40229134, 40231925, 40162522, 19133768),
              "morphine" = c(1110410, 35605858, 40169988))

# Instantiate cohorts with CohortConstructor
cdm$my_cohort <- conceptCohort(cdm = cdm,
                               conceptSet = codes, 
                               exit = "event_end_date",
                               overlap = "merge",
                               name = "my_cohort")
```

We can easily run all the analyses explained above (**database
diagnostics**, **codelist diagnostics**, **cohort diagnostics**,
**matched diagnostics**, and **population diagnostics**) using
`phenotypeDiagnostics()`:

``` r
result <- phenotypeDiagnostics(cdm$my_cohort)
```

Once we have our results we can quickly view them in an interactive
application. Here we’ll apply a minimum cell count of 10 to our results
and save our shiny app to a temporary directory, but you will likely
want to save this shiny app to a local directory of your choice.

``` r
shinyDiagnostics(result = result, minCellCount = 10, directory = tempdir())
```

See the shiny app generated from the example cohort in
[here](https://dpa-pde-oxford.shinyapps.io/Readme_PhenotypeR/).

### More information

To see more details regarding each one of the analyses, please refer to
the package vignettes.
