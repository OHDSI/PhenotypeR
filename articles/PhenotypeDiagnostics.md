# Phenotype diagnostics

## Introduction

In this vignette, we are going to present how to run
`PhenotypeDiagnostics()`. We are going to use the following packages and
mock data:

``` r
library(CohortConstructor)
library(OmopSketch)
library(PhenotypeR)
library(dplyr)

con <- DBI::dbConnect(duckdb::duckdb(), 
                      CDMConnector::eunomiaDir("synpuf-1k", "5.3"))
cdm <- CDMConnector::cdmFromCon(con = con, 
                                cdmName = "Eunomia Synpuf",
                                cdmSchema   = "main",
                                writeSchema = "main", 
                                achillesSchema = "main")
cdm
```

Note that we have included [achilles
tables](https://github.com/OHDSI/Achilles) in our cdm reference, which
will be used to speed up some of the analyses.

We need to create a set of cohorts to review. For this we are going to
use the package
[CohortConstructor](https://ohdsi.github.io/CohortConstructor/) to
generate cohorts with users of *warfarin*, *acetaminophen* and
*morphine*.

``` r
# Create codelists
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

## Running PhenotypeDiagnostics

Now we have our cohort, we will use `phenotypeDiagnotics()` to assess
them. This will run the following diagnostics which help us know whether
are cohorts are ready to be used in research with the OMOP CDM dataset
we’re using:

- **Database diagnostics**: This includes information about the size of
  the data, the time period covered, the number of people in the data,
  and other meta-data of the CDM object. If only database diagnostics
  are of interest, these analyses can be run using
  `databaseDiagnotics()`.
- **Codelist diagnostics**: This includes information on the concepts
  included in our cohorts’ codelist. If only codelist diagnostics are of
  interest, these analyses can be run using `codelistDiagnotics()`.
- **Cohort diagnostics**: This summarises the characteristics of our
  cohorts, as well as comparing them to age and sex matched controls
  from the dataset. If only cohort diagnostics are of interest, these
  analyses can be run using `cohortDiagnotics()`.
- **Population diagnostics**: Calculates the frequency of our study
  cohorts in the database in terms of their incidence rates and
  prevalence. If only population diagnostics are of interest, these
  analyses can be run using `populationDiagnotics()`.

If we do not provide any specifications, the default values of the
functions will be used. That means, the following two scripts provide
the same summarised result:

``` r
diagnostics <- phenotypeDiagnostics(cdm$my_cohort,
                                databaseDiagnostics = list(),
                                codelistDiagnostics = list(),
                                cohortDiagnostics = list(),
                                populationDiagnostics = list())
```

If we don’t want to run one of the diagnostics we can switch it off by
setting it to NULL.

``` r
phenotypeDiagnostics(cdm$my_cohort,
                     databaseDiagnostics = list(),
                     codelistDiagnostics = NULL,
                     cohortDiagnostics = list(),
                     populationDiagnostics = NULL)
```

Or if we want to change the settings we can include arguments used in
the sub-functions in a list. For example, survial analysis is not run by
default (cohortSuvival is set by default to FALSE in
`cohortDiagnotics()`). We can run this, leaving other arguments as their
defaults, like so:

``` r
diagnostics <- phenotypeDiagnostics(cdm$my_cohort,
                                databaseDiagnostics = list(),
                                codelistDiagnostics = list(),
                                cohortDiagnostics = list("cohortSurvival" = TRUE),
                                populationDiagnostics = list())
```

### Database diagnostics

Although we may have created our study cohort, to inform analytic
decisions and interpretation of results requires an understanding of the
dataset from which it has been derived. The database diagnostics builds
on [OmopSketch](https://ohdsi.github.io/OmopSketch/index.html) package
to perform the following analyses:

- **Snapshot:** Summarises the meta data of a CDM object by using
  [summariseOmopSnapshot()](https://ohdsi.github.io/OmopSketch/reference/summariseOmopSnapshot.html)
- **Person table:** Summarises the person table by using
  [summarisePerson()](https://ohdsi.github.io/OmopSketch/reference/summarisePerson.html).
  This provides demographic information including sex, race, ethnicity,
  year/month/day of birth distributions, and location/provider/care site
  information.
- **Observation periods:** Summarises the observation period table by
  using
  [summariseObservationPeriod()](https://ohdsi.github.io/OmopSketch/reference/summariseObservationPeriod.html).
  This will allow us to see if there are individuals with multiple,
  non-overlapping, observation periods and how long each observation
  period lasts on average.
- **Clinical Records**: The diagnostics will detect which domains
  appears to the codelist associated to your cohort (i.e., Drug), and
  use
  [summariseClinicalRecords()](https://ohdsi.github.io/OmopSketch/reference/summariseClinicalRecords.html)
  to summarise the associated clinical table (i.e., “drug_exposure”).

### Codelist diagnostics

Codelist diagnostics builds on
[CodelistGenerator](https://darwin-eu.github.io/CodelistGenerator/) and
[MeasurementDiagnostics](https://ohdsi.github.io/MeasurementDiagnostics/)
R packages to perform the following analyses:

- **Achilles code use:** Which summarises the counts of our codes in our
  database based on achilles results using
  [summariseAchillesCodeUse()](https://darwin-eu.github.io/CodelistGenerator/reference/summariseAchillesCodeUse.html).
- **Orphan code use:** Orphan codes refer to codes that we did not
  include in our cohort definition, but that have any relationship with
  the codes in our codelist. So, although many can be false positives,
  we may identify some codes that we may want to use in our cohort
  definitions. This analysis uses
  [summariseOrphanCodes()](https://darwin-eu.github.io/CodelistGenerator/reference/summariseOrphanCodes.html).
- **Cohort code use:** Summarises the cohort code use in our cohort
  using
  [summariseCohortCodeUse()](https://darwin-eu.github.io/CodelistGenerator/reference/summariseCohortCodeUse.html).
- **Measurement diagnostics:** If any of the concepts used in our
  codelist is a measurement, it summarises its code use using
  [summariseCohortMeasurementUse()](https://ohdsi.github.io/MeasurementDiagnostics/reference/summariseCohortMeasurementUse.html).
- **Drug diagnostics:** If any of the concepts used in our codelist is a
  drug, it summarises its code use, including a summry of the exposure
  duration, the days between records, the daily dose, and the quantity.

### Cohort diagnostics

Cohort diagnostics builds on
[CohortCharacteristics](https://darwin-eu.github.io/CohortCharacteristics/)
and [CohortSurvival](https://darwin-eu-dev.github.io/CohortSurvival/) R
packages to perform the following analyses on our cohorts:

- **Cohort count:** Summarises the number of records and persons in each
  one of the cohorts using
  [summariseCohortCount()](https://darwin-eu.github.io/CohortCharacteristics/reference/summariseCohortCount.html)
  and summarises the attrition associated with the cohorts using
  [summariseCohortAttrition()](https://darwin-eu.github.io/CohortCharacteristics/reference/summariseCohortAttrition.html).
- **Cohort characteristics:** Summarises cohort baseline characteristics
  using
  [summariseCharacteristics()](https://darwin-eu.github.io/CohortCharacteristics/reference/summariseCharacteristics.html).
  Results are stratified by sex and by age group (0 to 17, 18 to 64, 65
  to 150). Age groups cannot be modified.
- **Cohort large scale characteristics:** Summarises cohort large scale
  characteristics using
  [summariseLargeScaleCharacteristics()](https://darwin-eu.github.io/CohortCharacteristics/reference/summariseLargeScaleCharacteristics.html).
  Results are stratified by sex and by age group (0 to 17, 18 to 64, 65
  to 150). Time windows (relative to cohort entry) included are: -Inf to
  -1, -Inf to -366, -365 to -31, -30 to -1, 0, 1 to 30, 31 to 365, 366
  to Inf, and 1 to Inf. The analysis is perform at standard and source
  code level.
- **Compare cohort:** If there is more than one cohort in the cohort
  table supplied, it summarises the overlap between them using
  [summariseCohortOverlap()](https://darwin-eu.github.io/CohortCharacteristics/reference/summariseCohortOverlap.html)
  and the timing between them
  [summariseCohortTiming()](https://darwin-eu.github.io/CohortCharacteristics/reference/summariseCohortTiming.html).
- **Cohort survival:** Smmarises the survival until the event of death
  (if death table is present in the cdm) using  
  [estimateSingleEventSurvival()](https://darwin-eu-dev.github.io/CohortSurvival/reference/estimateSingleEventSurvival.html).

For computational efficiency, cohort diagnostics will take a joint
random sample of 20,000 people from across the study cohorts for
describing cohort charateristics. The number sampled can be changed by
altering the `cohortSample` argument (e.g. `cohortSample = 40000` to
double the number). Sampling can be switched off by setting
`cohortSample = NULL`.

For each of the input cohorts, cohort diagnostics are also run on a set
of age and sex matched controls taken from the dataset as a whole. Again
random sampling is used for efficiency. By default 1,000 age and sex
matched controls are identified for 1,000 individuals from each of the
study cohorts. The number matched can be changed by altering the
`matchedSample` argument (e.g. `matchedSample = 2000` to double the
number). Sampling can be switched off by setting `matchedSample = NULL`.
Creation of age and sex matched controls can be skipped by setting
`matchedSample = 0`.

### Population diagnostics

Population diagnostics builds on
[IncidencePrevalence](https://darwin-eu.github.io/IncidencePrevalence/index.html)
R package to perform the following analyses:

- **Incidence:** It estimates the incidence of our cohorts using
  [estimateIncidence()](https://darwin-eu.github.io/IncidencePrevalence/reference/estimateIncidence.html).
- **Period Prevalence:** It estimates the period prevalence of our
  cohort on a year basis using
  [estimatePeriodPrevalence()](https://darwin-eu.github.io/IncidencePrevalence/reference/estimatePeriodPrevalence.html).

By default, these analyses are performed for:

- Overall, stratified by age groups (0 to 17, 18 to 64, 65 to 150) and
  by sex (Female, Male).
- Including all individuals, and restricting the denominator population
  to those with 0 and 365 of days of prior observation.

By default incidence rates and prevalence will be calculated for all
years captured in the dataset (based on earliest observation period
start date and latest observation period end date). The date range can
though be limited by using the `populationDateRange` argument.

These analyses are also conducted on a random sample of the population
captured in the dataset. By default this sample is set to 1 million
individuals and so will only be relevant for particularly large
datasets. The sampling number can be changed via the `populationSample`
argument (e.g. `populationSample = 200000` to double the number) or
switched off by setting `populationSample = NULL`.

## Save the results

To save our diagnositics results, we can use
[exportSummarisedResult](https://darwin-eu.github.io/omopgenerics/reference/exportSummarisedResult.html)
function from
[omopgenerics](https://darwin-eu.github.io/omopgenerics/index.html) R
Package:

``` r
exportSummarisedResult(diagnostics, path = here::here(), minCellCount = 5)
```

## Visualisation of the results

Once we get our **Phenotype diagnostics** result, we can use
`shinyDiagnostics` to easily create a shiny app and visualise our
results:

``` r
shinyDiagnostics(diagnostics,
                 directory = tempdir(),
                 minCellCount = 5, 
                 open = TRUE)
```

Notice that we have specified the minimum number of counts
(`minCellCount`) for suppression to be shown in the shiny app, and also
that we want the shiny to be launched in a new R session (`open`). You
can see the shiny app generated for this example in
[here](https://dpa-pde-oxford.shinyapps.io/PhenotypeRShiny/).See [Shiny
diagnostics
vignette](https://ohdsi.github.io/PhenotypeR/articles/a02_ShinyDiagnostics.html)
for a full explanation of the shiny app.
