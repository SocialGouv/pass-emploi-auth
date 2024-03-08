// l'utilisation de depends_on permet d'assurer les priorités du flow car l'API de keycloak ne le permet pas
// la priorité est assurée par l'ordre de création
// source --> https://github.com/mrparkers/terraform-provider-keycloak/issues/296

########### BROWSER ###########
resource "keycloak_authentication_flow" "pass-emploi-browser" {
  realm_id    = keycloak_realm.pass-emploi.id
  alias       = "pass-emploi-browser"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_subflow" "pass-emploi-browser-authentication" {
  depends_on        = [keycloak_authentication_flow.pass-emploi-browser]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_flow.pass-emploi-browser.alias
  alias             = "pass-emploi-browser-authentication"
  provider_id       = "basic-flow"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_execution" "pass-emploi-browser-cookie-execution" {
  depends_on        = [keycloak_authentication_subflow.pass-emploi-browser-authentication]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_subflow.pass-emploi-browser-authentication.alias
  requirement       = "ALTERNATIVE"
  authenticator     = "auth-cookie"
}

resource "keycloak_authentication_execution" "pass-emploi-browser-idp-redirector-execution" {
  depends_on        = [keycloak_authentication_execution.pass-emploi-browser-cookie-execution]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_subflow.pass-emploi-browser-authentication.alias
  requirement       = "ALTERNATIVE"
  authenticator     = "identity-provider-redirector"
}

resource "keycloak_authentication_subflow" "pass-emploi-browser-authentication-form" {
  depends_on        = [keycloak_authentication_execution.pass-emploi-browser-idp-redirector-execution]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_subflow.pass-emploi-browser-authentication.alias
  alias             = "pass-emploi-browser-authentication-form"
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
}

resource "keycloak_authentication_execution" "pass-emploi-browser-username-password-execution" {
  depends_on        = [keycloak_authentication_subflow.pass-emploi-browser-authentication-form]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_subflow.pass-emploi-browser-authentication-form.alias
  requirement       = "REQUIRED"
  authenticator     = "auth-username-password-form"
}

resource "keycloak_authentication_execution" "pass-emploi-custom-execution" {
  depends_on        = [keycloak_authentication_subflow.pass-emploi-browser-authentication-form, keycloak_authentication_execution.pass-emploi-browser-username-password-execution]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_subflow.pass-emploi-browser-authentication-form.alias
  requirement       = "REQUIRED"
  authenticator     = "user-authenticator-pass-emploi"
}


########### IDP ###########
########### CONSEILLER MILO ###########
resource "keycloak_authentication_flow" "pass-emploi-idp-conseiller-milo" {
  realm_id    = keycloak_realm.pass-emploi.id
  alias       = "pass-emploi-idp-conseiller"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_execution" "pass-emploi-idp-conseiller-milo-execution" {
  depends_on        = [keycloak_authentication_flow.pass-emploi-idp-conseiller-milo]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_flow.pass-emploi-idp-conseiller-milo.alias
  requirement       = "REQUIRED"
  authenticator     = "user-authenticator-conseiller-milo"
}

########### JEUNE MILO ###########
resource "keycloak_authentication_flow" "pass-emploi-idp-jeune-milo" {
  realm_id    = keycloak_realm.pass-emploi.id
  alias       = "pass-emploi-idp-jeune"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_execution" "pass-emploi-idp-jeune-execution" {
  depends_on        = [keycloak_authentication_flow.pass-emploi-idp-jeune-milo]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_flow.pass-emploi-idp-jeune-milo.alias
  requirement       = "REQUIRED"
  authenticator     = "user-authenticator-jeune-milo"
}

########### CONSEILLER PE ###########
resource "keycloak_authentication_flow" "pass-emploi-idp-conseiller-pe" {
  realm_id    = keycloak_realm.pass-emploi.id
  alias       = "pass-emploi-idp-conseiller-pe"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_execution" "pass-emploi-idp-conseiller-pe-execution" {
  depends_on        = [keycloak_authentication_flow.pass-emploi-idp-conseiller-pe]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_flow.pass-emploi-idp-conseiller-pe.alias
  requirement       = "REQUIRED"
  authenticator     = "user-authenticator-conseiller-pe"
}
########### JEUNE PE ###########
resource "keycloak_authentication_flow" "pass-emploi-idp-jeune-pe" {
  realm_id    = keycloak_realm.pass-emploi.id
  alias       = "pass-emploi-idp-jeune-pe"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_execution" "pass-emploi-idp-jeune-pe-execution" {
  depends_on        = [keycloak_authentication_flow.pass-emploi-idp-jeune-pe]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_flow.pass-emploi-idp-jeune-pe.alias
  requirement       = "REQUIRED"
  authenticator     = "user-authenticator-jeune-pe"
}

########### CONSEILLER PE BRSA ###########
resource "keycloak_authentication_flow" "pass-emploi-idp-conseiller-pe-brsa" {
  realm_id    = keycloak_realm.pass-emploi.id
  alias       = "pass-emploi-idp-conseiller-pe-brsa"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_execution" "pass-emploi-idp-conseiller-pe-brsa-execution" {
  depends_on        = [keycloak_authentication_flow.pass-emploi-idp-conseiller-pe-brsa]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_flow.pass-emploi-idp-conseiller-pe-brsa.alias
  requirement       = "REQUIRED"
  authenticator     = "user-authenticator-cons-pe-brsa"
}
########### JEUNE PE BRSA ###########
resource "keycloak_authentication_flow" "pass-emploi-idp-jeune-pe-brsa" {
  realm_id    = keycloak_realm.pass-emploi.id
  alias       = "pass-emploi-idp-jeune-pe-brsa"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_execution" "pass-emploi-idp-jeune-pe-brsa-execution" {
  depends_on        = [keycloak_authentication_flow.pass-emploi-idp-jeune-pe-brsa]
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = keycloak_authentication_flow.pass-emploi-idp-jeune-pe-brsa.alias
  requirement       = "REQUIRED"
  authenticator     = "user-authenticator-jeune-pe-brsa"
}

########### FIRST BROKER LOGIN ###########
data "keycloak_authentication_execution" "first_broker_login_review_profile_execution" {
  realm_id          = keycloak_realm.pass-emploi.id
  parent_flow_alias = "first broker login"
  provider_id       = "idp-review-profile"
}

resource "keycloak_authentication_execution_config" "first_broker_login_review_profile_config" {
  realm_id     = keycloak_realm.pass-emploi.id
  execution_id = data.keycloak_authentication_execution.first_broker_login_review_profile_execution.id
  alias        = "review profile config"
  config = {
    "update.profile.on.first.login" = "off"
  }
}
