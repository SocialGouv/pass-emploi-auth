resource "keycloak_realm" "pass-emploi" {
  realm                                   = "pass-emploi"
  display_name                            = "Portail de connexion"
  enabled                                 = true
  access_token_lifespan_for_implicit_flow = "30m"
  access_token_lifespan                   = "30m"
  sso_session_max_lifespan                = "1008h"
  sso_session_idle_timeout                = "504h"
  ssl_required                            = var.ssl_required
  login_theme                             = "keycloak"
  account_theme                           = "keycloak.v3"
  admin_theme                             = "keycloak.v2"
  email_theme                             = "keycloak"
  registration_allowed                    = true
  registration_email_as_username          = true
  verify_email                            = true
  login_with_email_allowed                = true
  remember_me                             = true
  reset_password_allowed                  = true
  #rules: hashAlgorithm specialChars passwordHistory upperCase lowerCase regexPattern digits notUsername forceExpiredPasswordChange hashIterations passwordBlacklist length
  # https://github.com/keycloak/keycloak/blob/main/docs/documentation/server_admin/topics/authentication/password-policies.adoc
  internationalization {
    supported_locales = [
      "fr"
    ]
    default_locale = "fr"
  }

  smtp_server {
    from              = "enregistrement@pass-emploi.beta.gouv.fr"
    host              = "ssl0.ovh.net"
    port              = "465"
    from_display_name = "Pass Emploi"
    ssl               = true
    auth {
      username = "enregistrement@pass-emploi.beta.gouv.fr"
      password = var.smtp_email_password
    }
  }

  security_defenses {
    brute_force_detection {
      permanent_lockout                = false
      max_login_failures               = 5
      wait_increment_seconds           = 60 * 10
      quick_login_check_milli_seconds  = 1000
      minimum_quick_login_wait_seconds = 60
      max_failure_wait_seconds         = 60 * 60 * 24
      failure_reset_time_seconds       = 60 * 60 * 24 * 7
    }
  }
}

resource "keycloak_realm_events" "realm_events" {
  realm_id                     = keycloak_realm.pass-emploi.id
  events_enabled               = true
  enabled_event_types          = []
  admin_events_enabled         = true
  admin_events_details_enabled = true
  events_expiration            = 60 * 60 * 24 * 90 //90 jours
}
