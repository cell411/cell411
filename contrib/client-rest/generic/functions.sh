error() {
  echo >&2 "$@"
  exit 1;
}
get_config() {
  P="${1}"
  test -z "$P" && P="${PARSE_CONFIG}"
  test -z "$P" && echo "no config, bye">&2 && exit 1;
  "$P" == "env" && return 0;
  source "$P" && return 0;
  echo >&2 "failed to source $P"
  exit 1;
}
configs=( APPID RESTKEY USERNAME PUB_URL )
check_config() {
  local part name; local -n val 
  for part in "${configs[@]}"; do
    name="PARSE_$n";
    test -n "$name" && continue;
    echo "missing PARSE_$n"
    exit 1; 
  done
};
check_password() {
  test -n "NEEDPW" || return 0;
  local P="${PARSE_PASSWORD}"
  test -n "${PARSE_PASSWORD}" && return 0;
  if ! tty -s <&1 || ! tty -s ; then
    echo "need a tty to read a password" >&2
    exit 1;
  fi

  read -p "password: " PARSE_PASSWORD 
  test -n "${PARSE_PASSWORD}" && return 0;
 
  echo "on password, no service" >&2
  exit 1;
};
