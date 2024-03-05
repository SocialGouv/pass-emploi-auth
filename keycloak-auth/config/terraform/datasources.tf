data "keycloak_openid_client" "realm_management" {
  realm_id  = keycloak_realm.pass-emploi.id
  client_id = "realm-management"
}
