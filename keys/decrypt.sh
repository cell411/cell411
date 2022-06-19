#!/bin/bash

decrypt() {
  gpg -d --output ${file%.asc} ${file}
};

if test -z "$*"; then
  set -- keys/*.asc
  select file ; do test -z "$file" || decrypt "$file"; done
else
  for file in "$@"; do decrypt "$file"; done
fi
