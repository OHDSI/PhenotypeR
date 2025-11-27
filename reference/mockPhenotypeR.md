# Function to create a mock cdm reference for mockPhenotypeR

\`mockPhenotypeR()\` creates an example dataset that can be used to show
how the package works

## Usage

``` r
mockPhenotypeR(
  nPerson = 100,
  con = DBI::dbConnect(duckdb::duckdb()),
  writeSchema = "main",
  seed = 111
)
```

## Arguments

- nPerson:

  number of people in the cdm.

- con:

  A DBI connection to create the cdm mock object.

- writeSchema:

  Name of an schema on the same connection with writing permissions.

- seed:

  seed to use when creating the mock data.

## Value

cdm object

## Examples

``` r
# \donttest{
library(PhenotypeR)

cdm <- mockPhenotypeR()

cdm
#> 
#> ── # OMOP CDM reference (duckdb) of mock database ──────────────────────────────
#> • omop tables: cdm_source, concept, concept_ancestor, concept_relationship,
#> concept_synonym, condition_occurrence, death, device_exposure, drug_exposure,
#> drug_strength, measurement, observation, observation_period, person,
#> procedure_occurrence, visit_occurrence, vocabulary
#> • cohort tables: my_cohort
#> • achilles tables: achilles_analysis, achilles_results, achilles_results_dist
#> • other tables: -
# }
```
