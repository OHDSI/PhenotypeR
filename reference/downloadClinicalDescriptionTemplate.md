# Download a Clinical Description Template

Download a Clinical Description Template

## Usage

``` r
downloadClinicalDescriptionTemplate(
  directory,
  name = "clinical_description_template"
)
```

## Arguments

- directory:

  Directory where to download the clinical description.

- name:

  Name of the Word file.Note that the file must match the cohort names
  used in PhenotypeR Diagnostics if you want to integrate the clinical
  description into the PhenotypeR Shiny app.

## Value

A Word document with the template of the clinical description.

## Examples

``` r
# \donttest{
library(PhenotypeR)
library(here)
#> here() starts at /home/runner/work/PhenotypeR/PhenotypeR

downloadClinicalDescriptionTemplate(directory = here(),
                                    name = "metformin")
#> ✔ Clinical description template download correctly!


# }
```
