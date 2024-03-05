resource "keycloak_user" "user_nils_tavernier" {
  realm_id   = keycloak_realm.pass-emploi.id
  enabled    = true
  first_name = "Nils"
  last_name  = "Tavernier"
  email      = ""
  username   = "41"
  attributes = {
    id_user = "41",
    type = "CONSEILLER",
    structure = "PASS_EMPLOI"
  }
  initial_password {
    value = "41"
  }
}

resource "keycloak_user" "user_virginie_renoux" {
  realm_id   = keycloak_realm.pass-emploi.id
  enabled    = true
  first_name = "Virginie"
  last_name  = "Renoux"
  email      = ""
  username   = "42"
  attributes = {
    id_user = "42",
    type = "CONSEILLER",
    structure = "PASS_EMPLOI"
  }
  initial_password {
    value = "42"
  }
}

resource "keycloak_user" "user_kenji_lefameux" {
  realm_id   = keycloak_realm.pass-emploi.id
  enabled    = true
  first_name = "Kenji"
  last_name  = "Lefameux"
  email      = ""
  username   = "1"
  attributes = {
    id_user = "1",
    type = "JEUNE",
    structure = "PASS_EMPLOI"
  }
  initial_password {
    value = "1"
  }
}

resource "keycloak_user" "user_deployeur" {
  realm_id   = keycloak_realm.pass-emploi.id
  enabled    = true
  first_name = "Le"
  last_name  = "Deployeur"
  email      = ""
  username   = "deployeur"
  attributes = {
    type = "SUPPORT",
    structure = "PASS_EMPLOI"
  }
  initial_password {
    value = "deployeur"
  }
}
