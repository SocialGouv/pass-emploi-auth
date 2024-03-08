SHELL=/bin/sh
.SHELLFLAGS = -e -c
.ONESHELL:
.PHONY: help

help: ##Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

start-local: start-keycloak
	provision-local
	echo KEYCLOAK STARTED

start-keycloak:
	docker-compose up -d keycloak
	echo >&2 Waiting for keycloak to be ready
	docker-compose run --rm wait-on-keycloak

provision-local:
	docker-compose build --no-cache provision-local
	docker-compose run --rm provision-local

clean: ##Stop and remove containers, volumes and other docker stuff
	docker-compose down --volumes --rmi local
	docker-compose rm -v

logs:
	docker-compose logs -f keycloak
