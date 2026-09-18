## ----eval = FALSE-------------------------------------------------------------
# options(shinyOAuth.audit_hook = function(event) {
#   cat(sprintf("[shinyOAuth] %s | %s\n", event[["type"]], event[["trace_id"]]))
#   str(event)
# })

## ----eval = FALSE-------------------------------------------------------------
# options(shinyOAuth.audit_include_http = FALSE)

## ----eval = FALSE-------------------------------------------------------------
# audit_digest_key <- Sys.getenv("AUDIT_DIGEST_KEY", unset = NA_character_)
# if (is.na(audit_digest_key) || !nzchar(audit_digest_key)) {
#   stop("AUDIT_DIGEST_KEY must be configured before the app starts")
# }
# options(shinyOAuth.audit_digest_key = audit_digest_key)

