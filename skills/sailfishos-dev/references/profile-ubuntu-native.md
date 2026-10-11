# Host profile: ubuntu-native

The original supported setup: a dedicated Ubuntu notebook with the Sailfish SDK
installed natively. sfdk, Docker (build engine) and the VirtualBox-managed emulator
all run directly on this machine.

Use this profile when `scripts/detect-host.sh` reports `ubuntu-native`.

## SDK invocation

Everything runs locally:

```bash
SDK=~/SailfishOS/bin/sfdk
$SDK --help
```

## Build engine

- Docker on the host, image `sailfish-sdk-build-engine:$USER`.
- Started automatically on first build, or manually: `$SDK engine start`.
- Shell inside the engine: `$SDK engine exec`.

## Workspace constraint — discover, do not assume

The build engine container only mounts specific host paths. Find what is actually
mounted on this machine instead of assuming a fixed directory:

```bash
docker inspect "sailfish-sdk-build-engine_$(whoami)" | python3 -c \
  "import json,sys; c=json.load(sys.stdin)[0]; [print(m['Source']) for m in c['Mounts']]"
```

Projects must live inside one of the mounted paths (typically the user's home or a
dedicated subdirectory such as `~/repos/`). If you get
`The command needs to be used under Sailfish SDK workspace`, move the project into
a mounted path and retry.

If the engine name differs (older SDK versions, multi-user machines), list candidates:

```bash
docker ps -a --format '{{.Names}}' | grep sailfish
```

## Emulator (VirtualBox)

`sfdk emulator` manages the emulator through VirtualBox on this host:

```bash
$SDK emulator start
$SDK emulator stop
$SDK emulator status
$SDK emulator set downscale=no   # fill window at native resolution
$SDK emulator exec               # shell inside the emulator
```

## Emulator SSH (from this host)

VirtualBox NAT forwards the emulator's SSH to local port 2223:

```bash
ssh -p 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/sdk defaultuser@127.0.0.1
# root also accepts the SDK key once configured
```

## IDE

Qt Creator ships inside the SDK: `~/SailfishOS/bin/qtcreator` (native x86_64 binary).
Devices and kits are registered under Options → Devices; emulator and physical
devices work through the standard Sailfish device type.

## Deploy / run (local sfdk)

```bash
# build first with the matching target, then:
$SDK -c "device=<device-name>" deploy --sdk
$SDK -c "device=<device-name>" run harbour-myapp
$SDK device list
```

`<device-name>` for the emulator is shown by `$SDK device list`
(e.g. "Sailfish OS Emulator <version>"); physical devices are whatever was
registered in the IDE.
