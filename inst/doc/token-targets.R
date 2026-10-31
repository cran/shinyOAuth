## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(shinyOAuth)

## ----eval=FALSE---------------------------------------------------------------
# # Provider supports RFC 8707 resource indicators.
# provider <- oauth_provider(
#   "workplace", "https://login.example/authorize", "https://login.example/token",
#   token_target_mode = "rfc8707",
#   token_auth_style = "body",
#   userinfo_required = FALSE
# )
# client <- oauth_client(
#   provider,
#   client_id = Sys.getenv("OAUTH_CLIENT_ID"),
#   client_secret = Sys.getenv("OAUTH_CLIENT_SECRET"),
#   redirect_uri = "https://app.example/callback",
#   token_targets = list(
#     calendar = oauth_token_target(
#       resource = "https://calendar.example/",
#       scopes = c("calendar.read", "calendar.write"),
#       required_scopes = "calendar.read",
#       resource_ids = "calendar_api"
#     ),
#     contacts = oauth_token_target(
#       resource = "https://contacts.example/",
#       scopes = "contacts.read",
#       resource_ids = "contacts_api"
#     )
#   ),
#   token_target_default = "calendar",
#   resource_bases = c(
#     calendar_api = "https://calendar.example/v1",
#     contacts_api = "https://contacts.example/v1"
#   )
# )

## ----eval=FALSE---------------------------------------------------------------
# server <- function(input, output, session) {
#   auth <- oauth_module_server(
#     "auth", client,
#     reauth_after_seconds = 60 * 60 # One-hour maximum login age
#   )
#   # Alternatively: auth <- oauth_connections_server("auth", manager)
#   # and select auth$connection(connection_id), or auth$connection() when unique.
# 
#   contacts <- shiny::reactive({
#     connection <- shiny::req(auth$connection())
#     token <- connection$access_token("contacts.read", target = "contacts")
#     existing_contacts_sdk(access_token = token)$list_contacts()
#   })
# 
#   output$can_edit_calendar <- shiny::renderText({
#     connection <- shiny::req(auth$connection())
#     connection$has_scopes("calendar.write", target = "calendar")
#   })
# 
#   shiny::observeEvent(input$save_event, {
#     connection <- shiny::req(auth$connection())
#     connection$request(
#       "calendar_api", "events", method = "POST",
#       required_scopes = "calendar.write", target = "calendar", refresh = TRUE,
#       configure = function(req) httr2::req_body_json(req, list(title = input$title))
#     )
#   })
# }

## ----eval=FALSE---------------------------------------------------------------
# provider <- oauth_provider_microsoft(
#   tenant = Sys.getenv("MICROSOFT_TENANT_ID"),
#   userinfo_required = FALSE
# )
# client <- oauth_client(
#   provider, Sys.getenv("OAUTH_CLIENT_ID"), Sys.getenv("OAUTH_CLIENT_SECRET"),
#   redirect_uri = "https://app.example/callback",
#   scopes = c(
#     "openid", "offline_access",
#     "https://graph.microsoft.com/Calendars.Read",
#     "api://your-contacts-api/Contacts.Read"
#   ),
#   token_targets = list(
#     calendar = oauth_token_target(
#       resource = "https://graph.microsoft.com",
#       scopes = "https://graph.microsoft.com/Calendars.Read"
#     ),
#     contacts = oauth_token_target(
#       resource = "api://your-contacts-api",
#       scopes = "api://your-contacts-api/Contacts.Read"
#     )
#   ),
#   token_target_default = "calendar"
# )

