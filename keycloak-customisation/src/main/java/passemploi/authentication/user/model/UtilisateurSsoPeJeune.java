package passemploi.authentication.user.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UtilisateurSsoPeJeune {
    private String given_name;
    private String family_name;
    private String gender;
    private String idIdentiteExterne;
    private String email;
    private String sub;
    private String updated_at;
}