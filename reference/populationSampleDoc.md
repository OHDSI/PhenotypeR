# Helper for consistent documentation of \`populationSample\`.

Helper for consistent documentation of \`populationSample\`.

## Arguments

- populationSample:

  Number of people from the cdm to sample. If NULL no sampling will be
  performed. Sample will be within populationDateRange if specified.

- populationDateRange:

  Two dates. The first indicating the earliest cohort start date and the
  second indicating the latest possible cohort end date. If NULL or the
  first date is set as missing, the earliest observation_start_date in
  the observation_period table will be used for the former. If NULL or
  the second date is set as missing, the latest observation_end_date in
  the observation_period table will be used for the latter.
