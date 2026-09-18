## ----eval = FALSE-------------------------------------------------------------
# library(shiny)
# library(shinyOAuth)
# 
# # Configure these once, outside server().
# provider <- oauth_provider_github()
# client <- oauth_client(
#   provider = provider,
#   client_id = Sys.getenv("GITHUB_OAUTH_CLIENT_ID"),
#   client_secret = Sys.getenv("GITHUB_OAUTH_CLIENT_SECRET"),
#   redirect_uri = "http://127.0.0.1:8100",
#   scopes = c("read:user", "user:email")
# )
# 
# ui <- oauth_ui(fluidPage(
#   h2("My app"),
#   textOutput("greeting")
# ), id = "auth", client = client)
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server("auth", client)
# 
#   output[["greeting"]] <- renderText({
#     req(auth[["authenticated"]])
#     paste("Hello,", auth[["token"]]@userinfo[["login"]])
#   })
# }
# 
# runApp(shinyApp(ui, server), port = 8100, launch.browser = FALSE)

## ----eval = FALSE-------------------------------------------------------------
# ui <- oauth_ui(fluidPage(
#   actionButton("login", "Sign in"),
#   actionButton("logout", "Sign out"),
#   textOutput("status")
# ), id = "auth", client = client)
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server("auth", client, auto_redirect = FALSE)
# 
#   observeEvent(input[["login"]], auth[["request_login"]]())
#   observeEvent(input[["logout"]], auth[["logout"]]())
# 
#   output[["status"]] <- renderText({
#     if (isTRUE(auth[["authenticated"]])) {
#       paste("Signed in as", auth[["token"]]@userinfo[["login"]])
#     } else {
#       "You are signed out. Use Sign in to continue."
#     }
#   })
# }

## ----eval = FALSE-------------------------------------------------------------
# output[["repositories"]] <- renderTable({
#   req(auth[["authenticated"]])
# 
#   repos <- tryCatch({
#     response <- perform_resource_req(
#       auth[["token"]],
#       "https://api.github.com/user/repos",
#       query = list(per_page = 10)
#     )
#     httr2::resp_check_status(response)
#     httr2::resp_body_json(response, simplifyVector = TRUE)
#   }, error = function(e) NULL)
# 
#   validate(need(!is.null(repos), "Could not load repositories. Try again later."))
#   validate(need(length(repos) > 0, "No repositories to show."))
#   repos[, c("name", "private"), drop = FALSE]
# })

## ----eval = FALSE-------------------------------------------------------------
# # Inside reactive server code, after a successful login:
# token <- auth[["token"]]
# token@extra_fields[["custom_field"]]
# token@initial_extra_fields[["custom_field"]]
# 
# # Distinguish an absent field from one explicitly returned as null.
# "custom_field" %in% names(token@extra_fields)

## ----eval = FALSE-------------------------------------------------------------
# provider <- oauth_provider_oidc_discover(
#   issuer = "https://login.example.com"
# )
# client <- oauth_client(
#   provider = provider,
#   client_id = Sys.getenv("OAUTH_CLIENT_ID"),
#   client_secret = Sys.getenv("OAUTH_CLIENT_SECRET"),
#   redirect_uri = "https://my-app.example.com",
#   scopes = c("openid", "profile", "email")
# )

## ----eval = FALSE-------------------------------------------------------------
# options(shinyOAuth.allow_insecure_oidc_loopback = TRUE)
# provider <- oauth_provider_keycloak(
#   base_url = "http://localhost:8080", realm = "shinyoauth"
# )

## ----eval = FALSE-------------------------------------------------------------
# options(shinyOAuth.tls_min_version = "1.2") # Set before discovery or login.
# provider <- oauth_provider(
#   name = "Example authorization server",
#   auth_url = "https://auth.example/authorize",
#   token_url = "https://auth.example/token",
#   token_auth_style = "public",
#   use_pkce = TRUE,
#   pkce_method = "S256"
# )
# client <- oauth_client(
#   provider,
#   client_id = "registered-client",
#   redirect_uri = "https://app.example/callback",
#   scopes = "read"
# )
# assessment <- check_oauth21(client)
# assessment[["configuration_compliant"]]
# assessment[["checks"]]

## ----eval = FALSE-------------------------------------------------------------
# assessment <- check_oauth21(
#   client,
#   context = list(operations = c("introspection", "revocation"))
# )

## ----eval = FALSE-------------------------------------------------------------
# if (identical(assessment[["configuration_compliant"]], FALSE)) {
#   stop("Resolve the mandatory configuration findings before deployment.")
# }
# if (is.na(assessment[["configuration_compliant"]])) {
#   message("Review unresolved configuration prerequisites before deployment.")
# }

## ----eval = FALSE-------------------------------------------------------------
# redirects <- c("https://app.example/oauth/a", "https://app.example/oauth/b")
# # provider_a and provider_b are independently configured OAuth/OIDC providers.
# clients <- list(
#   auth_a = oauth_client(
#     provider_a, client_id = Sys.getenv("SITE_A_CLIENT_ID"),
#     client_secret = Sys.getenv("SITE_A_CLIENT_SECRET"),
#     redirect_uri = redirects[[1]], scopes = c("read"),
#     authorization_server_mode = "multi_redirect_uri",
#     authorization_server_redirect_uris = redirects
#   ),
#   auth_b = oauth_client(
#     provider_b, client_id = Sys.getenv("SITE_B_CLIENT_ID"),
#     client_secret = Sys.getenv("SITE_B_CLIENT_SECRET"),
#     redirect_uri = redirects[[2]], scopes = c("read"),
#     authorization_server_mode = "multi_redirect_uri",
#     authorization_server_redirect_uris = redirects
#   )
# )
# ui <- oauth_ui(fluidPage(
#   actionButton("connect_a", "Connect A"),
#   actionButton("connect_b", "Connect B")
# ), clients = clients)
# server <- function(input, output, session) {
#   a <- oauth_module_server("auth_a", clients[["auth_a"]], auto_redirect = FALSE)
#   b <- oauth_module_server("auth_b", clients[["auth_b"]], auto_redirect = FALSE)
#   observeEvent(input[["connect_a"]], a[["request_login"]]())
#   observeEvent(input[["connect_b"]], b[["request_login"]]())
# }
# shinyApp(ui, server, uiPattern = ".*")

## ----eval = FALSE-------------------------------------------------------------
# client <- oauth_client(
#   provider, client_id = "registered-app",
#   redirect_uri = "https://app.example/callback", scopes = "read",
#   resource_bases = c(records = "https://api.example/v1"),
#   required_scopes = "read" # A subset of the requested scopes.
# )
# server <- function(input, output, session) {
#   auth <- oauth_module_server("auth", client)
#   connection <- oauth_connection(client, reactive(auth[["token"]]))
#   records <- reactive({
#     req(connection[["is_usable"]]())
#     connection[["request"]]("records", "records", query = list(limit = 20)) |>
#       httr2::resp_body_json()
#   })
# }

## ----eval = FALSE-------------------------------------------------------------
# mirai::daemons(2)
# shiny::onStop(function() mirai::daemons(0))
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server("auth", client, async = TRUE)
#   # Add your outputs and observers here.
# }

## ----eval = FALSE-------------------------------------------------------------
# future::plan(future::multisession, workers = 2)
# shiny::onStop(function() future::plan(future::sequential))
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server("auth", client, async = TRUE)
#   # Add your outputs and observers here.
# }

