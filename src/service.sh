#!/bin/sh

. /etc/service.subr

framework_version="2.1"
name="tailscale"
version="1.102.4"
description="Tailscale userspace daemon"
depends=""

prog_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
data_dir="${prog_dir}/var"
daemon="${prog_dir}/app/tailscaled"
tmp_dir="/tmp/DroboApps/${name}"
pidfile="${tmp_dir}/pid.txt"
logfile="${tmp_dir}/log.txt"
statusfile="${tmp_dir}/status.txt"
errorfile="${tmp_dir}/error.txt"
socket="${tmp_dir}/tailscaled.sock"

start() {
  mkdir -p "${tmp_dir}" "${data_dir}"
  chmod 700 "${tmp_dir}" "${data_dir}"
  start-stop-daemon -S -m -b -x "${daemon}" -p "${pidfile}" -- \
    --state="${data_dir}/tailscaled.state" \
    --socket="${socket}" \
    --tun=userspace-networking
}

stop() {
  :
}

main "$@"
