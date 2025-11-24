## ----eval = FALSE-------------------------------------------------------------
# library(shiny)
# library(shinyOAuth)
# 
# provider <- oauth_provider_github()
# 
# client <- oauth_client(
#   provider = provider,
#   client_id = Sys.getenv("GITHUB_OAUTH_CLIENT_ID"),
#   client_secret = Sys.getenv("GITHUB_OAUTH_CLIENT_SECRET"),
#   redirect_uri = "http://127.0.0.1:8100",
#   scopes = c("read:user", "user:email")
# )
# 
# ui <- fluidPage(
#   # Include JavaScript dependency:
#   use_shinyOAuth(),
#   # Render login status & user info:
#   uiOutput("login")
# )
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server("auth", client, auto_redirect = TRUE)
#   output$login <- renderUI({
#     if (auth$authenticated) {
#       user_info <- auth$token@userinfo
#       tagList(
#         tags$p("You are logged in!"),
#         tags$pre(paste(capture.output(str(user_info)), collapse = "\n"))
#       )
#     } else {
#       tags$p("You are not logged in.")
#     }
#   })
# }
# 
# runApp(
#   shinyApp(ui, server), port = 8100,
#   launch.browser = FALSE
# )
# 
# # Open the app in your regular browser at http://127.0.01:8100
# # (viewers in RStudio/Positron/etc. cannot perform necessary redirects)

## ----eval = FALSE-------------------------------------------------------------
# library(shiny)
# library(shinyOAuth)
# 
# provider <- oauth_provider_github()
# 
# client <- oauth_client(
#   provider = provider,
#   client_id = Sys.getenv("GITHUB_OAUTH_CLIENT_ID"),
#   client_secret = Sys.getenv("GITHUB_OAUTH_CLIENT_SECRET"),
#   redirect_uri = "http://127.0.0.1:8100",
#   scopes = c("read:user", "user:email")
# )
# 
# ui <- fluidPage(
#   use_shinyOAuth(),
#   actionButton("login_btn", "Login"),
#   uiOutput("login")
# )
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server(
#     "auth",
#     client,
#     auto_redirect = FALSE
#   )
# 
#   observeEvent(input$login_btn, {
#     auth$request_login()
#   })
# 
#   output$login <- renderUI({
#     if (auth$authenticated) {
#       user_info <- auth$token@userinfo
#       tagList(
#         tags$p("You are logged in!"),
#         tags$pre(paste(capture.output(str(user_info)), collapse = "\n"))
#       )
#     } else {
#       tags$p("You are not logged in.")
#     }
#   })
# }
# 
# runApp(
#   shinyApp(ui, server), port = 8100,
#   launch.browser = FALSE
# )
# 
# # Open the app in your regular browser at http://127.0.01:8100
# # (viewers in RStudio/Positron/etc. cannot perform necessary redirects)

## ----eval = FALSE-------------------------------------------------------------
# library(shiny)
# library(shinyOAuth)
# 
# provider <- oauth_provider_github()
# 
# client <- oauth_client(
#   provider = provider,
#   client_id = Sys.getenv("GITHUB_OAUTH_CLIENT_ID"),
#   client_secret = Sys.getenv("GITHUB_OAUTH_CLIENT_SECRET"),
#   redirect_uri = "http://127.0.0.1:8100",
#   scopes = c("read:user", "user:email")
# )
# 
# ui <- fluidPage(
#   use_shinyOAuth(),
#   uiOutput("ui")
# )
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server(
#     "auth",
#     client,
#     auto_redirect = TRUE
#   )
# 
#   repositories <- reactiveVal(NULL)
# 
#   observe({
#     req(auth$authenticated)
# 
#     # Example additional API request using the access token
#     # (e.g., fetch user repositories from GitHub)
#     req <- client_bearer_req(auth$token, "https://api.github.com/user/repos")
#     resp <- httr2::req_perform(req)
# 
#     if (httr2::resp_is_error(resp)) {
#       repositories(NULL)
#     } else {
#       repos_data <- httr2::resp_body_json(resp, simplifyVector = TRUE)
#       repositories(repos_data)
#     }
#   })
# 
#   # Render username + their repositories
#   output$ui <- renderUI({
#     if (isTRUE(auth$authenticated)) {
#       user_info <- auth$token@userinfo
#       repos <- repositories()
# 
#       return(tagList(
#         tags$p(paste("You are logged in as:", user_info$login)),
#         tags$h4("Your repositories:"),
#         if (!is.null(repos)) {
#           tags$ul(
#             Map(function(url, name) {
#               tags$li(tags$a(href = url, target = "_blank", name))
#             }, repos$html_url, repos$full_name)
#           )
#         } else {
#           tags$p("Loading repositories...")
#         }
#       ))
#     }
# 
#     return(tags$p("You are not logged in."))
#   })
# }
# 
# runApp(
#   shinyApp(ui, server), port = 8100,
#   launch.browser = FALSE
# )
# 
# # Open the app in your regular browser at http://127.0.01:8100
# # (viewers in RStudio/Positron/etc. cannot perform necessary redirects)

