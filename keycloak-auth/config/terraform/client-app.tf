resource "keycloak_openid_client" "keycloak_openid_client_app" {
  realm_id = keycloak_realm.pass-emploi.id
  client_id = "pass-emploi-app"
  client_secret = var.app_client_secret

  name = "Pass Emploi APP"
  login_theme = "theme-pass-emploi-app"

  access_type = "CONFIDENTIAL"
  valid_redirect_uris = var.app_valid_redirect_uris

  standard_flow_enabled = true
  authentication_flow_binding_overrides {
    browser_id = keycloak_authentication_flow.pass-emploi-browser.id
  }
}

resource "keycloak_openid_client_default_scopes" "pass-emploi-app-default-scopes" {
  realm_id  = keycloak_realm.pass-emploi.id
  client_id = keycloak_openid_client.keycloak_openid_client_app.id

  default_scopes = [
    keycloak_openid_client_scope.pass_emploi_user_scope.name,
    "profile",
    "email",
    "openid",
    "roles"
  ]
}

