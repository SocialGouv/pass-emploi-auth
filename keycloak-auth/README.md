### Packaging
Keycloak est packagé dans un custom buildpack pour Scalingo

### Config
Keycloak est configuré via un provider terraform

### Poste local

1. Récupérer les password des vault de stagin et de prod dans Dashlane
2. Mettre le password dans `config/vault/vault-<env>.secret`
3. Déchiffrer le vault

```
cd config/vault
make run-vault
make decrypt-staging-f
```

2. Générer le fichier `.env` à partir du `.env.template`
3. Créer un fichier local.secret dans le dossier vault avec TF_VAR_idp_pe_jeune_client_secret

4. Lancer le tout

```
make start #lance keycloak avec son postgres et applique la configuration terraform
make clean #supprime tous les volumes et images
```

#### Utiliser le SSO PE Jeune
Les redirect URL du SSO PE Jeune ne permettent pas de travailler en local.
Afin de quand même l'utiliser on peut utiliser l'astuce suivante :

1. Éditer le fichier /etc/hosts en ajoutant la ligne suivante :
```bash
127.0.0.1	id.pass-emploi.incubateur.net
```

2. Dans le web et l'api mettre les variables suivantes
```bash
#API
OIDC_ISSUER_URL=http://id.pass-emploi.incubateur.net:8082/auth/realms/pass-emploi

#WEB
KEYCLOAK_ISSUER=http://id.pass-emploi.incubateur.net:8082/auth/realms/pass-emploi
```

### Déploiement sur Scalingo

1. Créer une application sur Scalingo
2. Ajouter l'addon postgres
3. Ajouter la variable d'environnement `BUILDPACK_URL=https://github.com/SocialGouv/pass-emploi-auth#main`
4. Ajiuter toutes les variables dans scalingo du fichier `.env.template` avec les bonnes valeurs
5. Lancer un déploiement manuel

### Appliquer la configuration du keycloak sur un env de scalingo

1. Lancer le tunnel ssh vers la db `tf_state`. Cette db permet de sauvegarder le tfstate.  

`scalingo --region osc-secnum-fr1 -a pa-tfstate db-tunnel -p 10030 SCALINGO_POSTGRESQL_URL`
> Il y a un schema par environnement. (staging & prod)
2. Déchiffrer le vault correspondant à l'environnement souhaité
```
cd config/vault
make run-vault
make decrypt-staging
```
3. Lancer le provisionning de l'environnement depuis la racine
`make provision-staging`


> Pour mettre à jour les secrets: `make edit-staging`
