#!/bin/bash

source "$HOME/.parse/config.dev.sh"

if test -z "$PARSE_SESSION_KEY"; then
  source key.sh
fi

cd "$(dirname "$BASE_SOURCE")"
source generic/functions.sh
base=$(basename "$BASH_SOURCE" .sh)

if test "${base:0:4}" == "read"; then
  name=${base:4};
  method="GET";
  path="classes/$name ";

elif test "${base:0:4}" == "call"; then
  name="${base:4}"
  name="$(echo "${name:0:1}" | tr A-Z a-z)${name:1}"
  method="POST"
  path="functions/$name"
elif test "${base:0:6}" == "create"; then
  name="${base:6}"
  method="POST"
  path="classes/$name"
else
  error "I only know how to handle read, call and create"
fi
json=""
if test -e $base.sh.in.json; then
  json="$(cat $base.sh.in.json)"
  echo "json: $json"
fi
str='curl -X $method \
  --trace-ascii curl.trace \
  -H "X-Parse-Application-Id: $PARSE_APPID" \
  -H "X-Parse-REST-API-Key: $PARSE_RESTKEY" \
  -H "X-Parse-Revocable-Session: 1" \
  -H "X-Parse-Session-Token: $PARSE_SESSION_KEY" \
  ${json+-H "Content-Type: application/json" -d "$json" } \
  $PARSE_PUB_URL/$path'

eval printf '"| %s\n"' "$str"

RESULT="$(eval "$str")"
if (($?)); then
  error "curl call failed"
fi

echo "$RESULT" | tee $base.sh.txt | json_pp | tee $base.sh.json | less -S





