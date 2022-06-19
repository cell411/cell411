#!/bin/bash
set -exv
cd $(dirname ${BASH_SOURCE})
pwd >> /tmp/pwd
output="$(pwd -P)"
chown -R root:parse .
chmod -R 0755 .
mkdir -p log
dir=$PWD/log
chmod -R 0755 $dir
chown -R parse-log:parse-log $dir
exec setuidgid parse-log multilog t $dir
