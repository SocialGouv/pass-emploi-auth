resource "keycloak_openid_client_scope" "pass_emploi_user_scope" {
  realm_id = keycloak_realm.pass-emploi.id
  name     = "pass-emploi-user"
}


resource "keycloak_openid_user_attribute_protocol_mapper" "user_attribute_mapper_id" {
  realm_id  = keycloak_realm.pass-emploi.id
  client_scope_id = keycloak_openid_client_scope.pass_emploi_user_scope.id
  name      = "user-attribute-mapper-id"

  user_attribute = "id_user"
  claim_name     = "userId"
}

resource "keycloak_openid_user_attribute_protocol_mapper" "user_attribute_mapper_type" {
  realm_id  = keycloak_realm.pass-emploi.id
  client_scope_id = keycloak_openid_client_scope.pass_emploi_user_scope.id
  name      = "user-attribute-mapper-type"

  user_attribute = "type"
  claim_name     = "userType"
}

resource "keycloak_openid_user_attribute_protocol_mapper" "user_attribute_mapper_structure" {
  realm_id  = keycloak_realm.pass-emploi.id
  client_scope_id = keycloak_openid_client_scope.pass_emploi_user_scope.id
  name      = "user-attribute-mapper-structure"

  user_attribute = "structure"
  claim_name     = "userStructure"
}

resource "keycloak_openid_user_attribute_protocol_mapper" "user_attribute_mapper_roles" {
  realm_id  = keycloak_realm.pass-emploi.id
  client_scope_id = keycloak_openid_client_scope.pass_emploi_user_scope.id
  name      = "user-attribute-mapper-roles"
  multivalued = true

  user_attribute = "roles"
  claim_name     = "userRoles"
}
