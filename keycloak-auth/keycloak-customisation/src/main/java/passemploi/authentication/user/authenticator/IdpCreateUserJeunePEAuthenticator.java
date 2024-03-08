package passemploi.authentication.user.authenticator;

import org.jboss.logging.Logger;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.authenticators.broker.AbstractIdpAuthenticator;
import org.keycloak.authentication.authenticators.broker.util.ExistingUserInfo;
import org.keycloak.authentication.authenticators.broker.util.SerializedBrokeredIdentityContext;
import org.keycloak.broker.provider.BrokeredIdentityContext;
import org.keycloak.events.Details;
import org.keycloak.events.Errors;
import org.keycloak.models.AuthenticatorConfigModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.services.ServicesLogger;
import org.keycloak.services.messages.Messages;
import passemploi.authentication.user.factory.IdpCreateUserJeunePEAuthenticatorFactory;

import javax.ws.rs.core.Response;
import java.util.List;
import java.util.Map;

public class IdpCreateUserJeunePEAuthenticator extends AbstractIdpAuthenticator {

    private static Logger logger = Logger.getLogger(IdpCreateUserJeunePEAuthenticator.class);


    @Override
    protected void actionImpl(AuthenticationFlowContext context, SerializedBrokeredIdentityContext serializedCtx, BrokeredIdentityContext brokerContext) {
    }

    @Override
    protected void authenticateImpl(AuthenticationFlowContext context, SerializedBrokeredIdentityContext serializedCtx, BrokeredIdentityContext brokerContext) {

        KeycloakSession session = context.getSession();
        RealmModel realm = context.getRealm();

        if (context.getAuthenticationSession().getAuthNote(EXISTING_USER_INFO) != null) {
            context.attempted();
            return;
        }

        String username = getUsername(context, serializedCtx, brokerContext);
        if (username == null) {
            ServicesLogger.LOGGER.resetFlow(realm.isRegistrationEmailAsUsername() ? "Email" : "Username");
            context.getAuthenticationSession().setAuthNote(ENFORCE_UPDATE_PROFILE, "true");
            context.resetFlow();
            return;
        }

        ExistingUserInfo duplication = checkExistingUserAndDeleteIfPEJeuneBRSA(context, username, serializedCtx, brokerContext, session);

        if (duplication == null) {
            logger.infof("No duplication detected. Creating account for user '%s' and linking with identity provider '%s' .",
                    username, brokerContext.getIdpConfig().getAlias());

            UserModel federatedUser = session.users().addUser(realm, username);
            federatedUser.setEnabled(true);

            for (Map.Entry<String, List<String>> attr : serializedCtx.getAttributes().entrySet()) {
                if (!UserModel.USERNAME.equalsIgnoreCase(attr.getKey())) {
                    federatedUser.setAttribute(attr.getKey(), attr.getValue());
                }
            }

            AuthenticatorConfigModel config = context.getAuthenticatorConfig();
            if (config != null && Boolean.parseBoolean(config.getConfig().get(IdpCreateUserJeunePEAuthenticatorFactory.REQUIRE_PASSWORD_UPDATE_AFTER_REGISTRATION))) {
                logger.debugf("User " + federatedUser.getUsername() + " required to update password");
                federatedUser.addRequiredAction(UserModel.RequiredAction.UPDATE_PASSWORD);
            }

            userRegisteredSuccess(context, federatedUser, serializedCtx, brokerContext);

            context.setUser(federatedUser);
            context.getAuthenticationSession().setAuthNote(BROKER_REGISTERED_NEW_USER, "true");
            context.success();
        } else {
            logger.warnf("Duplication detected. There is already existing user with %s '%s' .",
                    duplication.getDuplicateAttributeName(), duplication.getDuplicateAttributeValue());
            
            // Set duplicated user, so next authenticators can deal with it
            context.getAuthenticationSession().setAuthNote(EXISTING_USER_INFO, duplication.serialize());
            
            //Only show error message if the authenticator was required
            if (context.getExecution().isRequired()) {
                Response challengeResponse = context.form()
                        .setError(Messages.FEDERATED_IDENTITY_EXISTS, duplication.getDuplicateAttributeName(), duplication.getDuplicateAttributeValue())
                        .createErrorPage(Response.Status.CONFLICT);
                context.challenge(challengeResponse);
                context.getEvent()
                        .user(duplication.getExistingUserId())
                        .detail("existing_" + duplication.getDuplicateAttributeName(), duplication.getDuplicateAttributeValue())
                        .removeDetail(Details.AUTH_METHOD)
                        .removeDetail(Details.AUTH_TYPE)
                        .error(Errors.FEDERATED_IDENTITY_EXISTS);
            } else {
                context.attempted();
            }
        }
    }

    protected ExistingUserInfo checkExistingUserAndDeleteIfPEJeuneBRSA(AuthenticationFlowContext context, String username, SerializedBrokeredIdentityContext serializedCtx, BrokeredIdentityContext brokerContext, KeycloakSession session) {
        UserModel existingUser;
        String existingUserModel;
        String existingUserAttribute;

        if (brokerContext.getEmail() != null && !context.getRealm().isDuplicateEmailsAllowed()) {
            existingUser = context.getSession().users().getUserByEmail(context.getRealm(), brokerContext.getEmail());
            existingUserModel = UserModel.EMAIL;
        } else {
            existingUser = context.getSession().users().getUserByUsername(context.getRealm(), username);
            existingUserModel = UserModel.USERNAME;
        }

        if (existingUser == null) {
            return null;
        }
        existingUserAttribute = existingUserModel.equals(UserModel.EMAIL) ? existingUser.getEmail() : existingUser.getUsername();

        // check si c'est le meme idp entre l'utilisateur qui veut se connecter et l'existant
        String structureUtilisateurExistant = existingUser.getFirstAttribute("structure");
        String idpUtilisateurQuiSeConnecte = brokerContext.getIdpConfig().getAlias();
        if (suppressionPossibleDuJeunePE(structureUtilisateurExistant, idpUtilisateurQuiSeConnecte)) {
            logger.warnf("Deleting duplicated user %s .", existingUserAttribute);
            session.userLocalStorage().removeUser(context.getRealm(), existingUser);
            return null;
        }

        return new ExistingUserInfo(existingUser.getId(), existingUserModel, existingUserAttribute);
    }

    protected Boolean suppressionPossibleDuJeunePE(String structure, String idp) {
        String idpPEJeune = "pe-jeune";
        String idpPEBRSA = "pe-brsa-jeune";
        String structurePE = "POLE_EMPLOI";
        String structurePEBRSA = "POLE_EMPLOI_BRSA";

        Boolean jeunePEVeutSeReconnecter = structure.equals(structurePE) && idp.equals(idpPEJeune);
        Boolean BRSAVeutSeReconnecter = structure.equals(structurePEBRSA) && idp.equals(idpPEBRSA);
        return jeunePEVeutSeReconnecter || BRSAVeutSeReconnecter;
    }

    protected String getUsername(AuthenticationFlowContext context, SerializedBrokeredIdentityContext serializedCtx, BrokeredIdentityContext brokerContext) {
        RealmModel realm = context.getRealm();
        return realm.isRegistrationEmailAsUsername() ? brokerContext.getEmail() : brokerContext.getModelUsername();
    }


    // Empty method by default. This exists, so subclass can override and add callback after new user is registered through social
    protected void userRegisteredSuccess(AuthenticationFlowContext context, UserModel registeredUser, SerializedBrokeredIdentityContext serializedCtx, BrokeredIdentityContext brokerContext) {

    }


    @Override
    public boolean requiresUser() {
        return false;
    }

    @Override
    public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
        return true;
    }

}
