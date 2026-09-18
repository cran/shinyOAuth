## ----multiple-clients, eval = FALSE-------------------------------------------
# library(shiny)
# library(shinyOAuth)
# 
# app_origin <- "http://127.0.0.1:8100"
# callbacks <- paste0(app_origin, c("/callback/a", "/callback/b"))
# 
# provider_a <- oauth_provider(
#   name = "Service A",
#   auth_url = "https://login.a.example/authorize",
#   token_url = "https://login.a.example/token",
#   token_auth_style = "header",
#   use_pkce = TRUE,
#   pkce_method = "S256"
# )
# provider_b <- oauth_provider(
#   name = "Service B",
#   auth_url = "https://login.b.example/authorize",
#   token_url = "https://login.b.example/token",
#   token_auth_style = "header",
#   use_pkce = TRUE,
#   pkce_method = "S256"
# )
# 
# client_a <- oauth_client(
#   provider_a,
#   client_id = Sys.getenv("SERVICE_A_CLIENT_ID"),
#   client_secret = Sys.getenv("SERVICE_A_CLIENT_SECRET"),
#   redirect_uri = callbacks[[1]],
#   scopes = "records.read",
#   resource_bases = c(api = "https://api.a.example/v1"),
#   required_scopes = "records.read",
#   label = "Service A",
#   authorization_server_mode = "multi_redirect_uri",
#   authorization_server_redirect_uris = callbacks
# )
# client_b <- oauth_client(
#   provider_b,
#   client_id = Sys.getenv("SERVICE_B_CLIENT_ID"),
#   client_secret = Sys.getenv("SERVICE_B_CLIENT_SECRET"),
#   redirect_uri = callbacks[[2]],
#   scopes = "records.read",
#   resource_bases = c(api = "https://api.b.example/v1"),
#   required_scopes = "records.read",
#   label = "Service B",
#   authorization_server_mode = "multi_redirect_uri",
#   authorization_server_redirect_uris = callbacks
# )
# 
# clients <- list(a = client_a, b = client_b)

## ----multiple-manager, eval = FALSE-------------------------------------------
# # Temporary keys for this local demo, generated once per R process.
# # In a deployment, load two independent 32-byte raw keys from secret storage.
# keys <- list(
#   credentials = openssl::rand_bytes(32),
#   owner = openssl::rand_bytes(32)
# )
# 
# manager <- oauth_connections(
#   clients,
#   app_origin = app_origin,
#   retention = "browser",
#   owner_policy = oauth_browser_owner(allow_http_loopback = TRUE),
#   store = oauth_connection_store_memory(),
#   keys = keys
# )

## ----multiple-app, eval = FALSE-----------------------------------------------
# base_ui <- fluidPage(
#   use_shinyOAuth(),
#   h2("My connected services"),
#   actionButton("connect_a", "Connect Service A"),
#   actionButton("connect_b", "Connect Service B"),
#   selectInput("connection_id", "Saved authorization", choices = character()),
#   actionButton("read", "Read records"),
#   actionButton("disconnect", "Disconnect selected"),
#   actionButton("logout", "Disconnect all and leave"),
#   textOutput("result"),
#   textOutput("auth_error")
# )
# ui <- oauth_connections_ui(base_ui, "services", manager)
# 
# server <- function(input, output, session) {
#   auth <- oauth_connections_server("services", manager)
#   observeEvent(input[["connect_a"]], auth[["connect"]]("a"))
#   observeEvent(input[["connect_b"]], auth[["connect"]]("b"))
# 
#   observe({
#     rows <- auth[["connections"]]()
#     ids <- vapply(rows, function(x) x[["connection_id"]], character(1))
#     labels <- vapply(seq_along(rows), function(i) {
#       paste(rows[[i]][["client_label"]], i, paste0("(", rows[[i]][["status"]], ")"))
#     }, character(1))
#     selected <- isolate(input[["connection_id"]])
#     if (!length(selected) || !selected %in% ids) selected <- head(ids, 1)
#     updateSelectInput(session, "connection_id",
#       choices = setNames(ids, labels), selected = selected)
#   })
# 
#   selected_connection <- reactive({
#     rows <- auth[["connections"]]()
#     ids <- vapply(rows, function(x) x[["connection_id"]], character(1))
#     req(input[["connection_id"]], input[["connection_id"]] %in% ids)
#     auth[["connection"]](input[["connection_id"]])
#   })
# 
#   result <- eventReactive(input[["read"]], {
#     auth[["touch"]]()
#     connection <- selected_connection()
#     req(connection[["is_usable"]]())
#     message <- tryCatch({
#       response <- connection[["request"]](
#         "api", "records", required_scopes = "records.read"
#       )
#       httr2::resp_check_status(response)
#       # Parse the body here according to your API's schema.
#       paste("Records request succeeded; HTTP", httr2::resp_status(response))
#     }, error = function(e) "Could not read records. Check the connection and try again.")
#     list(connection_id = connection[["id"]], message = message)
#   })
# 
#   output[["result"]] <- renderText({
#     connection <- selected_connection()
#     req(connection[["is_usable"]]())
#     value <- result()
#     req(identical(value[["connection_id"]], connection[["id"]]))
#     value[["message"]]
#   })
#   observeEvent(input[["disconnect"]], {
#     auth[["disconnect"]](selected_connection()[["id"]])
#   })
#   observeEvent(input[["logout"]], auth[["logout"]]())
#   output[["auth_error"]] <- renderText({
#     if (length(auth[["errors"]]())) "Authorization is unavailable. Try connecting again."
#   })
# }
# 
# runApp(shinyApp(ui, server, uiPattern = ".*"),
#   host = "127.0.0.1", port = 8100, launch.browser = FALSE)

## ----multiple-request-body, eval = FALSE--------------------------------------
# observeEvent(input[["write"]], {
#   auth[["touch"]]()
#   connection <- selected_connection()
#   req(connection[["is_usable"]]())
#   tryCatch({
#     response <- connection[["request"]]("api", "records/example", method = "PUT",
#       required_scopes = "records.write", configure = function(req) {
#         req |>
#           httr2::req_body_json(list(name = "Updated record")) |>
#           httr2::req_headers(`If-Match` = 'W/"7"')
#       })
#     httr2::resp_check_status(response)
#     showNotification("Record updated.")
#   }, error = function(e) {
#     showNotification("Could not update the record.", type = "error")
#   })
# })

## ----multiple-refresh, eval = FALSE-------------------------------------------
# observeEvent(input[["refresh"]], {
#   tryCatch(selected_connection()[["refresh"]](), error = function(e) {
#     showNotification("Could not refresh. Connect again if access has ended.", type = "error")
#   })
# })

## ----multiple-identity, eval = FALSE------------------------------------------
# identity <- selected_connection()[["identity"]](userinfo = c("name", "email"))
# # identity[["id_token_claims"]] contains only iss and sub by default.
# # identity[["userinfo"]] contains only the selected, previously fetched fields.

## ----mixed-login-configuration, eval = FALSE----------------------------------
# callbacks <- c("https://app.example/login/callback", "https://app.example/fhir/callback")
# login_client <- oauth_client(login_provider, "registered-login-app",
#   redirect_uri = callbacks[[1]], scopes = c("openid", "profile"),
#   authorization_server_mode = "multi_redirect_uri",
#   authorization_server_redirect_uris = callbacks)
# fhir_client <- smart_client(site, "registered-fhir-app", callbacks[[2]],
#   scopes = c("launch/patient", "patient/Patient.r"),
#   authorization_server_mode = "multi_redirect_uri",
#   authorization_server_redirect_uris = callbacks)
# manager <- oauth_connections(list(fhir = fhir_client), "https://app.example",
#   retention = "browser", owner_policy = oauth_browser_owner(),
#   store = oauth_connection_store_memory(), keys = keys)
# base_ui <- fluidPage(actionButton("sign_in", "Sign in"),
#   actionButton("connect_fhir", "Connect FHIR"))
# ui <- oauth_connections_ui(base_ui, "health", manager,
#   additional_clients = list(login = login_client))
# server <- function(input, output, session) {
#   login <- oauth_module_server("login", login_client, auto_redirect = FALSE)
#   health <- oauth_connections_server("health", manager)
#   observeEvent(input[["sign_in"]], login[["request_login"]]())
#   observeEvent(input[["connect_fhir"]], health[["connect"]]("fhir"))
# }
# shinyApp(ui, server, uiPattern = ".*")

