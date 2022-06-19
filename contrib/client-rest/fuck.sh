set -- "$@" curl
set -- "$@" -X
set -- "$@" POST
set -- "$@" -H
set -- "$@" "X-Parse-Application-Id: usk1R59XKd20Bm4uCqbpcqTMAchohfq6JPIT61Sj"
set -- "$@" -H
set -- "$@" "X-Parse-REST-API-Key: 26tk0fXADmeHesdCnqVIGfYQ7nqx70Qeu1kDrbfv"
set -- "$@" -H
set -- "$@" "X-Parse-Revocable-Session: 1"
set -- "$@" http://localhost:1338//functions/hello

"$@"
