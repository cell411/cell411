#!/bin/bash

cd $(dirname ${BASH_SOURCE});
source ./generic/config.sh

PARSE_PASSWORD=aa
{
  set -xv
  for PARSE_USERNAME in dev{1,2,3}@copblock.app; do
    json=$(printf '{"username":"%s","password":"%s"}' "${PARSE_USERNAME}" "${PARSE_PASSWORD}")
    curl -X POST \
      -H "X-Parse-Application-Id: $PARSE_APPID" \
      -H "X-Parse-REST-API-Key: $PARSE_RESTAPI_KEY" \
      -H "X-Parse-Master-Key: $PARSE_MASTERKEY" \
      -H "X-Parse-Revocable-Session: 1" \
      -H "Content-Type: application/json" \
      -d "${json}" \
      $PARSE_SERVER_URL/functions/setPassword;


    echo;
  done
} 2>&1 | tee setPassword.sh.out | less -S
#| json_pp | tee session.json | less -S

node generic/proc_session.js





