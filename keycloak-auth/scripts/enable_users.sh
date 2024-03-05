#!/usr/bin/env bash
source .env

accessToken=$(
    curl -ks --fail \
        -d "username=${KEYCLOAK_ADMIN_USER}" \
        -d "password=${KEYCLOAK_ADMIN_PASSWORD}" \
        -d "client_id=admin-cli" \
        -d "grant_type=password" \
        "${KEYCLOAK_URL}/auth/realms/master/protocol/openid-connect/token" \
        | jq -r '.access_token'
    )

function enableUser() {
    local userId=$1
    curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer ${accessToken}" \
    --data "{\"enabled\": true}" \
    "${KEYCLOAK_URL}/auth/admin/realms/${REALM}/users/${userId}"
}

while read userId; do
  enableUser $userId
done <users_to_enable
