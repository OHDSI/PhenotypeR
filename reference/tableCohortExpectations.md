# Create a table summarising cohort expectations

Create a table summarising cohort expectations

## Usage

``` r
tableCohortExpectations(expectations, type = "reactable")
```

## Arguments

- expectations:

  Data frame or tibble with cohort expectations. It must contain the
  following columns: cohort_name, estimate, value, and source.

- type:

  Table type to view results. See visOmopResults::tableType() for
  supported tables.

## Value

Summary of cohort expectations
