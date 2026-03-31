# Download a Clinical Description Template

Download a Clinical Description Template

## Usage

``` r
downloadDatabaseDescriptionTemplate(
  directory,
  name = "database_description_template"
)
```

## Arguments

- directory:

  Directory where to download the database description template.

- name:

  Name of the Word file.Note that the file must match the database names
  used in PhenotypeR Diagnostics if you want to integrate the database
  description into the PhenotypeR Shiny app.

## Value

A Word document with the template of the clinical description.

## Examples

``` r
# \donttest{
library(PhenotypeR)
library(here)

downloadDatabaseDescriptionTemplate(directory = here(),
                                    name = "GiBleed")
#> ✔ Database description template download correctly!


# }
```
