# FreeBSD Port for Teleport tsh

This directory contains a FreeBSD port for the Teleport `tsh` CLI client.

## Installing the Port

### Quick Install (from this repo)

```sh
cd port
sudo make install clean
```

### Submitting to FreeBSD Ports

To submit this port to the official FreeBSD ports tree:

1. Test the port thoroughly:
   ```sh
   sudo make stage
   sudo make check-plist
   sudo make package
   ```

2. Run portlint:
   ```sh
   portlint -A
   ```

3. Submit a bug report at https://bugs.freebsd.org/
   - Category: ports
   - Summary: [NEW PORT] security/teleport-tsh: Teleport CLI client

See: https://docs.freebsd.org/en/books/porters-handbook/

## Updating the Port Version

1. Update `PORTVERSION` in `Makefile`
2. Regenerate distinfo:
   ```sh
   sudo make makesum
   ```
3. Test the build:
   ```sh
   sudo make clean && sudo make
   ```

## Port Options

- `FIDO2` (default: on) - Enable libfido2 for hardware MFA tokens
  Note: HID not actually supported on FreeBSD, but the library links

## Files

- `Makefile` - Port makefile
- `pkg-descr` - Package description
- `files/` - FreeBSD-specific source files
  - `disk_freebsd.go` - Disk utilities
  - `stat_freebsd.go` - SCP file stats
  - `reexec_freebsd.go` - Process re-exec (v18+)
  - `hid-stub/` - HID library stub
