## ----eval = FALSE-------------------------------------------------------------
# # install.packages("otelsdk")
# Sys.setenv(
#   OTEL_TRACES_EXPORTER = "console",
#   OTEL_LOGS_EXPORTER = "console",
#   OTEL_LOG_LEVEL = "debug"
# )
# library(shinyOAuth)

## ----eval = FALSE-------------------------------------------------------------
# options(
#   shinyOAuth.otel_logging_enabled = FALSE,
#   shinyOAuth.otel_tracing_enabled = FALSE
# )

## ----eval = FALSE-------------------------------------------------------------
# options(shinyOAuth.otel_include_authorization_details = TRUE)

