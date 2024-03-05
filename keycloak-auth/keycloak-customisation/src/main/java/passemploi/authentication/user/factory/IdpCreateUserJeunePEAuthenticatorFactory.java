package passemploi.authentication.user.factory;

import org.keycloak.Config;
import org.keycloak.authentication.Authenticator;
import org.keycloak.authentication.AuthenticatorFactory;
import org.keycloak.models.AuthenticationExecutionModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;
import org.keycloak.provider.ProviderConfigProperty;
import passemploi.authentication.user.authenticator.IdpCreateUserJeunePEAuthenticator;

import java.util.ArrayList;
import java.util.List;

public class IdpCreateUserJeunePEAuthenticatorFactory implements AuthenticatorFactory {

    public static final String PROVIDER_ID = "idp-create-user-jeune-pe-brsa";
    static IdpCreateUserJeunePEAuthenticator SINGLETON = new IdpCreateUserJeunePEAuthenticator();

    public static final String REQUIRE_PASSWORD_UPDATE_AFTER_REGISTRATION = "require.password.update.after.registration";

    @Override
    public Authenticator create(KeycloakSession session) {
        return SINGLETON;
    }

    @Override
    public void init(Config.Scope config) {

    }

    @Override
    public void postInit(KeycloakSessionFactory factory) {

    }

    @Override
    public void close() {

    }

    @Override
    public String getId() {
        return PROVIDER_ID;
    }

    @Override
    public String getReferenceCategory() {
        return "createUserIfJeunePEBRSA";
    }

    @Override
    public boolean isConfigurable() {
        return true;
    }

    @Override
    public AuthenticationExecutionModel.Requirement[] getRequirementChoices() {
        return REQUIREMENT_CHOICES;
    }

    @Override
    public String getDisplayType() {
        return "Create User If Unique Jeune PE / BRSA";
    }

    @Override
    public String getHelpText() {
        return "Detect if there is existing Keycloak account with same email like Jeune PE / BRSA identity provider. If yes, recreate the user. If no, create new user.";
    }

    @Override
    public boolean isUserSetupAllowed() {
        return false;
    }

    private static final List<ProviderConfigProperty> configProperties = new ArrayList<ProviderConfigProperty>();

    @Override
    public List<ProviderConfigProperty> getConfigProperties() {
        return configProperties;
    }
}