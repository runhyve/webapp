release=""
entrypoint=""
_tmp_jail="jailer-build.$$"
workdir="/"
user="root"

trap _CLEANUP EXIT

FROM() {
  release="$@"
  _INIT
}

# placeholder
ENTRYPOINT() {
  entrypoint="$@"
}

RUN() {
  echo "RUN $*"
  iocage exec -U ${user} "${_tmp_jail}" "cd ${workdir} && $*"
}

_INIT() {
  random=$(jot -r 1 65500)
  # this should be configurable
  ip="172.16.4.$(($random%252))/24"

  echo "[*] Creating temporary jail (${_tmp_jail})"
  iocage create -n "${_tmp_jail}" -r "${release}"
  iocage set ip4_addr="lo0|${ip}" "${_tmp_jail}"
  iocage start "${_tmp_jail}"
}

USER() {
  echo "USER $1"
  user="$1"
}

WORKDIR() {
  echo "WORKDIR $1"
  workdir="$1"
}

ADD() {
  echo "ADD $1 $2"
  _src="$1"
  _dst="$2"
  # Get jail path from iocage
  cp -rf "$1" "/zroot/iocage/jails/${_tmp_jail}/root/$2"
}

_CLEANUP() {
  echo "[*] Removing temporary jail (${_tmp_jail})"
  iocage stop "${_tmp_jail}" ||
  iocage export "${_tmp_jail}"
  iocage destroy -f "${_tmp_jail}"
}
