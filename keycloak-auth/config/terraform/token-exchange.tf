resource "keycloak_identity_provider_token_exchange_scope_permission" "token_exchange_pe_jeune_api" {
  realm_id       = keycloak_realm.pass-emploi.id
  provider_alias = keycloak_oidc_identity_provider.idp_pe_jeune.alias
  policy_type    = "client"
  clients = [
    keycloak_openid_client.keycloak_openid_client_api.id
  ]
}
resource "keycloak_identity_provider_token_exchange_scope_permission" "token_exchange_milo_conseiller_api" {
  realm_id       = keycloak_realm.pass-emploi.id
  provider_alias = keycloak_oidc_identity_provider.idp_milo_conseiller.alias
  policy_type    = "client"
  clients = [
    keycloak_openid_client.keycloak_openid_client_api.id
  ]
}
resource "keycloak_identity_provider_token_exchange_scope_permission" "token_exchange_pe_brsa_jeune_api" {
  realm_id       = keycloak_realm.pass-emploi.id
  provider_alias = keycloak_oidc_identity_provider.idp_pe_brsa_jeune.alias
  policy_type    = "client"
  clients = [
    keycloak_openid_client.keycloak_openid_client_api.id
  ]
}
resource "keycloak_identity_provider_token_exchange_scope_permission" "token_exchange_milo_jeune_api" {
  realm_id       = keycloak_realm.pass-emploi.id
  provider_alias = keycloak_oidc_identity_provider.idp_milo_jeune.alias
  policy_type    = "client"
  clients = [
    keycloak_openid_client.keycloak_openid_client_api.id
  ]
}
