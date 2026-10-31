## ----spotify-app, eval = FALSE------------------------------------------------
# library(shiny)
# library(shinyOAuth)
# 
# client <- oauth_client(
#   provider = oauth_provider_spotify(),
#   client_id = Sys.getenv("SPOTIFY_OAUTH_CLIENT_ID"),
#   client_secret = Sys.getenv("SPOTIFY_OAUTH_CLIENT_SECRET"),
#   redirect_uri = "http://127.0.0.1:8100",
#   scopes = c("user-read-private", "user-top-read"),
#   resource_bases = c(spotify = "https://api.spotify.com/v1")
# )
# 
# ui <- oauth_ui(fluidPage(
#   h2("My top tracks"),
#   actionButton("load", "Load top tracks"),
#   tableOutput("tracks")
# ), id = "auth", client = client)
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server("auth", client)
#   tracks <- reactiveVal(NULL)
# 
#   observe({
#     connection <- auth[["connection"]]()
#     result <- isolate(tracks())
#     if (is.null(connection) ||
#         !connection[["has_scopes"]]("user-top-read") ||
#         (!is.null(result) &&
#          !identical(result[["authorization"]], connection[["id"]]))) {
#       tracks(NULL)
#     }
#   })
# 
#   observeEvent(input[["load"]], {
#     connection <- req(auth[["connection"]]())
#     req(connection[["has_scopes"]]("user-top-read"))
#     data <- tryCatch({
#       response <- connection[["request"]](
#         "spotify", "me/top/tracks",
#         query = list(limit = 10, time_range = "short_term"),
#         required_scopes = "user-top-read",
#         refresh = TRUE
#       )
#       httr2::resp_check_status(response)
#       body <- httr2::resp_body_json(response, simplifyVector = FALSE)
#       vapply(body[["items"]], function(track) track[["name"]], character(1))
#     }, error = function(e) NULL)
#     tracks(list(authorization = connection[["id"]], data = data))
#   })
# 
#   output[["tracks"]] <- renderTable({
#     connection <- req(auth[["connection"]]())
#     req(connection[["has_scopes"]]("user-top-read"))
#     result <- tracks()
#     req(identical(result[["authorization"]], connection[["id"]]))
#     values <- result[["data"]]
#     validate(need(!is.null(values), "Could not load tracks. Try again later."))
#     validate(need(length(values) > 0, "No listening data to show yet."))
#     data.frame(Track = values)
#   })
# }
# 
# runApp(shinyApp(ui, server), port = 8100, launch.browser = FALSE)

## ----eval = FALSE-------------------------------------------------------------
# install.packages(c("bslib", "ggplot2", "DT", "purrr", "dplyr"))
# dashboard_file <- system.file(
#   "examples", "spotify-dashboard.R", package = "shinyOAuth", mustWork = TRUE
# )
# file.show(dashboard_file)  # Read or copy the complete source.
# source(dashboard_file)    # Run after setting your Spotify credentials.

