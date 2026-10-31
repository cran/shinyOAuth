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

