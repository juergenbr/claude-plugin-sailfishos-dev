#!/bin/sh
# Detect which SailfishOS development host profile applies to the current machine.
#
# Prints exactly one of:
#   ubuntu-native    Linux host with a native Sailfish SDK (the original dev notebook)
#   mac-utm          macOS (Apple silicon) host; SDK lives in the "SailfishOSDev" UTM VM
#   sdk-vm-internal  Running INSIDE the SailfishOSDev UTM VM itself (ARM64 Linux + native SDK)
#   unknown          No known environment — do not guess, ask the user to set one up
#
# Override: write the profile name to ~/.config/sailfishos-dev/profile (or set
# SAILFISHOS_DEV_PROFILE_FILE to another path). An explicit marker always wins,
# so unusual setups can be pinned without touching this script.
#
# Usage: scripts/detect-host.sh && exit 0 on a known profile.

MARKER="${SAILFISHOS_DEV_PROFILE_FILE:-$HOME/.config/sailfishos-dev/profile}"
if [ -f "$MARKER" ]; then
    cat "$MARKER"
    exit 0
fi

S=$(uname -s)
M=$(uname -m)

# ARM64 Linux with a local SDK: that is the SailfishOSDev UTM guest itself.
if [ "$S" = "Linux" ] && [ "$M" = "aarch64" ] && [ -x "$HOME/SailfishOS/bin/sfdk" ]; then
    echo "sdk-vm-internal"
    exit 0
fi

# macOS host: the SDK can only run in the UTM VM (Intel/Intel-VBox builds do not
# run on Apple silicon). UTM's presence identifies the supported setup.
if [ "$S" = "Darwin" ]; then
    if command -v utmctl >/dev/null 2>&1; then
        echo "mac-utm"
        exit 0
    fi
    echo "unknown"
    exit 1
fi

# Linux host with a native SDK install: the original Ubuntu dev notebook.
if [ "$S" = "Linux" ] && [ -x "$HOME/SailfishOS/bin/sfdk" ]; then
    if command -v docker >/dev/null 2>&1 || command -v VBoxManage >/dev/null 2>&1; then
        echo "ubuntu-native"
        exit 0
    fi
fi

echo "unknown"
exit 1
