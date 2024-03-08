package passemploi.authentication.user.authenticator;

import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.AuthenticationFlowError;
import org.keycloak.authentication.authenticators.broker.AbstractIdpAuthenticator;
import org.keycloak.authentication.authenticators.broker.util.PostBrokerLoginConstants;
import org.keycloak.authentication.authenticators.broker.util.SerializedBrokeredIdentityContext;
import org.keycloak.broker.provider.BrokeredIdentityContext;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.KeycloakSession;
import org.keycloak.representations.AccessTokenResponse;
import passemploi.authentication.user.model.Utilisateur;

import javax.ws.rs.core.Response;

import static org.keycloak.broker.oidc.OIDCIdentityProvider.FEDERATED_ACCESS_TOKEN_RESPONSE;

public class Helpers {
  public enum AuthCEJErrorCode {
    ERREUR_INCONNUE, NON_TRAITABLE, UTILISATEUR_INEXISTANT, UTILISATEUR_DEJA_PE, UTILISATEUR_DEJA_PE_BRSA, UTILISATEUR_DEJA_MILO, UTILISATEUR_NOUVEAU_PE, UTILISATEUR_NOUVEAU_PE_BRSA, UTILISATEUR_NOUVEAU_MILO
  }

  public enum Idp {
    POLE_EMPLOI, POLE_EMPLOI_BRSA
  }
  public enum UtilisateurInconnuMessage {
    JEUNE_PE_INCONNU("passJeunePEInconnu"),
    UTILISATEUR_PASS_EMPLOI_INCONNU("passUtilisateurInconnu"),
    JEUNE_INEXISTANT("jeuneInexistant"),
    JEUNE_DEJA_PE_IDP_PE_BRSA("jeuneDejaPEIdpPEBRSA"),
    JEUNE_DEJA_PE_BRSA("jeuneDejaPEBRSA"),
    JEUNE_DEJA_MILO_IDP_PE("jeuneDejaMiloIdpPE"),
    JEUNE_DEJA_MILO_IDP_PE_BRSA("jeuneDejaMiloIdpPEBRSA"),
    JEUNE_NOUVEAU_PE_IDP_PE_BRSA("jeuneNouveauPEIdpPEBRSA"),
    JEUNE_NOUVEAU_PE_BRSA("jeuneNouveauPEBRSA"),
    JEUNE_NOUVEAU_MILO_IDP_PE("jeuneNouveauMiloIdpPE"),
    JEUNE_NOUVEAU_MILO_IDP_PE_BRSA("jeuneNouveauMiloIdpPEBRSA");


    public final String value;

    UtilisateurInconnuMessage(String value) {
      this.value = value;
    }
  }

  static public void utilisateurInconnuRedirect(AuthenticationFlowContext context, UtilisateurInconnuMessage utilisateurInconnuMessage) {
    LoginFormsProvider form = context.form();
    form.setAttribute("utilisateurInconnu", true);
    form.setAttribute("passMessage", utilisateurInconnuMessage.value);
    Response response = form.createForm("utilisateur-inconnu.ftl");
    context.failure(AuthenticationFlowError.INVALID_USER, response);
  }

  static public AccessTokenResponse getFederatedAccessTokenResponse(AuthenticationFlowContext context) {
    SerializedBrokeredIdentityContext serializedCtx = SerializedBrokeredIdentityContext.readFromAuthenticationSession(context.getAuthenticationSession(), AbstractIdpAuthenticator.BROKERED_CONTEXT_NOTE);
    if (serializedCtx == null) {
      // get the identity context for post login flow
      serializedCtx = SerializedBrokeredIdentityContext.readFromAuthenticationSession(context.getAuthenticationSession(), PostBrokerLoginConstants.PBL_BROKERED_IDENTITY_CONTEXT);
    }
    BrokeredIdentityContext brokerContext = serializedCtx.deserialize(context.getSession(), context.getAuthenticationSession());
    AccessTokenResponse tokenResponse = (AccessTokenResponse) brokerContext.getContextData().get(FEDERATED_ACCESS_TOKEN_RESPONSE);
    return tokenResponse;
  }

  public static void setContextPostLogin(AuthenticationFlowContext context, Utilisateur utilisateur) {
    context.getUser().setSingleAttribute("id_user", utilisateur.getId());
    context.getUser().setSingleAttribute("type", utilisateur.getType().toString());
    context.getUser().setSingleAttribute("structure", utilisateur.getStructure().toString());
    context.getUser().setAttribute("roles", utilisateur.getRoles());
    context.getUser().setEmail(utilisateur.getEmail());
    context.getUser().setFirstName(utilisateur.getPrenom());
    context.getUser().setLastName(utilisateur.getNom());
  }

  public static void supprimerUtilisateurSelonErreur(AuthCEJErrorCode errorCode, AuthenticationFlowContext context, KeycloakSession session) {
    if (session == null) {
      return;
    }
    if (errorCode == AuthCEJErrorCode.UTILISATEUR_INEXISTANT || errorCode == AuthCEJErrorCode.UTILISATEUR_NOUVEAU_MILO || errorCode == AuthCEJErrorCode.UTILISATEUR_NOUVEAU_PE || errorCode == AuthCEJErrorCode.UTILISATEUR_NOUVEAU_PE_BRSA) {
      session.userLocalStorage().removeUser(context.getRealm(), context.getUser());
    }
  }

  public static UtilisateurInconnuMessage getMessageSelonErreur(AuthCEJErrorCode errorCode, Idp idp) {
    switch (errorCode) {
      case UTILISATEUR_INEXISTANT:
        return Helpers.UtilisateurInconnuMessage.JEUNE_INEXISTANT;
      case UTILISATEUR_NOUVEAU_PE: {
        if (idp == Idp.POLE_EMPLOI_BRSA) return Helpers.UtilisateurInconnuMessage.JEUNE_NOUVEAU_PE_IDP_PE_BRSA;
      }
      case UTILISATEUR_NOUVEAU_PE_BRSA:
        return Helpers.UtilisateurInconnuMessage.JEUNE_NOUVEAU_PE_BRSA;
      case UTILISATEUR_NOUVEAU_MILO: {
        if (idp == Idp.POLE_EMPLOI) return Helpers.UtilisateurInconnuMessage.JEUNE_NOUVEAU_MILO_IDP_PE;
        if (idp == Idp.POLE_EMPLOI_BRSA) return Helpers.UtilisateurInconnuMessage.JEUNE_NOUVEAU_MILO_IDP_PE_BRSA;
      }
      case UTILISATEUR_DEJA_PE: {
        if (idp == Idp.POLE_EMPLOI_BRSA) return Helpers.UtilisateurInconnuMessage.JEUNE_DEJA_PE_IDP_PE_BRSA;
      }
      case UTILISATEUR_DEJA_PE_BRSA:
        return Helpers.UtilisateurInconnuMessage.JEUNE_DEJA_PE_BRSA;
      case UTILISATEUR_DEJA_MILO: {
        if (idp == Idp.POLE_EMPLOI) return Helpers.UtilisateurInconnuMessage.JEUNE_DEJA_MILO_IDP_PE;
        if (idp == Idp.POLE_EMPLOI_BRSA) return Helpers.UtilisateurInconnuMessage.JEUNE_DEJA_MILO_IDP_PE_BRSA;
      }
      default:
        return Helpers.UtilisateurInconnuMessage.JEUNE_PE_INCONNU;
    }
  }
}
