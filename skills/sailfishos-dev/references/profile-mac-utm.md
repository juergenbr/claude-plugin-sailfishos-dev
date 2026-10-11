# Host profile: mac-utm

macOS on Apple silicon. The official macOS SDK (Intel + VirtualBox) cannot run here,
so the complete SDK lives inside a dedicated Linux VM and all SDK operations go
through SSH. This profile documents that setup.

Use this profile when `scripts/detect-host.sh` reports `mac-utm`.
(The profile `sdk-vm-internal` means the agent already runs inside the VM — then use
the commands below *without* the `ssh sailfishdev` wrapper.)

## Architecture

```
macOS host (Apple silicon)
└── UTM VM "SailfishOSDev" — Ubuntu 24.04 LTS ARM64, Apple Virtualization
    ├── Sailfish SDK (sfdk + IDE are x86_64 → run under Rosetta)
    ├── Docker build engine (linux/386 image → runs under qemu-user-static)
    ├── Build targets (discover with `sfdk tools list`)
    └── Sailfish OS Emulator under QEMU (virtio-gpu UI, SSH on localhost:2223)
```

Host access: `ssh sailfishdev` (alias in `~/.ssh/config`). The VM bundle lives at
`~/utm-seed/SailfishOSDev.utm` on the Mac. Full setup documentation including all
credentials and rescue procedures: `~/utm-seed/README-dev-environment.md` on the Mac
and `~/README-dev-environment.md` inside the VM.

## VM lifecycle

```bash
/opt/homebrew/bin/utmctl start SailfishOSDev
/opt/homebrew/bin/utmctl status SailfishOSDev
/opt/homebrew/bin/utmctl stop SailfishOSDev     # also shuts down the emulator
ssh -o ConnectTimeout=5 sailfishdev 'echo ok'   # verify it is up before SDK work
```

## SDK invocation (always through the VM)

sfdk runs inside the VM. Every build/deploy also needs
`DOCKER_DEFAULT_PLATFORM=linux/386` (the build engine image is i386):

```bash
ssh sailfishdev 'DOCKER_DEFAULT_PLATFORM=linux/386 ~/SailfishOS/bin/sfdk <args>'
```

Interactive engine shells:

```bash
ssh -t sailfishdev 'DOCKER_DEFAULT_PLATFORM=linux/386 ~/SailfishOS/bin/sfdk engine exec'
```

## Workspace constraint

Projects must live inside the VM (the build engine mounts the VM user's home).
The Mac is not part of the build path. Push project sources in:

```bash
rsync -a --delete ~/my-project/ sailfishdev:~/sailfish-workspace/my-project/
# or: scp -r
```

Keep project sources on the Mac as the single source of truth and sync into the VM
before building — or edit directly in the VM. If sfdk reports
`The command needs to be used under Sailfish SDK workspace`, the project is outside
the mounted home.

## Build engine (patched linux/386 image)

- Docker image: `sailfish-sdk-build-engine:saildev`, verified with
  `docker image inspect sailfish-sdk-build-engine:saildev --format '{{.Os}}/{{.Architecture}}'`
  → must print `linux/386`.
- The image is patched (no-op setarch/iptables, disabled udisks oneshot) so it boots
  under qemu-user-static. **After every SDK update re-run** `~/patch-build-engine.sh`
  inside the VM, then re-verify the architecture.
- After VM reboots, binfmt handlers are restored automatically by systemd
  (`/etc/binfmt.d/qemu-i386.conf`, `rosetta-binfmt.service`). Sanity check:
  `docker run --rm --platform linux/386 busybox uname -m` → `i686`.

## Emulator (QEMU — sfdk emulator does NOT work here)

VirtualBox does not exist on Apple silicon; the emulator is a QEMU setup with an
Arch 32 LTS kernel (the stock emulator kernel has no DRM device QEMU can provide,
so the UI would never start). Start it inside the VM:

```bash
# headless (default, e.g. for CI-style deploys)
ssh sailfishdev '~/start-emu.sh'

# windowed inside the VM's xfce desktop (shows the Sailfish UI)
ssh sailfishdev 'EMU_DISPLAY="-display sdl,show-cursor=on" ~/start-emu.sh'
```

- Boot takes 2–5 minutes under software emulation; SSH becomes available first.
- `sfdk emulator start/stop/status` will fail on this host — use the script and
  `pgrep -f qemu-system-i386` instead. Stop: `ssh sailfishdev 'kill $(cat /tmp/sfos-emu.pid)'`.

## Emulator SSH

Port 2223 exists **inside the VM**. From the Mac, jump through the VM:

```bash
# from the Mac
ssh -J sailfishdev -p 2223 -i SailfishOS/vmshare/ssh/private_keys/sdk defaultuser@localhost
# (add -i ~/utm-seed/... or copy the key; the path below is relative to the VM home)

# from inside the VM (e.g. during IDE deploy)
ssh -p 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/sdk defaultuser@localhost
```

## IDE

The Sailfish IDE (Qt Creator) runs inside the VM's graphical session (xfce):
open the UTM window, log in (`saildev`), run `~/SailfishOS/bin/qtcreator`.
It is an x86_64 binary translated by Rosetta — first launch is slow; that is normal.

Deploy from the IDE to the emulator requires a device entry `127.0.0.1:2223`
(user `defaultuser`, key `~/SailfishOS/vmshare/ssh/private_keys/sdk`).
CLI fallback for deploys:

```bash
ssh sailfishdev 'scp -P 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/sdk \
  ~/RPMS/app.rpm root@localhost:/tmp/ && \
  ssh -p 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/sdk root@localhost \
  "rpm -Uvh --nodeps /tmp/app.rpm"'
```

## Rescue

- VM serial console (from the Mac): `cat /dev/ttys003` (read),
  `printf 'text\n' > /dev/ttys003` (write) — get the current ptty via
  `osascript -e 'tell application "UTM" to get address of serial port 1 of virtual machine named "SailfishOSDev"'`.
- Emulator serial console (inside the VM): `python3 ~/emu-serial.py 6 "root" "sailroot2026" "command"`.
- Emulator screen capture: QEMU monitor at `/tmp/emu-mon` (`screendump /tmp/screen.ppm`).
- All credentials and recovery paths are listed in the README-dev-environment.md
  mentioned above.
