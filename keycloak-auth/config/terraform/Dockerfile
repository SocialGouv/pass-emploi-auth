ARG TERRAFORM_VERSION="1.0.11"

FROM hashicorp/terraform:${TERRAFORM_VERSION}

RUN apk add --update --no-cache curl ca-certificates libc6-compat make jq 

COPY . /config/terraform

WORKDIR /config/terraform

ENTRYPOINT []

CMD ["/bin/sh"]
