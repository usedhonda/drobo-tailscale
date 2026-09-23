#!/bin/sh
set -eu
app_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
"${app_dir}/service.sh" stop
# Intentionally retain var/tailscaled.state for explicit administrator handling.
