#!/bin/bash

exec 2>&1
set -exv
cd $(dirname ${BASH_SOURCE})
pwd
umask 0
chown -R parse:parse .
chmod -R 755 .
chown -R parse-log:parse-log -R log/log
chmod -R 755 -R log/log
PARSE_FLAVOR=$(basename "$PWD")
PARSE_FLAVOR=${PARSE_FLAVOR##*-}
PATH=/opt/bin:$PATH

cd /home/parse/src/cell411/js/server
pwd
if [ $(id -un) != "parse" ]; then
  set -- setuidgid parse
fi
"$@" mkdir -p logs-$PARSE_FLAVOR
#exec > >("$@" tee logs-$PARSE_FLAVOR/run.$$.log) 2>&1
#set -- "$@" PARSE_SERVER_LOG_LEVEL='debug'
set -- "$@" env
set -- "$@" PATH="/opt/bin:/usr/sbin:/usr/bin"
set -- "$@" HOME=~parse
set -- "$@" PARSE_FLAVOR=$PARSE_FLAVOR 
set -- "$@" PARSE_SERVER_LOGS_FOLDER=$PWD/logs-$PARSE_FLAVOR

if [ "$PARSE_FLAVOR" != "geocache" ]; then
test -e index.$PARSE_FLAVOR.js ||
  ln -s index.js index.$PARSE_FLAVOR.js
fi

exec "$@" node index.$PARSE_FLAVOR.js
