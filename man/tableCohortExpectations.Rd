% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getCohortExpectations.R
\name{tableCohortExpectations}
\alias{tableCohortExpectations}
\title{Create a table summarising cohort expectations}
\usage{
tableCohortExpectations(expectations, type = "reactable")
}
\arguments{
\item{expectations}{Data frame or tibble with cohort expectations. It must contain the following columns: cohort_name, estimate, value, and source.}

\item{type}{Table type to view results. See visOmopResults::tableType()
for supported tables.}
}
\value{
Summary of cohort expectations
}
\description{
Create a table summarising cohort expectations
}
