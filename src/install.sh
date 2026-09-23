#!/bin/sh
set -eu
app_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
chmod 700 "${app_dir}/var"
