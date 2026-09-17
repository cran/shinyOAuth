## ----eval = FALSE-------------------------------------------------------------
# clients <- list(auth_a = client_a, auth_b = client_b)
# ui <- oauth_ui(shiny::fluidPage("My app"), clients = clients)
# server <- function(input, output, session) {
#   auth_a <- oauth_module_server("auth_a", client_a)
#   auth_b <- oauth_module_server("auth_b", client_b)
# }
# shiny::shinyApp(ui, server, uiPattern = ".*")

