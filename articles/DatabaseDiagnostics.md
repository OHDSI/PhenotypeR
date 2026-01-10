# Database diagnostics

## Introduction

In this example we’re going to be using the Eunomia synthetic data.

``` r
library(CDMConnector)
library(OmopSketch)
library(PhenotypeR)
library(dplyr)
library(CohortConstructor)

con <- DBI::dbConnect(duckdb::duckdb(), 
                      CDMConnector::eunomiaDir("synpuf-1k", "5.3"))
cdm <- CDMConnector::cdmFromCon(con = con, 
                                cdmName = "Eunomia Synpuf",
                                cdmSchema   = "main",
                                writeSchema = "main", 
                                achillesSchema = "main")

cdm$injuries <- conceptCohort(cdm = cdm,
  conceptSet = list(
    "ankle_sprain" = 81151L,
    "ankle_fracture" = 4059173L,
    "forearm_fracture" = 4278672L,
    "hip_fracture" = 4230399L
  ),
  name = "injuries")
```

## Database diagnostics

Although we may have created our study cohort, to inform analytic
decisions and interpretation of results requires an understanding of the
dataset from which it has been derived. The
[`databaseDiagnostics()`](https://ohdsi.github.io/PhenotypeR/reference/databaseDiagnostics.md)
function will help us better understand a data source.

To run database diagnostics we just need to provide our cdm reference to
the function.

``` r
db_diagnostics <- databaseDiagnostics(cdm$injuries)
```

Database diagnostics builds on
[OmopSketch](https://ohdsi.github.io/OmopSketch/index.html) package to
perform the following analyses:

- **Snapshot:** Summarises the meta data of a CDM object by using
  [summariseOmopSnapshot()](https://ohdsi.github.io/OmopSketch/reference/summariseOmopSnapshot.html)
- **Observation periods:** Summarises the observation period table by
  using
  [summariseObservationPeriod()](https://ohdsi.github.io/OmopSketch/reference/summariseObservationPeriod.html).
  This will allow us to see if there are individuals with multiple,
  non-overlapping, observation periods and how long each observation
  period lasts on average.
- **Person table:** Summarises the person table by using
  [summarisePerson()](https://ohdsi.github.io/OmopSketch/reference/summarisePerson.html).
  This provides demographic information including sex, race, ethnicity,
  year/month/day of birth distributions, and location/provider/care site
  information.
- **Clinical Records**: The diagnostics will detect which domains
  appears to the codelist associated to your cohort (i.e., Drug), and
  use
  [summariseClinicalRecords()](https://ohdsi.github.io/OmopSketch/reference/summariseClinicalRecords.html)
  to summarise the clinical table associated (i.e., “drug_exposure”).

The output is a summarised result object.

## Visualise the results

We can use [OmopSketch](https://ohdsi.github.io/OmopSketch/index.html)
package functions to visualise the results obtained.

### Snapshot

``` r
tableOmopSnapshot(db_diagnostics)
```

[TABLE]

Snapshot of the cdm Eunomia Synpuf

### Observation Periods

``` r
tableObservationPeriod(db_diagnostics)
```

[TABLE]

Summary of observation_period table

### Person Table

``` r
tablePerson(db_diagnostics)
```

[TABLE]

Summary of person table

### Clinical Records

``` r
tableClinicalRecords(db_diagnostics)
```

[TABLE]

Summary of condition_occurrence table
