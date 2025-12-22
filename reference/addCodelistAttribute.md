# Adds the cohort_codelist attribute to a cohort

\`addCodelistAttribute()\` allows the users to add a codelist to a
cohort in OMOP CDM.

This is particularly important for the use of \`codelistDiagnostics()\`,
as the underlying assumption is that the cohort that is fed into
\`codelistDiagnostics()\` has a cohort_codelist attribute attached to
it.

## Usage

``` r
addCodelistAttribute(cohort, codelist, cohortName = names(codelist))
```

## Arguments

- cohort:

  Cohort table in a cdm reference

- codelist:

  Named list of concepts

- cohortName:

  For each element of the codelist, the name of the cohort in \`cohort\`
  to which the codelist refers

## Value

A cohort

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

cohort <- addCodelistAttribute(cohort = cdm$warfarin,
               codelist = list("warfarin" = c(1310149L,  40163554L)))
#> Warning: Overwriting codelist for cohort warfarin
attr(cohort, "cohort_codelist")
#> # Source:   table<results.test_warfarin_codelist> [?? x 4]
#> # Database: DuckDB 1.4.3 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpdgVT8t/file1ee52af68ac1.duckdb]
#>   cohort_definition_id codelist_name concept_id codelist_type
#>                  <int> <chr>              <int> <chr>        
#> 1                    1 warfarin         1310149 index event  
#> 2                    1 warfarin        40163554 index event  

CDMConnector::cdmDisconnect(cdm)
# }
```
