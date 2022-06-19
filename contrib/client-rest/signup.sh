#!/bin/bash
set -xv

set -e
test -z "$PARSE_CONFIG" && PARSE_CONFIG=$HOME/.parse/config.json
X="${PARSE_CONFIG}"
X=${X%.sh}
X=${X%.json}
X=${X}.sh
set -xv
source "$X"
set +xv
test -z "$PARSE_PASSWORD" && read -s -p "password: " PARSE_PASSWORD
echo "$PARSE_PASSWORD"
set -xv
for PREFIX in dev{1,2,3,4,5,6,7,8,9}; do
#for PREFIX in dev1; do
PARSE_USERNAME="$PREFIX@copblock.app"
curl -X POST \
  -H "X-Parse-Application-Id: $PARSE_APPID" \
  -H "X-Parse-REST-API-Key: $PARSE_RESTAPI_KEY" \
  -H "X-Parse-Revocable-Session: 1" \
  -H "Content-Type: application/json" \
  -d '{"username":"'"${PARSE_USERNAME}"'","password":"'"${PARSE_PASSWORD}"'","phone":"415-392-0202","firstName":"Rich","lastName":"Paul"}' \
  $PARSE_SERVER_URL/users;
done
