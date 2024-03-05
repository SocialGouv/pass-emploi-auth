#!/bin/bash

steptxt="----->"
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'                              # No Color
CURL="curl -L --retry 15 --retry-delay 2" # retry for up to 30 seconds

info() {
  echo -e "${GREEN}       $*${NC}"
}

warn() {
  echo -e "${YELLOW} !!    $*${NC}"
}

err() {
  echo -e "${RED} !!    $*${NC}" >&2
}

step() {
  echo "$steptxt $*"
}

start() {
  echo -n "$steptxt $*... "
}

finished() {
  echo "done"
}

function indent() {
  c='s/^/       /'
  case $(uname) in
  Darwin) sed -l "$c" ;; # mac/bsd sed: -l buffers on line boundaries
  *) sed -u "$c" ;;      # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
  esac
}

function install_jq() {
  if [[ -f "${ENV_DIR}/JQ_VERSION" ]]; then
    JQ_VERSION=$(cat "${ENV_DIR}/JQ_VERSION")
  else
    JQ_VERSION=1.6
  fi
  step "Fetching jq $JQ_VERSION"
  if [ -f "${CACHE_DIR}/dist/jq-$JQ_VERSION" ]; then
    info "File already downloaded"
  else
    ${CURL} -o "${CACHE_DIR}/dist/jq-$JQ_VERSION" "https://github.com/stedolan/jq/releases/download/jq-$JQ_VERSION/jq-linux64"
  fi
  cp "${CACHE_DIR}/dist/jq-$JQ_VERSION" "${BUILD_DIR}/bin/jq"
  chmod +x "${BUILD_DIR}/bin/jq"
  finished
}

function install_jdk() {
  install_jq
  if [[ -f "${ENV_DIR}/JDK_MAJOR_VERSION" ]]; then
    JDK_MAJOR_VERSION=$(cat "${ENV_DIR}/JDK_MAJOR_VERSION")
  else
    JDK_MAJOR_VERSION=11
  fi
  step "Install AdoptOpenJDK JDK_MAJOR_VERSION JDK"
  local jdk_query_url="https://api.adoptopenjdk.net/v3/assets/feature_releases/${JDK_MAJOR_VERSION}/ga"
  local http_code
  http_code=$($CURL -G -o "$TMP_PATH/jdk.json" -w '%{http_code}' -H "accept: application/json" "${jdk_query_url}" \
   --data-urlencode "architecture=x64" \
   --data-urlencode "heap_size=normal" \
   --data-urlencode "image_type=jdk" \
   --data-urlencode "jvm_impl=hotspot" \
   --data-urlencode "os=linux" \
   --data-urlencode "page=0" \
   --data-urlencode "page_size=1" \
   --data-urlencode "project=jdk" \
   --data-urlencode "sort_method=DEFAULT" \
   --data-urlencode "sort_order=DESC" \
   --data-urlencode "vendor=adoptopenjdk")
  
  if [[ $http_code == 200 ]]; then
    local jdk_dist
    jdk_dist=$(cat "$TMP_PATH/jdk.json" | jq '.[] | .binaries | .[] | .package.name' )
    jdk_dist="${jdk_dist%\"}"
    jdk_dist="${jdk_dist#\"}"
    local checksum
    checksum=$(cat "$TMP_PATH/jdk.json" | jq '.[] | .binaries | .[] | .package.checksum' | xargs)
    local jdk_release_name
    jdk_release_name=$(cat "$TMP_PATH/jdk.json" | jq '.[] | .release_name')
    jdk_release_name="${jdk_release_name%\"}"
    jdk_release_name="${jdk_release_name#\"}"
    local jdk_url
    jdk_url=$(cat "$TMP_PATH/jdk.json" | jq '.[] | .binaries | .[] | .package.link' | xargs)
    info $jdk_url
  else
    warn "AdoptOpenJDK API v3 HTTP STATUS CODE: $http_code"
    local jdk_release_name="jdk-11.0.11+9"
    info "Using by default $jdk_release_name"
    local jdk_dist="OpenJDK11U-jdk_x64_linux_hotspot_11.0.14_9.tar.gz"
    local jdk_url="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/${jdk_dist}"
    local checksum="${jdk_url}.sha256.txt"
  fi
  info "Fetching $jdk_dist"
  local dist_filename="${CACHE_DIR}/dist/$jdk_dist"
  if [ -f "${dist_filename}" ]; then
    info "File already downloaded"
  else
    ${CURL} -o "${dist_filename}" "${jdk_url}"
  fi
  if [ -f "${dist_filename}.sha256" ]; then
    info "JDK sha256 sum already checked"
  else
    echo "${checksum} ${jdk_dist}" > "${dist_filename}.sha256"
    cd "${CACHE_DIR}/dist" || return
    sha256sum -c --strict --status "${dist_filename}.sha256"
    info "JDK sha256 checksum valid"
  fi
  if [ -d "${BUILD_DIR}/java" ]; then
    warn "JDK already installed"
  else
    tar xzf "${dist_filename}" -C "${CACHE_DIR}/dist"
    info `ls "${CACHE_DIR}/dist"`
    mv "${CACHE_DIR}/dist/$jdk_release_name" "$BUILD_DIR/java"
    info "JDK archive unzipped to $BUILD_DIR/java"
  fi
  export PATH=$PATH:"${BUILD_DIR}/java/bin"
  if [ ! -d "${BUILD_DIR}/.profile.d" ]; then
    mkdir -p "${BUILD_DIR}/.profile.d"
  fi
  touch "${BUILD_DIR}/.profile.d/java.sh"
  echo "export PATH=$PATH:/app/java/bin" > "${BUILD_DIR}/.profile.d/java.sh"
  info "$(java -version)"
  finished
}

function fetch_github_latest_release() {
  local location="$1"
  local latest_release_repo="$2"
  local default_latest_release="$3"
  local http_code
  http_code=$($CURL -G -o "$TMP_PATH/latest_release.json" -w '%{http_code}' -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${latest_release_repo}/releases/latest")
  local latest_release_version
  if [[ $http_code == 200 ]]; then
    latest_release_version=$(cat "$TMP_PATH/latest_release.json" | jq '.tag_name' | xargs)
    latest_release_version="${latest_release_version%\"}"
    latest_release_version="${latest_release_version#\"}"
  else
    latest_release_version="$default_latest_release"
  fi
  echo "$latest_release_version"
}

function fetch_keycloak_dist() {
  local version="$1"
  local location="$2"

  local dist="keycloak-${version}.tar.gz"
  local dist_url
  local download_url
  local RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
  local major_version
  major_version=$(echo $version | sed -e "s#$RE#\1#")
  if [[ $major_version -gt 11 ]]; then
    download_url="https://github.com/keycloak/keycloak/releases/download/${version}"
  else
    download_url="https://downloads.jboss.org/keycloak/${version}"
  fi
  dist_url=$(echo "${download_url}/${dist}" | xargs)
  dist_url="${dist_url%\"}"
  dist_url="${dist_url#\"}"
  local sha1_dist
  sha1_dist=$(echo "${dist}.sha1" | xargs)
  local sha1_url
  sha1_url=$(echo "${download_url}/${sha1_dist}" | xargs)
  sha1_url="${sha1_url%\"}"
  sha1_url="${sha1_url#\"}"
  step "Fetch keycloak ${version} dist"
  if [ -f "${CACHE_DIR}/dist/${dist}" ]; then
    info "File is already downloaded"
  else
    ${CURL} -g -o "${CACHE_DIR}/dist/${dist}" "${dist_url}"
  fi
  ${CURL} -g -o "${CACHE_DIR}/dist/${dist}.sha1" "${sha1_url}"
  local file_checksum
  file_checksum="$(shasum "${CACHE_DIR}/dist/${dist}" | cut -d \  -f 1)"
  local checksum
  checksum=$(cat "${CACHE_DIR}/dist/${dist}.sha1")
  if [ "$checksum" != "$file_checksum" ]; then
    err "Keycloak checksum file downloaded not valid"
    exit 1
  else
    info "Keycloak checksum valid"
  fi
  tar xzf "$CACHE_DIR/dist/${dist}" -C "$location"
  finished
}

function fetch_keycloak_tools() {
  local version="$1"
  local location="$2"
  local tmp="$3"

  local tools_repo_url="https://github.com/keycloak/keycloak-containers"
  git clone --depth 1 --branch "${version}" "${tools_repo_url}" "${tmp}/keycloak-containers" >/dev/null 2>&1
  mv "${tmp}/keycloak-containers/server/tools" "${location}"
  rm -rf "${tmp}/keycloak-containers"
}

function configure_postgres_module() {
  local version="$1"
  local keycloak_path="$2"
  local tools_path="$3"

  mkdir -p "${keycloak_path}/modules/system/layers/base/org/postgresql/jdbc/main"
  cd "${keycloak_path}/modules/system/layers/base/org/postgresql/jdbc/main" || return
  local jdbc_postgresql_url="https://jdbc.postgresql.org/download/postgresql-${version}.jar"
  curl -L -s "${jdbc_postgresql_url}" >postgres-jdbc.jar
  cp "${tools_path}/databases/postgres/module.xml" .
}

function configure_keycloak() {
  local keycloak_path="$1"
  local tools_path="$2"
  find "${tools_path}" -type f -name '*.sh' -exec chmod +x {} \;
  find "${keycloak_path}" -type f -name '*.sh' -exec chmod +x {} \;
  find "${tools_path}" -type f -name '*.cli' -exec sed -i "s|\/opt\/jboss|${BUILD_DIR}|g" {} \;
  find "${keycloak_path}" -type f -name '*.cli' -exec sed -i "s|\/opt\/jboss|${BUILD_DIR}|g" {} \;
  find "${tools_path}" -type f -name '*.sh' -exec sed -i "s|\/opt\/jboss|${BUILD_DIR}|g" {} \;
  find "${keycloak_path}" -type f -name '*.sh' -exec sed -i "s|\/opt\/jboss|${BUILD_DIR}|g" {} \;
  find "${tools_path}" -type f -name '*.cli' -exec sed -i "s|\/app|${BUILD_DIR}|g" {} \;
  find "${keycloak_path}" -type f -name '*.cli' -exec sed -i "s|\/app|${BUILD_DIR}|g" {} \;
  find "${tools_path}" -type f -name '*.sh' -exec sed -i "s|\/app|${BUILD_DIR}|g" {} \;
  find "${keycloak_path}" -type f -name '*.sh' -exec sed -i "s|\/app|${BUILD_DIR}|g" {} \;
  "${keycloak_path}/bin/jboss-cli.sh" --file="${tools_path}/cli/standalone-configuration.cli"
  rm -rf "${keycloak_path}/standalone/configuration/standalone_xml_history"
  "${keycloak_path}/bin/jboss-cli.sh" --file="${tools_path}/cli/standalone-ha-configuration.cli"
  rm -rf "${keycloak_path}/standalone/configuration/standalone_xml_history"
  find "${tools_path}" -type f -name '*.cli' -exec sed -i "s|${BUILD_DIR}|\/app|g" {} \;
  find "${keycloak_path}" -type f -name '*.cli' -exec sed -i "s|${BUILD_DIR}|\/app|g" {} \;
  find "${tools_path}" -type f -name '*.sh' -exec sed -i "s|${BUILD_DIR}|\/app|g" {} \;
  find "${keycloak_path}" -type f -name '*.sh' -exec sed -i "s|${BUILD_DIR}|\/app|g" {} \;
}

function install_custom_themes() {
  local dest="$1"

  mv "${BP_DIR}/theme-pass-emploi" "${dest}/themes/theme-pass-emploi"
  mv "${BP_DIR}/theme-pass-emploi-web" "${dest}/themes/theme-pass-emploi-web"
  mv "${BP_DIR}/theme-pass-emploi-app" "${dest}/themes/theme-pass-emploi-app"
}

function install_keycloak_customisation(){
  local dest="$1"
  cd "${BP_DIR}/keycloak-customisation"
  ./gradlew clean jar
  cp "${BP_DIR}/keycloak-customisation/build/libs/pass-emploi-keycloak-customisation-0.0.1-SNAPSHOT.jar" "${dest}/standalone/deployments/pass-emploi-keycloak-customisation.jar"

}
function install_prebuild_keycloak_customisation(){
  local dest="$1"
  cp "${BP_DIR}/keycloak-customisation/build/libs/pass-emploi-keycloak-customisation-0.0.1-SNAPSHOT.jar" "${dest}/standalone/deployments/pass-emploi-keycloak-customisation.jar"
}

function install_custom_scripts() {
  mv "${BP_DIR}/bin/custom-startup-scripts" "${KEYCLOAK_PATH}/custom-startup-scripts"
  mv "${BP_DIR}/bin/startup-scripts" "${KEYCLOAK_PATH}/startup-scripts"
  
  find "${KEYCLOAK_PATH}" -type f -name '*.cli' -exec sed -i "s|\/opt\/jboss|${KEYCLOAK_PATH}|g" {} \;
  find "${KEYCLOAK_PATH}" -type f -name '*.cli' -exec sed -i "s|\/app|${KEYCLOAK_PATH}|g" {} \;
  
  "${KEYCLOAK_PATH}/bin/jboss-cli.sh" --file="${KEYCLOAK_PATH}/startup-scripts/standalone-configuration.cli"
  rm -rf "${KEYCLOAK_PATH}/standalone/configuration/standalone_xml_history"
  "${KEYCLOAK_PATH}/bin/jboss-cli.sh" --file="${KEYCLOAK_PATH}/startup-scripts/standalone-ha-configuration.cli"
  rm -rf "${KEYCLOAK_PATH}/standalone/configuration/standalone_xml_history"
}

function install_elastic_apm_agent() {
  local dest="$1"

  mv "${BP_DIR}/bin/elastic-apm-agent-1.29.0.jar" "${dest}/elastic-apm-agent.jar"
}
