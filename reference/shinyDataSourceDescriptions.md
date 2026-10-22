# Shiny app to create data source descriptions for contextualising diagnostic results

Shiny app to create data source descriptions for contextualising
diagnostic results

## Usage

``` r
shinyDataSourceDescriptions(directory, open = rlang::is_interactive())
```

## Arguments

- directory:

  Directory where to save shiny app

- open:

  If TRUE, the shiny app will be launched in a new session. If FALSE,
  the shiny app will be created but not launched.

## Value

Shiny app

## Examples

``` r
# \donttest{
shinyDataSourceDescriptions(tempdir())
#> ℹ Creating shiny from provided data
#> ℹ Shiny app created in /tmp/Rtmp00jdvo/dataSourceDescritpionShiny
# }
```
