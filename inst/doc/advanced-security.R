## ----eval = FALSE-------------------------------------------------------------
# provider <- oauth_provider_oidc_discover(
#   issuer = "https://id.example.com"
# )

## ----eval = FALSE-------------------------------------------------------------
# provider <- oauth_provider_oidc_discover(
#   "https://id.example.com", token_auth_style = "private_key_jwt"
# )
# client <- oauth_client(
#   provider = provider,
#   client_id = "client-id",
#   redirect_uri = "https://app.example.com",
#   scopes = c("openid", "profile"),
#   client_assertion_private_key = openssl::read_key("keys/client-key.pem"),
#   client_assertion_private_key_kid = "registered-key-id"
# )

## ----eval = FALSE-------------------------------------------------------------
# client@client_assertion_audience <- provider@issuer
# client@client_assertion_typ <- "client-authentication+jwt"

## ----eval = FALSE-------------------------------------------------------------
# client@endpoint_auth <- list(
#   introspection = list(
#     token_auth_style = "header",
#     client_id = "registered-inspector",
#     client_secret = Sys.getenv("INTROSPECTION_SECRET"),
#     extra_headers = c("X-App" = "registered-app")
#   ),
#   revocation = list(
#     token_auth_style = "private_key_jwt",
#     client_assertion_private_key = openssl::read_key("keys/revocation-key.pem"),
#     client_assertion_alg = "RS256",
#     client_assertion_audience = "https://id.example.com/revocation"
#   )
# )

## ----mtls-provider, eval = FALSE----------------------------------------------
# provider <- oauth_provider(
#   name = "example-mtls",
#   # Exact OIDC issuer; enables nonce and ID-token validation
#   issuer = "https://id.example.com",
#   auth_url = "https://id.example.com/authorize",
#   token_url = "https://id.example.com/token",
#   jwks_uri = "https://id.example.com/jwks",
#   userinfo_url = "https://id.example.com/userinfo",
#   # Use RFC 8705 client-certificate auth at the token endpoint
#   token_auth_style = "tls_client_auth",
#   # Use mTLS-specific endpoints when the provider publishes them
#   mtls_endpoint_aliases = list(
#     token_endpoint = "https://mtls.id.example.com/token",
#     userinfo_endpoint = "https://mtls.id.example.com/userinfo"
#   ),
#   # Expect certificate-bound access tokens from the provider
#   mtls_client_certificate_bound_access_tokens = TRUE
# )

## ----eval = FALSE-------------------------------------------------------------
# client <- oauth_client(
#   provider = provider,
#   client_id = "client-id",
#   redirect_uri = "https://app.example.com/auth/callback",
#   scopes = c("openid", "profile"),
#   # Certificate and key sent on mTLS requests
#   mtls_client_cert_file = "certs/client.pem",
#   mtls_client_key_file = "certs/client-key.pem",
#   mtls_client_ca_file = "certs/ca.pem",
#   # Require the matching certificate when access tokens are used
#   mtls_certificate_bound_access_tokens = TRUE
# )

## ----eval = FALSE-------------------------------------------------------------
# client <- oauth_client(
#   provider = provider,
#   client_id = "client-id",
#   redirect_uri = "https://app.example.com/auth/callback",
#   mtls_client_cert_file = "certs/client.pem",
#   mtls_client_key_file = "certs/client-key.pem",
#   mtls_certificate_bound_access_tokens = TRUE,
#   mtls_require_observed_cnf = FALSE
# )

## ----eval = FALSE-------------------------------------------------------------
# provider <- oauth_provider(
#   name = "example-jar",
#   issuer = "https://id.example.com",
#   auth_url = "https://id.example.com/authorize",
#   token_url = "https://id.example.com/token",
#   # The server registration must already require signed Request Objects
#   signed_request_object_required = TRUE,
#   request_parameter_supported = TRUE,
#   request_object_signing_alg_values_supported = c("RS256")
# )
# 
# client <- oauth_client(
#   provider = provider,
#   client_id = "client-id",
#   client_secret = "client-secret",
#   redirect_uri = "https://app.example.com/auth/callback",
#   scopes = c("openid", "profile"),
#   # Signing key for the Request Object
#   client_assertion_private_key = openssl::read_key("keys/client-key.pem"),
#   # Send the authorization request as a JWT in the request parameter
#   request_object_mode = "request",
#   request_object_signing_alg = "RS256"
# )

## ----eval = FALSE-------------------------------------------------------------
# unsigned <- httr2::request(provider@auth_url) |>
#   httr2::req_url_query(
#     client_id = client@client_id,
#     redirect_uri = client@redirect_uri,
#     response_type = "code", scope = "openid profile",
#     state = "unsigned-policy-probe",
#     code_challenge = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM",
#     code_challenge_method = "S256"
#   ) |>
#   httr2::req_options(followlocation = FALSE) |>
#   httr2::req_error(is_error = function(resp) FALSE) |>
#   httr2::req_perform()
# httr2::resp_status(unsigned)
# httr2::resp_headers(unsigned)
# httr2::resp_body_string(unsigned)

## ----eval = FALSE-------------------------------------------------------------
# request_uri_provider <- oauth_provider(
#   name = "example-request-uri",
#   issuer = "https://id.example.com",
#   auth_url = "https://id.example.com/authorize",
#   token_url = "https://id.example.com/token",
#   request_uri_parameter_supported = TRUE,
#   request_object_signing_alg_values_supported = "RS256"
# )
# 
# client <- oauth_client(
#   provider = request_uri_provider,
#   client_id = "client-id",
#   client_secret = "client-secret",
#   redirect_uri = "https://app.example.com/auth/callback",
#   scopes = c("openid", "profile"),
#   client_assertion_private_key = openssl::read_key("keys/client-key.pem"),
#   # Publish the Request Object by reference instead of sending it inline
#   request_object_mode = "request_uri",
#   request_object_signing_alg = "RS256"
# )
# 
# # Inside server()
# auth <- oauth_module_server(
#   "auth",
#   client,
#   auto_redirect = TRUE,
#   # Public HTTPS base URL of this Shiny app as seen by the provider
#   request_uri_base_url = "https://shiny.yourdomain.com/myapp"
# )

## ----eval = FALSE-------------------------------------------------------------
# provider <- oauth_provider(
#   name = "example-par",
#   issuer = "https://id.example.com",
#   auth_url = "https://id.example.com/authorize",
#   token_url = "https://id.example.com/token",
#   # Enable pushed authorization requests
#   par_url = "https://id.example.com/par",
#   par_required = TRUE,
#   # Keep the browser redirect down to client_id + PAR request_uri
#   authorization_request_front_channel_mode = "minimal"
# )
# 
# client <- oauth_client(
#   provider = provider,
#   client_id = "client-id",
#   client_secret = "client-secret",
#   redirect_uri = "https://app.example.com/auth/callback",
#   scopes = c("openid", "profile")
# )

## ----eval = FALSE-------------------------------------------------------------
# base_ui <- shiny::fluidPage(shiny::textOutput("status"))
# ui <- oauth_form_post_ui(base_ui, id = "auth", client = client)
# 
# server <- function(input, output, session) {
#   auth <- oauth_module_server("auth", client)
#   output[["status"]] <- shiny::renderText({
#     if (isTRUE(auth[["authenticated"]])) "Signed in" else "Waiting for login"
#   })
# }
# 
# app <- shiny::shinyApp(ui, server, uiPattern = ".*")

## ----eval = FALSE-------------------------------------------------------------
# trusted_proxy_uri <- function(req) {
#   if (!identical(req[["REMOTE_ADDR"]], "10.0.0.10") ||
#       !identical(req[["HTTP_X_FORWARDED_PROTO"]], "https")) {
#     return(NULL)
#   }
#   paste0("https://app.example.com", req[["SCRIPT_NAME"]], req[["PATH_INFO"]])
# }
# 
# ui <- oauth_form_post_ui(
#   base_ui, id = "auth", client = client,
#   request_uri_resolver = trusted_proxy_uri
# )

## ----eval = FALSE-------------------------------------------------------------
# provider <- oauth_provider(
#   name = "example-jarm",
#   issuer = "https://id.example.com",
#   auth_url = "https://id.example.com/authorize",
#   token_url = "https://id.example.com/token",
#   # Advertise the JARM response modes and algorithms this provider supports
#   response_modes_supported = c("query", "query.jwt", "form_post.jwt"),
#   jarm_signing_alg_values_supported = c("RS256"),
#   jarm_encryption_alg_values_supported = c("RSA-OAEP"),
#   jarm_encryption_enc_values_supported = c("A128CBC-HS256")
# )
# 
# client <- oauth_client(
#   provider = provider,
#   client_id = "client-id",
#   client_secret = "client-secret",
#   redirect_uri = "https://app.example.com/auth/callback",
#   scopes = c("openid", "profile"),
#   # Ask for a JWT-wrapped authorization response
#   response_mode = "query.jwt",
#   jarm_signed_response_alg = "RS256"
# )

## ----eval = FALSE-------------------------------------------------------------
# client <- oauth_client(
#   provider = provider,
#   client_id = "client-id",
#   client_secret = "client-secret",
#   redirect_uri = "https://app.example.com/auth/callback",
#   scopes = c("openid", "profile"),
#   response_mode = "query.jwt",
#   jarm_signed_response_alg = "RS256",
#   # Optional: decrypt JARM before validating the signed payload
#   jarm_encrypted_response_alg = "RSA-OAEP",
#   jarm_encrypted_response_enc = "A128CBC-HS256",
#   jarm_decryption_private_key = openssl::read_key("keys/jarm-decrypt.pem")
# )

## ----eval = FALSE-------------------------------------------------------------
# provider <- oauth_provider(
#   name = "example-dpop",
#   issuer = "https://id.example.com",
#   auth_url = "https://id.example.com/authorize",
#   token_url = "https://id.example.com/token",
#   # Optional metadata check for acceptable DPoP signing algorithms
#   dpop_signing_alg_values_supported = c("ES256")
# )
# 
# client <- oauth_client(
#   provider = provider,
#   client_id = "client-id",
#   client_secret = "client-secret",
#   redirect_uri = "https://app.example.com/auth/callback",
#   scopes = c("openid", "profile", "api.read"),
#   # Private key used to sign DPoP proofs
#   dpop_private_key = openssl::read_key("keys/dpop-key.pem"),
#   dpop_signing_alg = "ES256"
# )

## ----eval = FALSE-------------------------------------------------------------
# resp <- perform_resource_req(
#   auth[["token"]],
#   "https://api.example.com/me",
#   # Lets shinyOAuth attach the DPoP proof and handle nonce challenges
#   client = client
# )

