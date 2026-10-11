# sailfishos-dev

SailfishOS app development skill. Teaches Claude how to develop, build, deploy, debug,
and publish SailfishOS applications using the Sailfish SDK, Silica QML, and sfdk CLI.

## Skill

- **sailfishos-dev** — Covers app architecture, Silica components, Theme design properties,
  sfdk build/deploy/run commands, C++/QML integration, debugging, platform APIs
  (Notifications, DBus, Contacts, Pickers), and Harbour store submission.

## Invoke

`/sailfishos-dev` — or it activates automatically when you ask about SailfishOS topics.

## Host profiles

The skill auto-detects where it is running (`scripts/detect-host.sh`) and switches
its build/deploy/emulator instructions accordingly:

- **ubuntu-native** — the dedicated Ubuntu dev notebook (Docker build engine, VirtualBox emulator)
- **mac-utm** — macOS on Apple silicon; the Sailfish SDK runs inside the "SailfishOSDev" UTM Linux VM and all commands go over SSH
