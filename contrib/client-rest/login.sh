#!/bin/bash

cd $(dirname ${BASH_SOURCE});
source ./generic/config.sh


if test -z "$PARSE_PASSWORD"; then
  read -p "enter password: " -s PARSE_PASSWORD 
fi
if test -z "$PARSE_PASSWORD"; then
  echo "password required"
  exit 1;
fi
for PARSE_USERNAME in dev2@copblock.app; do
#      echo "trying: $PARSE_USERNAME"
#      set -o pipefail # we want to know if cur fails, not tee.
#      set -e
set -- curl -X POST \
  -H "X-Parse-Application-Id: $PARSE_APPID" \
  -H "X-Parse-REST-API-Key: $PARSE_RESTAPI_KEY" \
  -H "X-Parse-Revocable-Session: 1" \
  -G \
  --data-urlencode "username=$PARSE_USERNAME" \
  --data-urlencode "password=$PARSE_PASSWORD" \
  "$PARSE_SERVER_URL/login" 
  
  
  if TEXT="$("$@")" ; then
    echo "$TEXT" > session.json
    node generic/proc_session.js
    exit 0;
  else
    echo "${@}" failed. 
    exit 1
  fi
done

