# Tailscale DroboApp for B810n (prototype)

This is an **uninstalled prototype**, not a verified B810n release. It packages
Tailscale's official Linux ARM static binaries in the DroboApp TGZ layout. No
Tailscale credentials or state belong in this repository.

## Build

Run `./build.sh` on macOS or Linux. The script downloads the pinned official ARM
archive, checks its SHA-256, and creates `dist/tailscale.tgz`. It does not contact
or change the Drobo. Inspect the archive with `tar -tzf dist/tailscale.tgz`.

## Before installation

On the B810n, confirm `uname -m`, `/dev/net/tun`, available RAM, and that the
DroboApps share is restricted to administrators. In particular, `var/tailscaled.state`
contains a Tailscale node identity and must not be readable over a guest or
ordinary SMB share. Do not install if that cannot be guaranteed.

The service starts `tailscaled` in userspace-networking mode to avoid assuming
TUN support. That mode does **not** make all Drobo services reachable by itself.
After authenticating, an administrator must explicitly configure Tailscale Serve
for the desired local TCP service (for example SMB port 445), then verify access
from another tailnet device. Do not enable Funnel. This prototype does not
automatically expose any service or run `tailscale up`.

## Intended manual installation (only after the checks above)

Copy `tailscale.tgz` to the DroboApps share, then use the Drobo Dashboard's app
install flow or `/usr/bin/DroboApps.sh install`. To authenticate interactively,
run `/mnt/DroboFS/Shares/DroboApps/tailscale/app/tailscale --socket=/tmp/DroboApps/tailscale/tailscaled.sock up`
on the B810n and open the URL it prints. Never paste an auth key into a command
or commit it. The installed `service.sh` supports `start`, `stop`, `restart`, and
`status` through the DroboApps framework.

## Current verification boundary

Archive layout and ARM ELF format can be checked locally. B810n execution,
reboot persistence, private-state permissions as seen through SMB, and tailnet
connectivity require live-device verification before calling this usable.
