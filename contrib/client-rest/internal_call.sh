#!/bin/bash
source "$HOME/.parse/config.sh"
curlCall() {
  base="$(basename $1 .sh)"
  shift;
  if test -z "$PARSE_SESSION_ID"; then
    source key.sh
  fi

  source generic/functions.sh

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
    json=$(cat $base.sh.in.json)
  fi

  set -- curl -X $method
  set -- "$@" --trace-ascii curl.trace
  set -- "$@" -H "X-Parse-Application-Id: $PARSE_APPID"
  set -- "$@" -H "X-Parse-REST-API-Key: $PARSE_RESTKEY"
  set -- "$@" -H "X-Parse-Revocable-Session: 1"
  set -- "$@"  -H "X-Parse-Session-Token: $PARSE_SESSION_KEY"
  if test -n "$json"; then
    set -- "$@" -H "Content-Type: application/json"
    set -- "$@" -d "$json"
  fi
  set -- "$@" $PARSE_PUB_URL/$path

  printf '| %s\n' "$@"

  RESULT="$( "$@" )"
  if (($?)); then
    error "curl call failed"
  fi
  echo "$RESULT" | tee $base.sh.txt | json_pp | tee $base.sh.json | less -S
}
