hasRows <- function(tbl){
  (tbl |>
    utils::head(1) |>
    dplyr::tally() |>
    dplyr::pull("n")) >= 1
}
