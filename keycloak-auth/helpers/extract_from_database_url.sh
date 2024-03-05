#!/bin/bash

if [[ -n "$1" ]]; then
  # extract the protocol
  proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
  # remove the protocol
  url="$(echo ${1/$proto/})"
  # extract the user (if any)
  userpwd="$(echo $url | grep @ | cut -d@ -f1)"
  user="$(echo $userpwd | grep : | cut -d: -f1)"
  pwd="$(echo $userpwd | grep : | cut -d: -f2)"
  # extract the host and port
  hostport="$(echo ${url/userpwd@/} | cut -d/ -f1)"
  # by request host without port    
  host="$(echo $hostport | sed -e 's,:.*,,g')"
  # by request - try to extract the port
  port="$(echo $hostport | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
  # extract the path (if any)
  path="$(echo $url | grep / | cut -d/ -f2-)"
  
  echo "DB_USER=$user"
  echo "DB_PASSWORD=$pwd"
  echo "DB_ADDR=$host"
  echo "DB_PORT=$port"
  echo "DB_DATABASE=$path"
fi
