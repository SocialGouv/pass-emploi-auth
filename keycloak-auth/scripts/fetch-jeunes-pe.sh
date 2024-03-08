#!/usr/bin/env bash
source .env

accessToken=$(
  curl -ks --fail \
    -d "username=${KEYCLOAK_ADMIN_USER}" \
    -d "password=${KEYCLOAK_ADMIN_PASSWORD}" \
    -d "client_id=admin-cli" \
    -d "grant_type=password" \
    "${KEYCLOAK_URL}/auth/realms/master/protocol/openid-connect/token" |
    jq -r '.access_token'
)

#curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${accessToken}" \
#  "${KEYCLOAK_URL}/auth/admin/realms/${REALM}/users/count"
  

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${accessToken}" \
  "${KEYCLOAK_URL}/auth/admin/realms/${REALM}/users?max=100000&briefRepresentation=true&idpAlias=pe-jeune" > users-pe.json
