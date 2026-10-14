#!/bin/sh
# Probe the current system for SailfishOS build engine capabilities.
# Emits key=value pairs to stdout for each finding.

emit() {
    echo "$1=$2"
}

# Detect build engine backends
if ! command -v docker >/dev/null 2>&1 && ! command -v VBoxManage >/dev/null 2>&1; then
    missing build_engine_backend
fi
# The emulator needs VirtualBox regardless of the build engine type.
if command -v VBoxManage >/dev/null 2>&1; then
    emit virtualbox_version "$(VBoxManage --version 2>/dev/null | head -n 1)"
    emit emulator_backend yes
else
    emit emulator_backend no
fi
if command -v docker >/dev/null 2>&1; then
    emit docker_version "$(docker version --format '{{.Client.Version}}' 2>/dev/null | head -n 1)"
fi
mem_kb=$(sed -n 's/^MemTotal:[[:space:]]*\([0-9]*\).*/\1/p' /proc/meminfo 2>/dev/null)
[ -n "$mem_kb" ] && emit ram_gb "$((mem_kb / 1024 / 1024))"
free_kb=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')
[ -n "$free_kb" ] && emit home_free_gb "$((free_kb / 1024 / 1024))"
if command -v docker >/dev/null 2>&1; then
    if id -nG 2>/dev/null | tr ' ' '\n' | grep -qx docker; then
        emit user_in_docker_group yes
    fi
fi
