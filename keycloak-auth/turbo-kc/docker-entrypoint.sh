#!/bin/bash

set -e
START_OPS="-Djboss.node.name=${JBOSS_NODE_NAME}"
if [[ "${DISABLE_CLUSTER_MODE}" == "true" ]]; then
    START_OPS+=" -c=standalone.xml"
else
  # enable replication of in memory infinispan cache for cluster
  # /opt/jboss/tools/cli/infinispan/cache-owners.cli
  export CACHE_OWNERS_COUNT=${CACHE_OWNERS_COUNT:-2}
  export CACHE_OWNERS_AUTH_SESSIONS_COUNT=${CACHE_OWNERS_COUNT}
fi
exec "$@" ${START_OPS}
exit $?
