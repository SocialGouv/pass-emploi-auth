package passemploi.authentication.user.authenticator;

import org.jboss.logging.Logger;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.Authenticator;
import org.keycloak.broker.provider.IdentityBrokerException;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import passemploi.authentication.user.model.Structure;
import passemploi.authentication.user.model.Type;
import passemploi.authentication.user.model.Utilisateur;
import passemploi.authentication.user.model.UtilisateurSso;
import passemploi.authentication.user.repository.FetchUtilisateurException;
import passemploi.authentication.user.repository.UserRepository;

import java.util.List;

public class SsoMiloAuthenticator implements Authenticator {
    protected static final Logger logger = Logger.getLogger(SsoMiloAuthenticator.class);
    private final UserRepository userRepository;
    private final Structure structure;
    private final Type type;

    public SsoMiloAuthenticator(Structure structure, Type type) {
        this.structure = structure;
        this.type = type;
        userRepository = new UserRepository(System.getenv("API_BASE_URL"));
    }

    @Override
    public void authenticate(AuthenticationFlowContext context) {
        try {
            String tokenFirstName = context.getUser().getFirstAttribute("firstName");
            String tokenLastName = context.getUser().getFirstAttribute("lastName");
            String tokenEmail = context.getUser().getFirstAttribute("email");
            UtilisateurSso utilisateurSso = new UtilisateurSso(tokenFirstName, tokenLastName, tokenEmail, this.structure, this.type);
            Utilisateur utilisateur = userRepository.createOrFetch(utilisateurSso, context.getUser().getFirstAttribute("idMilo"));
            context.getUser().setAttribute("id_user", List.of(utilisateur.getId()));
            context.getUser().setAttribute("type", List.of(utilisateur.getType().toString()));
            context.getUser().setAttribute("structure", List.of(utilisateur.getStructure().toString()));
            context.getUser().setEmail(utilisateur.getEmail());
            context.getUser().setFirstName(utilisateur.getPrenom());
            context.getUser().setLastName(utilisateur.getNom());
        } catch (FetchUtilisateurException e) {
            logger.error(e.getMessage());
            throw new IdentityBrokerException(e.getMessage());
        }
        context.success();

    }


    @Override
    public void action(AuthenticationFlowContext context) {
    }

    @Override
    public void close() {
    }

    @Override
    public boolean requiresUser() {
        return true;
    }

    @Override
    public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
        return true;
    }


    @Override
    public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
    }
}