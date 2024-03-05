package passemploi.authentication.user.repository;


import passemploi.authentication.user.authenticator.Helpers;

public class FetchUtilisateurException extends Exception {
    private final Helpers.AuthCEJErrorCode authCEJErrorCode;
    public FetchUtilisateurException(String message, Helpers.AuthCEJErrorCode authCEJErrorCode) {
        super(message);
        this.authCEJErrorCode = authCEJErrorCode;
    }

    public Helpers.AuthCEJErrorCode getAuthCEJErrorCode() {
        return this.authCEJErrorCode;
    }
}
