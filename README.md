# Tailscale DroboApp for Drobo B810n

This repository packages Tailscale's official Linux ARM binaries as a DroboApp for the Drobo B810n. The package was installed and authenticated on one B810n running ARMv7 and kernel 3.2.96-3. The node appeared in its tailnet, and a `tailscale ping` to another tailnet device succeeded. A Resilio Sync WebUI on TCP 8888 was reached through the Drobo's Tailscale IP. This is a device-specific verification, not a compatibility claim for other Drobo models.

The repository contains build scripts and DroboApp service files, **not** Tailscale credentials, node state, downloaded binaries, or the generated package.

## Build

Run `./build.sh` on macOS or Linux. It downloads the pinned official ARM archive, verifies its SHA-256, and writes `dist/tailscale.tgz`. Inspect its layout with `tar -tzf dist/tailscale.tgz`. The build does not contact or change the Drobo.

## Install on a B810n

Before installing, verify the target's architecture and DroboApps framework, and ensure the DroboApps share does not expose the app's `var/tailscaled.state` to unintended SMB users. The app's `var` directory is set to mode `700`, but SMB access controls must also be checked on the target. Do not commit or share the state file: it is the node's identity.

Copy `dist/tailscale.tgz` to the root of the DroboApps share and run `/usr/bin/DroboApps.sh install` on the NAS. The framework extracts the package and starts `tailscaled`. It uses `--tun=userspace-networking` because the tested B810n has no `/dev/net/tun`. No Funnel or service exposure is enabled by the package.

For first-time authentication, run the CLI as root with the installed socket and open the URL it prints:

```sh
sudo /mnt/DroboFS/Shares/DroboApps/tailscale/app/tailscale \
  --socket=/tmp/DroboApps/tailscale/tailscaled.sock up
```

Then verify registration and connectivity:

```sh
sudo /mnt/DroboFS/Shares/DroboApps/tailscale/app/tailscale \
  --socket=/tmp/DroboApps/tailscale/tailscaled.sock status
```

The DroboApps framework invokes `service.sh` for start and stop. Its `stop` action signals the daemon using the PID file and removes the transient PID and socket files; it does not delete the node state.

## Accessing a local app over Tailscale

On the tested B810n, Resilio Sync's WebUI was reachable from another tailnet device at `http://<drobo-tailnet-ip>:8888/gui/` and responded with HTTP Basic authentication (`Resilio Sync` realm). Those WebUI credentials are separate from Drobo SSH and Tailscale. This reachability is verified for the WebUI only; SMB access and post-reboot persistence have not been verified.
