resource "keycloak_openid_client" "keycloak_openid_client_api" {
  realm_id      = keycloak_realm.pass-emploi.id
  client_id     = "pass-emploi-api"
  client_secret = var.api_client_secret

  name = "Pass Emploi API"

  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true
}

resource "keycloak_openid_client_service_account_role" "keycloak_openid_client_api_role_manage_users" {
  realm_id                = keycloak_realm.pass-emploi.id
  service_account_user_id = keycloak_openid_client.keycloak_openid_client_api.service_account_user_id
  client_id               = data.keycloak_openid_client.realm_management.id
  role                    = "manage-users"
}


