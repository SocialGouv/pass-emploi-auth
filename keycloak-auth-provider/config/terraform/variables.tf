variable "ssl_required" {
  type        = string
  default     = "all"
  description = "Enabled SSL required on pass-emploi realm"
}

############### SWAGGER SECRETS ###############
variable "swagger_valid_redirect_uris" {
  type        = list(string)
  default     = ["*"]
  sensitive   = true
  description = "Valid redirect uris for web"
}

############### API SECRETS ###############
variable "api_client_secret" {
  type        = string
  default     = "6822c1da-c03e-4e40-8bcb-53c025d9c7d5"
  sensitive   = true
  description = "Client secret for api"
}

############### APP SECRETS ###############
variable "app_client_secret" {
  type        = string
  default     = "ad7bc35e-8b11-4dff-8a6c-341158371b4e"
  sensitive   = true
  description = "Client secret for app"
}
variable "app_valid_redirect_uris" {
  type = list(string)
  default = [
    "fr.fabrique.social.gouv.passemploi://login-callback",
  "fr.fabrique.social.gouv.passemploi://logout-callback"]
  sensitive   = true
  description = "Valid redirect uris for app"
}
