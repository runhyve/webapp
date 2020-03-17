set -x

release=""
entrypoint=""
if [ ! -z $JAILER_TAG ]; then
  _tmp_jail="$JAILER_TAG"
else
  _tmp_jail="jailer-build.$$"
fi

_jid=""
_mountpoint=""
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

_GET_JID() {
  iocage get jid "${_tmp_jail}"
}

_GET_MOUNTPOINT() {
  jls -j ${_jid} -n path | cut -f 2 -d=
}

_INIT() {
  random=$(jot -r 1 65500)
  # this should be configurable
  ip="172.16.4.$(($random%252))/24"

  echo "[*] Creating temporary jail (${_tmp_jail})"
  iocage create -n "${_tmp_jail}" -r "${release}"
  iocage set ip4_addr="lo0|${ip}" "${_tmp_jail}"
  iocage start "${_tmp_jail}"
  _jid=$(_GET_JID)
  _mountpoint="$(_GET_MOUNTPOINT)"
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
  cp -rf "$1" "${_mountpoint}/$2"
}

STOP() {
  echo "STOP"
  iocage stop "${_tmp_jail}"
}

EXPORT() {
  STOP
  iocage export "${_tmp_jail}"
}

_CLEANUP() {
  iocage stop "${_tmp_jail}" || echo "Jail ${_tmp_jail} is stopped"
  echo "[*] Removing temporary jail (${_tmp_jail})"
  iocage destroy -f "${_tmp_jail}"
}
