SHELL=/bin/sh
.SHELLFLAGS = -e -c
.ONESHELL:
.PHONY: help

export KEYCLOAK_URL=http://localhost:8082
export KEYCLOAK_ADMIN_USER=admin
export KEYCLOAK_ADMIN_PASSWORD=admin
export KEYCLOAK_CLIENT_ID=terraform
export KEYCLOAK_CLIENT_SECRET=111ed886-126a-11e9-ab12-23b741c9418a
export DOCKER_GATEWAY_IP=$(shell docker network inspect bridge | grep Gateway | cut -d: -f2 | awk '{ print $1}'| tr -d '" ')
export API_HOST=$(shell which apt-get > /dev/null && echo ${DOCKER_GATEWAY_IP} || echo 'host.docker.internal')

help: ##Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

provision: start-keycloak
	docker-compose build --no-cache provision
	docker-compose run --rm provision

provision-local:
	docker-compose build --no-cache provision
	docker-compose run --rm provision

build-keycloak:
	docker-compose build keycloak
build-keycloak-nc:
	docker-compose build --no-cache keycloak

start-keycloak:
	docker-compose up -d keycloak
	echo >&2 Waiting for keycloak to be ready
	docker-compose run --rm wait-on-keycloak

forward-local-keycloak:
	docker-compose up -d keycloak-fwd

start: start-keycloak-local ## Start the application
	echo AUTH SERVER STARTED

start-keycloak-local: provision forward-local-keycloak

clean: ##Stop and remove containers, volumes and other docker stuff
	docker-compose down --volumes --rmi local
	docker-compose rm -v

provision-staging:
	docker-compose -f deploy/docker-compose.yml build --no-cache provision-scalingo-staging
	docker-compose -f deploy/docker-compose.yml run --rm provision-scalingo-staging 

provision-prod:
	docker-compose -f deploy/docker-compose.yml build --no-cache provision-scalingo-prod
	docker-compose -f deploy/docker-compose.yml run --rm provision-scalingo-prod

logs:
	docker-compose logs -f keycloak
