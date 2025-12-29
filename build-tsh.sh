#!/bin/sh
# Build tsh for FreeBSD
# Usage: ./freebsd-build/build-tsh.sh [version-tag]
# Example: ./freebsd-build/build-tsh.sh v13.4.26

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_TAG="${1:-}"

cd "$REPO_DIR"

# Checkout specific version if requested
if [ -n "$VERSION_TAG" ]; then
    echo "==> Checking out $VERSION_TAG..."
    git checkout "$VERSION_TAG"
fi

echo "==> Applying FreeBSD compatibility files..."

# Add replace directive for HID library (doesn't support FreeBSD)
if ! grep -q "github.com/flynn/hid.*=>.*freebsd-build/hid-stub" go.mod; then
    echo "" >> go.mod
    echo "replace github.com/flynn/hid => ./freebsd-build/hid-stub" >> go.mod
    echo "    Added replace directive for github.com/flynn/hid"
fi

# Copy FreeBSD-specific files (only if target directories exist)
if [ -d "lib/client/reexec" ]; then
    cp "$SCRIPT_DIR/reexec_freebsd.go" lib/client/reexec/
    echo "    Added lib/client/reexec/reexec_freebsd.go"
fi

if [ -d "lib/utils" ]; then
    cp "$SCRIPT_DIR/disk_freebsd.go" lib/utils/
    echo "    Added lib/utils/disk_freebsd.go"

    # Patch disk.go to exclude FreeBSD from its build constraints
    if [ -f "lib/utils/disk.go" ]; then
        if grep -q "//go:build !windows" lib/utils/disk.go; then
            awk '{
                gsub(/\/\/go:build !windows/, "//go:build linux || darwin")
                gsub(/\/\/ \+build !windows/, "// +build linux darwin")
                print
            }' lib/utils/disk.go > lib/utils/disk.go.tmp && mv lib/utils/disk.go.tmp lib/utils/disk.go
            echo "    Patched lib/utils/disk.go build constraint"
        fi
    fi
fi

if [ -d "lib/sshutils/scp" ]; then
    cp "$SCRIPT_DIR/stat_freebsd.go" lib/sshutils/scp/
    echo "    Added lib/sshutils/scp/stat_freebsd.go"
fi

# Detect Go binary
GO_BIN=""
for candidate in go go124 go123 go122 go121; do
    if command -v "$candidate" >/dev/null 2>&1; then
        GO_BIN="$candidate"
        break
    fi
done

if [ -z "$GO_BIN" ]; then
    # Try common FreeBSD paths
    for candidate in /usr/local/bin/go124 /usr/local/bin/go123 /usr/local/bin/go; do
        if [ -x "$candidate" ]; then
            GO_BIN="$candidate"
            break
        fi
    done
fi

if [ -z "$GO_BIN" ]; then
    echo "ERROR: Go not found. Install with: pkg install go124"
    exit 1
fi

echo "==> Using Go: $GO_BIN"
$GO_BIN version

# Check for libfido2
FIDO_TAG=""
if pkg-config --exists libfido2 2>/dev/null; then
    FIDO_TAG="libfido2"
    echo "==> libfido2 found, enabling MFA support"
else
    echo "==> libfido2 not found, building without MFA support"
    echo "    Install with: pkg install libfido2"
fi

# Create build directory
mkdir -p build

echo "==> Building tsh..."
CGO_ENABLED=1 $GO_BIN build -tags "$FIDO_TAG" -o build/tsh ./tool/tsh

echo "==> Build complete!"
ls -lh build/tsh
build/tsh version

echo ""
echo "Install with: cp build/tsh /usr/local/bin/"
