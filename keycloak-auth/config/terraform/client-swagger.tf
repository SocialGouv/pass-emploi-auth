resource "keycloak_openid_client" "keycloak_openid_client_swagger" {
  realm_id = keycloak_realm.pass-emploi.id
  client_id = "pass-emploi-swagger"
  client_secret = var.app_client_secret

  name = "Pass Emploi Swagger"

  access_type = "PUBLIC"
  valid_redirect_uris = var.swagger_valid_redirect_uris

  implicit_flow_enabled = true
  authentication_flow_binding_overrides {
    browser_id = keycloak_authentication_flow.pass-emploi-browser.id
  }
}

resource "keycloak_openid_client_default_scopes" "pass-emploi-swagger-default-scopes" {
  realm_id  = keycloak_realm.pass-emploi.id
  client_id = keycloak_openid_client.keycloak_openid_client_swagger.id

  default_scopes = [
    keycloak_openid_client_scope.pass_emploi_user_scope.name,
    "roles",
    "profile",
    "email",
    "openid"
  ]
}

