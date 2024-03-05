#!/bin/sh

set -e

KEYCLOAK_URL=${KEYCLOAK_URL:-http://localhost:8080}
KEYCLOAK_ADMIN_USER=${KEYCLOAK_ADMIN_USER:-admin}
KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD:-admin}
KEYCLOAK_CLIENT_ID=${KEYCLOAK_CLIENT_ID:-terraform}
KEYCLOAK_CLIENT_SECRET=${KEYCLOAK_CLIENT_SECRET:-111ed886-126a-11e9-ab12-23b741c9418a}

check_client_exists() {
  tokenResponse=$(curl -kv\
    -X POST \
    -d client_id=${KEYCLOAK_CLIENT_ID} \
    -d client_secret=${KEYCLOAK_CLIENT_SECRET} \
    -d grant_type=client_credentials \
    ${KEYCLOAK_URL}/auth/realms/master/protocol/openid-connect/token
  )
  errorMessage=$(echo $tokenResponse | jq -r '.error_description // empty')
  echo $errorMessage
  if test -z "${errorMessage}" ; then
    echo message is empty
    return 0
  fi
  if test "Invalid client secret" = "${errorMessage}" ; then
    echo >&2 "Client is already configured but client_secret seems to be wrong"
    exit 1
  fi
  return 1
}

if check_client_exists; then
  echo "Terraform client already exists"
  exit 0
fi

echo "Creating initial terraform client"

accessToken=$(
    curl -ks --fail \
        -d "username=${KEYCLOAK_ADMIN_USER}" \
        -d "password=${KEYCLOAK_ADMIN_PASSWORD}" \
        -d "client_id=admin-cli" \
        -d "grant_type=password" \
        "${KEYCLOAK_URL}/auth/realms/master/protocol/openid-connect/token" \
        | jq -r '.access_token'
)

post() {
    curl -ks --fail \
        -H "Authorization: bearer ${accessToken}" \
        -H "Content-Type: application/json" \
        -d "${2}" \
        "${KEYCLOAK_URL}/auth/admin${1}"
}

put() {
    curl -ks --fail \
        -X PUT \
        -H "Authorization: bearer ${accessToken}" \
        -H "Content-Type: application/json" \
        -d "${2}" \
        "${KEYCLOAK_URL}/auth/admin${1}"
}

get() {
    curl  -k --fail --silent \
        -H "Authorization: bearer ${accessToken}" \
        -H "Content-Type: application/json" \
        "${KEYCLOAK_URL}/auth/admin${1}"
}

terraformClient=$(jq -n "{
    id: \"${KEYCLOAK_CLIENT_ID}\",
    name: \"${KEYCLOAK_CLIENT_ID}\",
    secret: \"${KEYCLOAK_CLIENT_SECRET}\",
    clientAuthenticatorType: \"client-secret\",
    enabled: true,
    serviceAccountsEnabled: true,
    standardFlowEnabled: false
}")

post "/realms/master/clients" "${terraformClient}"

masterRealmAdminRole=$(get "/realms/master/roles" | jq -r '
    .
    | map(
        select(.name == "admin")
    )
    | .[0]
')
masterRealmAdminRoleId=$(echo ${masterRealmAdminRole} | jq -r '.id')

terraformClientServiceAccount=$(get "/realms/master/clients/${KEYCLOAK_CLIENT_ID}/service-account-user")
terraformClientServiceAccountId=$(echo ${terraformClientServiceAccount} | jq -r '.id')

serviceAccountAdminRoleMapping=$(jq -n "[{
    clientRole: false,
    composite: true,
    containerId: \"master\",
    description: \"\${role_admin}\",
    id: \"${masterRealmAdminRoleId}\",
    name: \"admin\",
}]")

post "/realms/master/users/${terraformClientServiceAccountId}/role-mappings/realm" "${serviceAccountAdminRoleMapping}"

echo "Done ensuring terraform client"
