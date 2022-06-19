#!/bin/bash

cmd="$1"
shift
out="$cmd.out"

"$cmd" "$@" 2>&1 | tee "$out"
res=( ${PIPESTATUS[@]} )
res=$(( "$(IFS="+"; echo "${res[*]}" )" ))
echo >&2 res=$res
exit $res;
