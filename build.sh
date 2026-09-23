#!/usr/bin/env bash
set -euo pipefail

version=1.102.4
archive="tailscale_${version}_arm.tgz"
url="https://pkgs.tailscale.com/stable/${archive}"
expected_sha256=b981a59cb85fb923ee6e1860ee6934772c83a840a6627f0dbfd7711ed690b869
mkdir -p download dist

if [[ ! -f "download/${archive}" ]]; then
  curl --fail --location --silent --show-error --output "download/${archive}.part" "${url}"
  mv "download/${archive}.part" "download/${archive}"
fi
actual_sha256="$(shasum -a 256 "download/${archive}" | awk '{print $1}')"
if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
  echo "SHA-256 mismatch for ${archive}" >&2
  exit 1
fi

stage="$(mktemp -d)"
trap 'rm -rf "${stage}"' EXIT
mkdir -p "${stage}/app" "${stage}/var"
tar -xzf "download/${archive}" -C "${stage}" "tailscale_${version}_arm/tailscale" "tailscale_${version}_arm/tailscaled"
cp "${stage}/tailscale_${version}_arm/tailscale" "${stage}/app/"
cp "${stage}/tailscale_${version}_arm/tailscaled" "${stage}/app/"
cp src/install.sh src/service.sh src/uninstall.sh "${stage}/"
chmod 755 "${stage}/app/tailscale" "${stage}/app/tailscaled" "${stage}/service.sh"
chmod 700 "${stage}/var"
tar -czf dist/tailscale.tgz -C "${stage}" app var install.sh service.sh uninstall.sh
echo "Built dist/tailscale.tgz"
