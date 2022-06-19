#!/bin/bash

cd $(dirname "$BASH_SOURCE")

shopt -s nullglob
if (($#)); then
  files=( "$@" )
else
  files=( *.h *.xml *.jks *.json )
fi

set -- "${files[@]}"
if (( !$# )); then
  echo >&2 no files
  exit 1
fi
set -- devs/*.asc devs/*.pub
for ((i=0;i<$#;i++)) ; do
  dev="$1"
  dev=$(basename "$dev" .asc)
  dev=$(basename "$dev" .pub)
  set "$@" "$dev"
  shift
done


for file in ${files[@]}; do
  file="${file%.asc}"

  if test -e $file.asc ; then
    if test -e $file.old.asc; then
      rm -f $file.asc
    else
      mv -f $file.asc $file.old.asc
    fi
  fi

  set -x 
  if gpg -sea  $(printf ' -r %s ' "$@" ) --output ${file}.asc ${file} ; then
      shred $file
      rm -f $file
  fi
  set +x
done
