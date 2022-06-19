#!/bin/bash

source "$HOME/.parse/config.sh"

if test -z "$PARSE_SESSION_ID"; then
  source key.sh
fi

#    var query = new Parse.Query(Parse.Installation);
#    query.equalTo('channels', 'test-channel');

#Parse.Push.send({
time=$(date +%s)
json_params="$(node sendPush.js)"


#});
echo "$json_params"
echo "$json_params" | json_pp || exit 1
str='curl -X POST \
  -H "X-Parse-Application-Id: $PARSE_APPID" \
  -H "X-Parse-REST-API-Key: $PARSE_RESTKEY" \
  -H "X-Parse-Session-Token: $PARSE_SESSION_KEY" \
  -H "X-Parse-Revocable-Session: 1" \
  -H "Content-Type: application/json" \
  -d "${json_params}" \
  $PARSE_PUB_URL/functions/sendPush'

eval echo "call: $str"

eval "$str"
echo
echo






