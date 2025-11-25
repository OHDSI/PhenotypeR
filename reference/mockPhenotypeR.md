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
#> Error in vec_data(data): `x` must be a vector, not a <tbl_df/tbl/data.frame/omop_table> object.

cdm
#> Error: object 'cdm' not found
# }
```
