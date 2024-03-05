variable "ssl_required" {
  type        = string
  default     = "all"
  description = "Enabled SSL required on pass-emploi realm"
}

############### APPS URLs ###############
variable "restrict_valid_redirect_uris" {
  type        = bool
  default     = true
  description = "Restrict redirect uri or authorize every uri"
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

############### WEB SECRETS ###############
variable "web_client_secret" {
  type        = string
  default     = "b208225f-addd-4600-8ae5-de6e19234551"
  sensitive   = true
  description = "Client secret for web"
}

variable "web_valid_redirect_uris" {
  type        = list(string)
  default     = ["*"]
  sensitive   = true
  description = "Valid redirect uris for web"
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

############### IDP SECRETS ###############
variable "idps_hide_on_login_page" {
  type        = bool
  default     = true
  description = "hide idps button on login page"
}

############### CONSEILLERS MILO ###############
variable "idp_similo_conseiller_authorization_url" {
  type        = string
  default     = "https://sso-dev.i-milo.fr/auth/realms/imilo-IC-0/protocol/openid-connect/auth"
  sensitive   = true
  description = "authorization_url"
}

variable "idp_similo_conseiller_token_url" {
  type        = string
  default     = "https://sso-dev.i-milo.fr/auth/realms/imilo-IC-0/protocol/openid-connect/token"
  sensitive   = true
  description = "token_url"
}

variable "idp_similo_conseiller_logout_url" {
  type        = string
  default     = "https://sso-dev.i-milo.fr/auth/realms/imilo-IC-0/protocol/openid-connect/logout"
  sensitive   = true
  description = "logout_url"
}

variable "idp_similo_conseiller_enabled" {
  type        = bool
  default     = true
  description = "similo_conseiller_enabled"
}

variable "idp_similo_conseiller_client_secret" {
  type        = string
  default     = "NO_SECRET"
  sensitive   = true
  description = "client_secret"
}

############### JEUNES MILO ###############
variable "idp_similo_jeune_authorization_url" {
  type        = string
  default     = "https://sso-dev.i-milo.fr/auth/realms/sue-jeunes-ic0/protocol/openid-connect/auth"
  sensitive   = true
  description = "authorization_url"
}

variable "idp_similo_jeune_token_url" {
  type        = string
  default     = "https://sso-dev.i-milo.fr/auth/realms/sue-jeunes-ic0/protocol/openid-connect/token"
  sensitive   = true
  description = "token_url"
}

variable "idp_similo_jeune_logout_url" {
  type        = string
  default     = "https://sso-dev.i-milo.fr/auth/realms/sue-jeunes-ic0/protocol/openid-connect/logout"
  sensitive   = true
  description = "logout_url"
}

variable "idp_similo_jeune_enabled" {
  type        = bool
  default     = true
  description = "similo_jeune_enabled"
}

variable "idp_similo_jeune_client_secret" {
  type        = string
  default     = "NO_SECRET"
  sensitive   = true
  description = "client_secret"
}

############### CONSEILLER PE ###############
variable "idp_pe_conseiller_authorization_url" {
  type        = string
  default     = "https://authentification-agent-va.pe-qvr.net/connexion/oauth2/authorize?realm=/agent"
  sensitive   = true
  description = "authorization_url"
}

variable "idp_pe_conseiller_token_url" {
  type        = string
  default     = "https://authentification-agent-va.pe-qvr.net/connexion/oauth2/access_token?realm=/agent"
  sensitive   = true
  description = "token_url"
}

variable "idp_pe_conseiller_logout_url" {
  type        = string
  default     = "https://authentification-agent-va.pe-qvr.net/connexion/oauth2/connect/endSession?realm=/agent"
  sensitive   = true
  description = "logout_url"
}

variable "idp_pe_conseiller_client_id" {
  type        = string
  sensitive   = true
  description = "client_id"
}

variable "idp_pe_conseiller_client_secret" {
  type        = string
  sensitive   = true
  description = "client_secret"
}

variable "idp_pe_conseiller_scopes" {
  type        = string
  description = "pe_conseiller_scopes"
}

############### JEUNE PE ###############
variable "idp_pe_jeune_authorization_url" {
  type        = string
  default     = "https://authentification-candidat-r.pe-qvr.fr/connexion/oauth2/authorize?realm=%2Findividu"
  sensitive   = true
  description = "authorization_url"
}

variable "idp_pe_jeune_token_url" {
  type        = string
  default     = "https://authentification-candidat-r.pe-qvr.fr/connexion/oauth2/access_token?realm=%2Findividu"
  sensitive   = true
  description = "token_url"
}

variable "idp_pe_jeune_logout_url" {
  type        = string
  default     = "https://authentification-candidat-r.pe-qvr.fr/connexion/oauth2/connect/endSession?realm=/individu"
  sensitive   = true
  description = "logout_url"
}

variable "idp_pe_jeune_client_id" {
  type        = string
  sensitive   = true
  description = "client_id"
}

variable "idp_pe_jeune_client_secret" {
  type        = string
  sensitive   = true
  description = "client_secret"
}

variable "idp_pe_jeune_scopes" {
  type        = string
  sensitive   = true
  description = "pe_jeune_scopes"
}

############### CONSEILLER PE CEJ ###############
variable "idp_pe_cej_conseiller_enabled" {
  type        = bool
  default     = true
  description = "pe_conseiller_enabled"
}

############### JEUNE PE CEJ ###############
variable "idp_pe_cej_jeune_enabled" {
  type        = bool
  default     = true
  description = "pe_jeune_enabled"
}

############### CONSEILLER PE BRSA ###############
variable "idp_pe_brsa_conseiller_enabled" {
  type        = bool
  default     = true
  description = "pe_brsa_conseiller_enabled"
}

############### JEUNE PE BRSA ###############
variable "idp_pe_brsa_jeune_enabled" {
  type        = bool
  default     = true
  description = "pe_brsa_jeune_enabled"
}
