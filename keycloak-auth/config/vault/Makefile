#OUTSIDE CONTAINER

build:
	docker build -t ansible-vault .
	
run-vault: build
	./vault.sh

#INSIDE CONTAINER
decrypt-staging:
	ansible-vault view --ask-vault-pass staging.env > staging.secret

edit-staging:
	ansible-vault edit --ask-vault-pass staging.env

decrypt-prod:
	ansible-vault view --ask-vault-pass prod.env > prod.secret

edit-prod:
	ansible-vault edit --ask-vault-pass prod.env

## with secret file
decrypt-staging-f:
	ansible-vault view --vault-password-file vault-staging.secret staging.env > staging.secret

edit-staging-f:
	ansible-vault edit --vault-password-file vault-staging.secret staging.env

decrypt-prod-f:
	ansible-vault view --vault-password-file vault-prod.secret prod.env > prod.secret

edit-prod-f:
	ansible-vault edit --vault-password-file vault-prod.secret prod.env

## create vault
## ansible-vault create myFile
