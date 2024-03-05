resource "keycloak_openid_client" "keycloak_openid_client_web" {
  realm_id = keycloak_realm.pass-emploi.id
  client_id = "pass-emploi-web"
  client_secret = var.web_client_secret

  name = "Pass Emploi WEB"
  login_theme = "theme-pass-emploi-web"

  access_type = "CONFIDENTIAL"
  valid_redirect_uris = var.web_valid_redirect_uris
  
  standard_flow_enabled = true
  authentication_flow_binding_overrides {
    browser_id = keycloak_authentication_flow.pass-emploi-browser.id
  }
}

resource "keycloak_openid_client_default_scopes" "pass-emploi-web-default-scopes" {
  realm_id  = keycloak_realm.pass-emploi.id
  client_id = keycloak_openid_client.keycloak_openid_client_web.id

  default_scopes = [
    keycloak_openid_client_scope.pass_emploi_user_scope.name,
    "roles",
    "profile",
    "email",
    "openid"
  ]
}

