SHELL=/bin/sh
.SHELLFLAGS = -e -c
.ONESHELL:

TFSTATE_PATH?=terraform.tfstate

apply: check-config terraform-client terraform-apply
apply-local: check-config-local terraform-client terraform-apply-local

destroy: check-config terraform-client terraform-destroy
destroy-local: check-config-local terraform-client terraform-destroy

terraform-apply-local:
	terraform init
	terraform plan -state=${TFSTATE_PATH} -var ssl_required=none
	terraform apply -state=${TFSTATE_PATH} -auto-approve -input=false -var ssl_required=none

terraform-destroy:
	terraform init -input=false
	terraform destroy -auto-approve -input=false

terraform-client:
	./scripts/ensure-terraform-client.sh

check-config-local:
	@test -n "${KEYCLOAK_URL}" || (echo >&2 KEYCLOAK_URL needs to be set && false)
	@test -n "${KEYCLOAK_CLIENT_ID}" || (echo >&2 KEYCLOAK_CLIENT_ID needs to be set && false)
	@test -n "${KEYCLOAK_CLIENT_SECRET}" || (echo >&2 KEYCLOAK_CLIENT_SECRET needs to be set && false)

terraform-delete-state: terraform-init
	@if terraform state list ; then \
		terraform state list | cut -f 1 -d '[' | xargs -I '{}' terraform state rm {} ; \
	else \
		echo 'no state to delete'; \
	fi

terraform-init:
	@if [ "${BACKEND_PG}" == "true" ]; then \
		ln -fs backends/pg.tf backend.tf; \
	fi
	pwd
	terraform init -backend-config="conn_str=${TFSTATE_DATABASE_URL}" -backend-config="schema_name=${TFSTATE_DATABASE_SCHEMA}" -input=false

terraform-apply: terraform-init
	rm users.tf 
	terraform apply -auto-approve -input=false

check-config:
	@test -n "${KEYCLOAK_URL}" || (echo >&2 KEYCLOAK_URL needs to be set && false)
	@test -n "${KEYCLOAK_CLIENT_ID}" || (echo >&2 KEYCLOAK_CLIENT_ID needs to be set && false)
	@test -n "${KEYCLOAK_CLIENT_SECRET}" || (echo >&2 KEYCLOAK_CLIENT_SECRET needs to be set && false)
	@test -n "${TFSTATE_DATABASE_URL}" || (echo >&2 TFSTATE_DATABASE_URL needs to be set && false)
	@test -n "${KEYCLOAK_URL}" || (echo >&2 KEYCLOAK_URL needs to be set && false)
	@test -n "${KEYCLOAK_ADMIN_PASSWORD}" || (echo >&2 KEYCLOAK_ADMIN_PASSWORD needs to be set && false)
	@test -n "${KEYCLOAK_ADMIN_USER}" || (echo >&2 KEYCLOAK_ADMIN_USER needs to be set && false)
