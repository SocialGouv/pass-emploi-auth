package passemploi.authentication.user.repository;

import org.apache.http.HttpResponse;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;
import org.jboss.logging.Logger;
import org.keycloak.util.JsonSerialization;
import passemploi.authentication.user.authenticator.Helpers;
import passemploi.authentication.user.model.Utilisateur;
import passemploi.authentication.user.model.UtilisateurSso;

import java.io.IOException;
import java.net.URI;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;

public class UserRepository {
  private final CloseableHttpClient httpClient;
  private final String apiBaseUrl = System.getenv("API_BASE_URL");
  private final String apiKey = System.getenv("API_KEY");
  private final Logger logger = Logger.getLogger(UserRepository.class);

  public UserRepository() {
    int timeout = 5;
    RequestConfig config = RequestConfig.custom()
        .setConnectTimeout(timeout * 1000)
        .setConnectionRequestTimeout(timeout * 1000)
        .setSocketTimeout(timeout * 1000).build();
    this.httpClient = HttpClientBuilder.create().setDefaultRequestConfig(config).build();
  }

  public Utilisateur createOrFetch(UtilisateurSso utilisateurSso, String idUtilisateur) throws FetchUtilisateurException {
    try {
      URI uri = URI.create(String.format("%s/auth/users/%s", this.apiBaseUrl, idUtilisateur));
      HttpPut httpPut = new HttpPut(uri);
      httpPut.setHeader("X-API-KEY", this.apiKey);
      String body = JsonSerialization.writeValueAsString(utilisateurSso);
      StringEntity requestEntity = new StringEntity(body, ContentType.APPLICATION_JSON);
      httpPut.setEntity(requestEntity);
      HttpResponse response = httpClient.execute(httpPut);
      if (response.getStatusLine().getStatusCode() == 200) {
        return JsonSerialization.readValue(response.getEntity().getContent(), Utilisateur.class);
      } else {
        logger.error("Une erreur est survenue lors de la récupération de l'utilisateur. Code HTTP : " + response.getStatusLine().getStatusCode());
        final String responseBody = EntityUtils.toString(response.getEntity());
        logger.error("Une erreur est survenue lors de la récupération de l'utilisateur. Message : " + responseBody);
        throw new FetchUtilisateurException("Une erreur est survenue lors de la récupération de l'utilisateur. Code HTTP : " + response.getStatusLine().getStatusCode(), this.getAuthCEJErrorCode(responseBody));
      }
    } catch (IOException e) {
      logger.error("error while fetching user: " + idUtilisateur, e);
      throw new FetchUtilisateurException("Une erreur est survenue lors de la récupération de l'utilisateur", Helpers.AuthCEJErrorCode.ERREUR_INCONNUE);
    }
  }

  private Helpers.AuthCEJErrorCode getAuthCEJErrorCode(String responseBody) {
    ObjectMapper objectMapper = new ObjectMapper();
    Helpers.AuthCEJErrorCode authCEJErrorCode = Helpers.AuthCEJErrorCode.ERREUR_INCONNUE;

    try {
    JsonNode jsonResponse = objectMapper.readTree(responseBody);
    final String errorCode = jsonResponse.get("code").asText();
    switch (errorCode) {
      case "NON_TRAITABLE":
        authCEJErrorCode = Helpers.AuthCEJErrorCode.NON_TRAITABLE;
        break;
      case "UTILISATEUR_INEXISTANT":
        authCEJErrorCode = Helpers.AuthCEJErrorCode.UTILISATEUR_INEXISTANT;
        break;
      case "UTILISATEUR_DEJA_PE":
        authCEJErrorCode = Helpers.AuthCEJErrorCode.UTILISATEUR_DEJA_PE;
        break;
      case "UTILISATEUR_DEJA_PE_BRSA":
        authCEJErrorCode = Helpers.AuthCEJErrorCode.UTILISATEUR_DEJA_PE_BRSA;
        break;
      case "UTILISATEUR_DEJA_MILO":
        authCEJErrorCode = Helpers.AuthCEJErrorCode.UTILISATEUR_DEJA_MILO;
        break;
      case "UTILISATEUR_NOUVEAU_PE":
        authCEJErrorCode = Helpers.AuthCEJErrorCode.UTILISATEUR_NOUVEAU_PE;
        break;
      case "UTILISATEUR_NOUVEAU_PE_BRSA":
        authCEJErrorCode = Helpers.AuthCEJErrorCode.UTILISATEUR_NOUVEAU_PE_BRSA;
        break;
      case "UTILISATEUR_NOUVEAU_MILO":
        authCEJErrorCode = Helpers.AuthCEJErrorCode.UTILISATEUR_NOUVEAU_MILO;
        break;
    }
    } catch (IOException e) {
      logger.warn(e.getMessage());
    }
    return authCEJErrorCode;
  }
}
