## ----eval = FALSE-------------------------------------------------------------
# connection <- shiny::req(auth$connection())
# token <- connection$access_token(required_scopes = "records.read")
# existing_sdk_read_records(access_token = token)

## ----eval = FALSE-------------------------------------------------------------
# library(shiny)
# library(shinyOAuth)
# 
# provider <- oauth_provider(
#   name = "records",
#   auth_url = "https://login.example/authorize",
#   token_url = "https://login.example/token",
#   userinfo_required = FALSE
# )
# client <- oauth_client(
#   provider,
#   client_id = Sys.getenv("OAUTH_CLIENT_ID"),
#   client_secret = Sys.getenv("OAUTH_CLIENT_SECRET"),
#   redirect_uri = "https://app.example/callback",
#   scopes = c("records.read", "records.write"),
#   required_scopes = "records.read"
# )
# 
# ui <- oauth_ui(fluidPage(
#   actionButton("login", "Sign in"),
#   actionButton("again", "Sign in again"),
#   actionButton("logout", "Sign out"),
#   actionButton("load", "Load records"),
#   textOutput("permissions"),
#   verbatimTextOutput("records")
# ), id = "auth", client = client)
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server(
#     "auth", client, auto_redirect = FALSE, refresh_proactively = TRUE
#   )
#   observeEvent(input$login, {
#     auth$request_login()
#     invisible(NULL)
#   })
#   observeEvent(input$again, {
#     auth$reauthorize()
#     invisible(NULL)
#   })
#   observeEvent(input$logout, auth$logout())
# 
#   output$permissions <- renderText({
#     connection <- req(auth$connection())
#     if (connection$has_scopes("records.write")) "Editing available" else "Read only"
#   })
# 
#   records <- eventReactive(input$load, {
#     connection <- req(auth$connection())
#     data <- tryCatch({
#       response <- httr2::request("https://api.example/records") |>
#         httr2::req_auth_bearer_token(
#           connection$access_token(required_scopes = "records.read")
#         ) |>
#         httr2::req_perform()
#       httr2::resp_body_json(response)
#     }, shinyOAuth_access_error = function(error) {
#       showNotification("Authorization unavailable. Try again or sign in again.")
#       req(FALSE)
#     })
#     list(authorization = connection$id, data = data)
#   })
# 
#   output$records <- renderPrint({
#     connection <- req(auth$connection())
#     result <- records()
#     req(identical(result$authorization, connection$id))
#     req(connection$has_scopes("records.read"))
#     result$data
#   })
# }
# 
# shinyApp(ui, server, uiPattern = ".*")

## ----eval = FALSE-------------------------------------------------------------
# sdk <- reactive({
#   connection <- req(auth$connection())
#   example_sdk_client(
#     token = function() connection$access_token(required_scopes = "records.read")
#   )
# })

## ----eval = FALSE-------------------------------------------------------------
# # Configure mirai daemons or a non-sequential future plan before starting Shiny.
# # Inside the owning Shiny session:
# connection <- req(auth$connection())
# pending <- connection$access_token(required_scopes = "records.read", async = TRUE)
# promises::then(pending, function(token) {
#   # Recheck before starting work after an asynchronous boundary.
#   current <- req(auth$connection())
#   req(identical(current$id, connection$id))
#   req(current$has_scopes("records.read"))
#   existing_sdk_read_records(access_token = token)
# })

## ----eval=FALSE---------------------------------------------------------------
# # Configure future::plan(future::multisession) before starting the app.
# # Inside server(), with auth already created:
# load_records <- shiny::ExtendedTask$new(function(token, authorization_id) {
#   promises::future_promise({
#     list(
#       authorization_id = authorization_id,
#       data = existing_sdk_read_records(access_token = token)
#     )
#   })
# })
# 
# shiny::observeEvent(input$load, {
#   shiny::req(load_records$status() != "running")
#   connection <- shiny::req(auth$connection())
#   token <- connection$access_token("records.read", min_valid_for_seconds = 120)
#   load_records$invoke(token, connection$id)
# })
# 
# output$records <- shiny::renderTable({
#   connection <- shiny::req(auth$connection())
#   shiny::req(connection$has_scopes("records.read"))
#   result <- load_records$result()
#   shiny::req(identical(result$authorization_id, connection$id))
#   result$data
# })

