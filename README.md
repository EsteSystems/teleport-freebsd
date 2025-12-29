# Teleport tsh for FreeBSD

Build the [Teleport](https://goteleport.com/) `tsh` CLI client on FreeBSD.

Teleport doesn't officially support FreeBSD, but `tsh` (the client) works fine with minor patches.

## Tested On

- FreeBSD 15.0-RELEASE
- Teleport v13.x, v18.x

## Prerequisites

```sh
pkg install go124 libfido2
```

## Quick Start

```sh
# Clone Teleport
git clone --depth 1 --branch v13.4.26 https://github.com/gravitational/teleport.git
cd teleport

# Clone this repo into freebsd-build/
git clone https://github.com/YOUR_USERNAME/teleport-freebsd.git freebsd-build

# Build
./freebsd-build/build-tsh.sh

# Install
sudo cp build/tsh /usr/local/bin/
```

## Building a Specific Version

```sh
# For a Teleport v13 server:
./freebsd-build/build-tsh.sh v13.4.26

# For a Teleport v18 server:
./freebsd-build/build-tsh.sh v18.0.0
```

**Important:** Your `tsh` version must match your server's major version. Check with:
```sh
tsh version
```

## What This Patches

| File | Purpose |
|------|---------|
| `disk_freebsd.go` | POSIX permission constants missing from Go's FreeBSD syscall |
| `stat_freebsd.go` | File access time for scp support |
| `reexec_freebsd.go` | Process re-exec support (v18+) |
| `hid-stub/` | Stub for HID library (hardware tokens not supported) |

## Supported Features

- `tsh login` - Authenticate to Teleport cluster
- `tsh ssh` - SSH to nodes
- `tsh scp` - File transfer
- `tsh ls` - List nodes
- `tsh db` - Database access
- `tsh kube` - Kubernetes access
- MFA via TOTP or browser-based WebAuthn

## Unsupported Features

- Hardware U2F/FIDO tokens (HID not supported on FreeBSD)
- VNet (Linux/macOS only)
- Touch ID (macOS only)

## Troubleshooting

### Version mismatch error
```
Maximum client version supported by the server is 13.x.x but you are using 18.0.0
```
Build the matching version: `./freebsd-build/build-tsh.sh v13.4.26`

### Login fails silently
Try with debug logging: `tsh login --debug --proxy your.proxy.com`

## FreeBSD Port

A FreeBSD port is included in `port/`. To install:

```sh
cd port
sudo make install clean
```

See `port/README.md` for instructions on submitting to the FreeBSD ports tree.

## License

Same as Teleport: [AGPL-3.0](https://github.com/gravitational/teleport/blob/master/LICENSE)

## Contributing

PRs welcome! If you test on other FreeBSD versions, please update this README.
