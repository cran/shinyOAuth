## ----smart-configuration, eval = FALSE----------------------------------------
# library(shiny)
# library(shinyOAuth)
# 
# app_origin <- "http://127.0.0.1:8100"
# discovery <- smart_discover(
#   "https://ehr.example/fhir/R4",
#   endpoint_hosts = c("ehr.example", "login.example"),
#   allow_http_loopback = TRUE # Enable the registered local HTTP callback for this demo.
# )
# 
# client <- smart_client(
#   discovery,
#   client_id = Sys.getenv("SMART_CLIENT_ID"),
#   client_secret = Sys.getenv("SMART_CLIENT_SECRET"),
#   token_auth_style = "header",
#   redirect_uri = paste0(app_origin, "/callback/fhir"),
#   launch = "standalone",
#   scopes = c("launch/patient", "patient/Patient.r", "patient/Observation.s"),
#   required_scopes = "patient/Patient.r",
#   label = "My hospital"
# )

## ----smart-manager, eval = FALSE----------------------------------------------
# manager <- oauth_connections(
#   clients = list(hospital = client),
#   app_origin = app_origin,
#   retention = "browser",
#   owner_policy = oauth_browser_owner(allow_http_loopback = TRUE),
#   store = oauth_connection_store_memory(),
#   # Temporary keys for this local demo, created once at app startup.
#   # For deployment, load independent 32-byte raw keys from secret storage.
#   keys = list(
#     credentials = openssl::rand_bytes(32),
#     owner = openssl::rand_bytes(32)
#   )
# )

## ----smart-app, eval = FALSE--------------------------------------------------
# base_ui <- fluidPage(
#   use_shinyOAuth(),
#   h2("FHIR patient example"),
#   actionButton("connect", "Connect hospital"),
#   selectInput("connection_id", "Saved authorization", choices = character()),
#   actionButton("load_patient", "Load patient"),
#   actionButton("disconnect", "Disconnect selected"),
#   textOutput("patient"),
#   textOutput("auth_error")
# )
# ui <- oauth_connections_ui(base_ui, "health", manager)
# 
# server <- function(input, output, session) {
#   health <- oauth_connections_server("health", manager)
#   observeEvent(input[["connect"]], health[["connect"]]("hospital"))
# 
#   observe({
#     rows <- health[["connections"]]()
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
#     rows <- health[["connections"]]()
#     ids <- vapply(rows, function(x) x[["connection_id"]], character(1))
#     req(input[["connection_id"]], input[["connection_id"]] %in% ids)
#     connection <- health[["connection"]](input[["connection_id"]])
#     req(connection[["is_usable"]]())
#     connection
#   })
# 
#   patient <- eventReactive(input[["load_patient"]], {
#     health[["touch"]]()
#     connection <- selected_connection()
#     context <- smart_context(connection)
#     data <- tryCatch({
#       response <- smart_patient(connection)
#       httr2::resp_check_status(response)
#       httr2::resp_body_json(response, simplifyVector = FALSE)
#     }, error = function(e) NULL)
#     list(connection_id = connection[["id"]], revision = context[["revision"]], data = data)
#   })
# 
#   output[["patient"]] <- renderText({
#     connection <- selected_connection()
#     context <- smart_context(connection)
#     value <- patient()
#     # Clear the display if the selected grant or accepted context has changed.
#     req(identical(value[["connection_id"]], connection[["id"]]),
#         identical(value[["revision"]], context[["revision"]]))
#     validate(need(!is.null(value[["data"]]), "Could not load this patient's record."))
#     paste("Patient resource:", value[["data"]][["id"]])
#   })
#   observeEvent(input[["disconnect"]], {
#     # Allow disconnect even when the connection has become unusable.
#     req(input[["connection_id"]])
#     health[["disconnect"]](input[["connection_id"]])
#   })
#   output[["auth_error"]] <- renderText({
#     if (length(health[["errors"]]())) "Authorization is unavailable. Try authorizing again."
#   })
# }
# 
# runApp(shinyApp(ui, server, uiPattern = ".*"),
#   host = "127.0.0.1", port = 8100, launch.browser = FALSE)

## ----smart-search, eval = FALSE-----------------------------------------------
# observeEvent(input[["search"]], {
#   health[["touch"]]()
#   connection <- selected_connection()
#   context <- smart_context(connection)
#   req(context[["patient"]])
#   tryCatch({
#     response <- connection[["request"]](
#       "fhir", "Observation",
#       query = list(patient = context[["patient"]], `_count` = 10),
#       required_scopes = "patient/Observation.s",
#       configure = function(req) httr2::req_headers(req, Accept = "application/fhir+json")
#     )
#     httr2::resp_check_status(response)
#     bundle <- httr2::resp_body_json(response, simplifyVector = FALSE)
#     # Process bundle[["entry"]] here, associating data with this ID and revision.
#     showNotification("Observation search completed.")
#   }, error = function(e) {
#     showNotification("Could not search observations. Check the granted permissions.",
#       type = "error")
#   })
# })

## ----smart-ehr-client, eval = FALSE-------------------------------------------
# client <- smart_client(
#   discovery,
#   client_id = Sys.getenv("SMART_EHR_CLIENT_ID"),
#   client_secret = Sys.getenv("SMART_EHR_CLIENT_SECRET"),
#   token_auth_style = "header",
#   redirect_uri = paste0(app_origin, "/callback/fhir"),
#   launch = "ehr",
#   scopes = c("patient/Patient.r", "patient/Observation.s"),
#   required_scopes = "patient/Patient.r",
#   label = "My hospital"
# )

## ----smart-ehr-ui, eval = FALSE-----------------------------------------------
# ui <- oauth_connections_ui(base_ui, "health", manager,
#   launch_routes = list(smart_launch_route("/smart/launch", "hospital")))

## ----smart-asymmetric, eval = FALSE-------------------------------------------
# client <- smart_client(
#   discovery,
#   client_id = Sys.getenv("SMART_ASYMMETRIC_CLIENT_ID"),
#   redirect_uri = paste0(app_origin, "/callback/fhir"),
#   launch = "standalone",
#   scopes = c("launch/patient", "patient/Patient.r"),
#   required_scopes = "patient/Patient.r",
#   token_auth_style = "private_key_jwt",
#   client_assertion_private_key = openssl::read_key(Sys.getenv("SMART_PRIVATE_KEY_FILE")),
#   client_assertion_private_key_kid = Sys.getenv("SMART_KEY_ID"),
#   client_assertion_alg = "RS384",
#   label = "My hospital"
# )

