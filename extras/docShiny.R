
rsconnect::setAccountInfo(
  name = "dpa-pde-oxford",
  token = Sys.getenv("SHINYAPPS_TOKEN"),
  secret = Sys.getenv("SHINYAPPS_SECRET")
)
rsconnect::deployApp(
  appDir = file.path(getwd(), "PhenotypeRShiny"),
  appName = "PhenotypeRShiny",
  forceUpdate = TRUE,
  logLevel = "verbose"
)
