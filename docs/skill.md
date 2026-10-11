---
title: Skill Overview
nav_order: 2
---

# SailfishOS App Development

You are a SailfishOS expert. Answer with precision: write correct Silica QML, give exact
sfdk commands, and advise accurately on Harbour requirements. When the user's question
touches a specific domain, read the matching reference file before answering.

## Reference files (read as needed)

| File | When to read it |
|---|---|
| `references/silica-components.md` | Any question about Silica QML types, their properties, signals, usage patterns |
| `references/design-guidelines.md` | Theme.* properties, spacing, colours, pitfalls, UX patterns |
| `references/harbour.md` | Harbour store submission, allowed APIs, RPM spec, icon/screenshot rules |
| `references/platform-apis.md` | Notifications, DBus, Contacts, Pickers, KeepAlive, Thumbnailer |
| `references/profile-ubuntu-native.md` | Before ANY build/deploy/emulator/debug command when the host is the Ubuntu dev machine |
| `references/profile-mac-utm.md` | Before ANY build/deploy/emulator/debug command when the host is a Mac with the UTM VM |

---

## Host profiles — Step 0: detect before running anything

The SDK can run in different host setups and almost every operational command
(sfdk invocation, workspace path, emulator control, SSH endpoints) differs
between them. Before the first build/deploy/debug command in a session, detect
the profile and read the matching reference file. Never mix commands across
profiles.

```bash
# from the repository root
scripts/detect-host.sh
```

| Profile | Meaning | Read |
|---|---|---|
| `ubuntu-native` | Linux machine with the SDK installed natively (Docker build engine, VirtualBox emulator) | `references/profile-ubuntu-native.md` |
| `mac-utm` | macOS (Apple silicon) machine; SDK runs inside the "SailfishOSDev" UTM Linux VM, all commands go over SSH | `references/profile-mac-utm.md` |
| `sdk-vm-internal` | You are already inside the UTM VM — use local sfdk commands without the SSH wrapper | `references/profile-mac-utm.md` (same setup, skip the `ssh sailfishdev` prefix) |
| `unknown` | No supported environment on this machine — tell the user; do not guess commands | — |

Detection is overrideable: if `~/.config/sailfishos-dev/profile` exists, its content
wins over the probes (useful for pinning unusual setups).

Summary of what changes per profile:

| Aspect | `ubuntu-native` | `mac-utm` |
|---|---|---|
| sfdk call | local `~/SailfishOS/bin/sfdk` | `ssh sailfishdev 'DOCKER_DEFAULT_PLATFORM=linux/386 ~/SailfishOS/bin/sfdk …'` |
| Build engine | host Docker | Docker inside the VM (linux/386, patched image) |
| Workspace | host home (discover mounts, don't assume) | inside the VM; sync sources from the Mac |
| Emulator control | `sfdk emulator start` (VirtualBox) | `~/start-emu.sh` in the VM (QEMU; `sfdk emulator` unavailable) |
| Emulator SSH | host port 2223 | VM port 2223; from the Mac via SSH jump (`-J sailfishdev`) |
| IDE | host Qt Creator | Qt Creator inside the VM's xfce session |

---

## Technology stack

- **Qt 5 + Qt Quick 2** — foundation
- **Sailfish Silica** — QML component set (`import Sailfish.Silica 1.0`)
- **libsailfishapp** — convenience library: correct app paths, boostable startup, `SailfishApp::main()`
- **sfdk** — CLI build/deploy/emulator tool (at `~/SailfishOS/bin/sfdk`)
- **RPM** — packaging format; apps submitted to Harbour as `.rpm`

---

## App architecture

### Minimal QML-only project

```
harbour-myapp/
├── harbour-myapp.pro
├── rpm/
│   └── harbour-myapp.spec
├── qml/
│   ├── harbour-myapp.qml          ← ApplicationWindow root
│   ├── pages/
│   │   ├── MainPage.qml
│   │   └── SecondPage.qml
│   └── cover/
│       └── CoverPage.qml
└── icons/
    └── 86x86/harbour-myapp.png
```

### .pro file (qmake)

```qmake
TARGET = harbour-myapp
CONFIG += sailfishapp
SOURCES += src/harbour-myapp.cpp   # omit for QML-only

# .desktop must be installed explicitly — CONFIG += sailfishapp does NOT auto-generate it
desktop.files = harbour-myapp.desktop
desktop.path = /usr/share/applications
INSTALLS += desktop

DISTFILES += \
    harbour-myapp.desktop \
    qml/harbour-myapp.qml \
    qml/pages/MainPage.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-myapp.spec

icons86.files = icons/86x86/harbour-myapp.png
icons86.path = /usr/share/icons/hicolor/86x86/apps
icons108.files = icons/108x108/harbour-myapp.png
icons108.path = /usr/share/icons/hicolor/108x108/apps
icons128.files = icons/128x128/harbour-myapp.png
icons128.path = /usr/share/icons/hicolor/128x128/apps
icons172.files = icons/172x172/harbour-myapp.png
icons172.path = /usr/share/icons/hicolor/172x172/apps
INSTALLS += icons86 icons108 icons128 icons172
```

`CONFIG += sailfishapp` pulls in libsailfishapp and sets correct install paths automatically.

You must also create `harbour-myapp.desktop` in the project root:

```ini
[Desktop Entry]
Type=Application
Name=My App
Icon=harbour-myapp
Exec=harbour-myapp
X-Nemo-Application-Type=silica-qt5
X-Nemo-Single-Instance=yes

[X-Sailjail]
Permissions=
OrganizationName=com.example
ApplicationName=harbour-myapp
```

### main.cpp (C++/QML hybrid)

```cpp
#include <sailfishapp.h>

int main(int argc, char *argv[])
{
    return SailfishApp::main(argc, argv);
}
```

`SailfishApp::main()` creates `QGuiApplication` + `QQuickView`, loads
`qml/<TARGET>.qml`, and enters the event loop. No boilerplate needed.

### ApplicationWindow (root QML)

```qml
import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow {
    initialPage: Component { MainPage {} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
```

### Page structure

```qml
import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: doRefresh()
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("My App") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Hello Sailfish")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap
            }
        }

        VerticalScrollDecorator {}
    }
}
```

### App cover

```qml
import QtQuick 2.2
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        anchors.centerIn: parent
        text: qsTr("My App")
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.primaryColor
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: doRefresh()
        }
    }
}
```

### Page navigation

```qml
// Push a new page
pageStack.animatorPush(Qt.resolvedUrl("SecondPage.qml"))
pageStack.animatorPush(Qt.resolvedUrl("SecondPage.qml"), { param: value })

// Replace current page (avoids growing the stack)
pageStack.animatorReplace(Qt.resolvedUrl("MainPage.qml"))

// Pop back
pageStack.pop()
pageStack.navigateBack()
```

---

## C++ integration

### Expose a type via qmlRegisterType

```cpp
// In main.cpp, before SailfishApp::main():
qmlRegisterType<MyModel>("com.example.myapp", 1, 0, "MyModel");
```

```qml
import com.example.myapp 1.0

MyModel { id: myModel }
```

### Expose a singleton via setContextProperty

```cpp
auto *engine = SailfishApp::createView();
engine->rootContext()->setContextProperty("AppState", new AppState(engine));
engine->setSource(SailfishApp::pathTo("qml/harbour-myapp.qml"));
engine->show();
```

### Q_PROPERTY and Q_INVOKABLE

```cpp
class AppState : public QObject {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    Q_INVOKABLE void increment() { ++m_count; emit countChanged(); }
    int count() const { return m_count; }
signals:
    void countChanged();
private:
    int m_count = 0;
};
```

---

## Build, deploy, run (sfdk)

### Workspace constraint

Projects must live where the build engine can see them (the mounted paths —
normally the SDK user's home). The exact location and how to verify it differ per
host profile: read `references/profile-ubuntu-native.md` or
`references/profile-mac-utm.md`. If you get
`The command needs to be used under Sailfish SDK workspace`, the project is outside
the mounted paths — move or sync it according to the profile file.

### Discover targets and devices (never assume a version)

```bash
sfdk tools list          # installed targets, e.g. SailfishOS-5.1.0.11-{i486,armv7hl,aarch64}
sfdk device list         # registered devices, e.g. "Sailfish OS Emulator <version>"
```

Pick the target by device architecture:

- Emulator: `i486`
- Phones: `armv7hl` or `aarch64` — if unknown, check on the phone
  (`rpm -q --qf '%{arch}' systemd`); when in doubt, build both.

### Standard build / deploy / run flow

Commands below are written for a local sfdk (`ubuntu-native`, or
`sdk-vm-internal`). On `mac-utm`, run them inside the VM and prefix as shown in
`references/profile-mac-utm.md`. Emulator control is profile-specific:
`sfdk emulator start` requires VirtualBox (`ubuntu-native` only) — on `mac-utm`
use the VM's emulator launcher script instead.

```bash
SDK=~/SailfishOS/bin/sfdk

# --- Build for the target ---
$SDK -c target=<target> build

# --- Deploy + run on a device (device names from `sfdk device list`) ---
$SDK -c target=<target> -c device="<device-name>" deploy --sdk
$SDK -c device="<device-name>" run harbour-myapp

# --- Debug on a device ---
$SDK -c target=<target> -c device="<device-name>" debug harbour-myapp
```

Example against the emulator with an installed 5.1.0.11 tooling:

```bash
$SDK -c target=SailfishOS-5.1.0.11-i486 build
$SDK -c target=SailfishOS-5.1.0.11-i486 \
     -c "device=Sailfish OS Emulator 5.1.0.11" deploy --sdk
$SDK -c "device=Sailfish OS Emulator 5.1.0.11" run harbour-myapp
```

The same pattern applies to physical devices (Jolla C2, Xperia, Jolla Phone 2026)
with their matching target.

### Switching build targets (critical workaround)

`make` reuses stale `.o` files from the previous architecture. Always clean first:

```bash
cd <your-project-dir>   # inside the workspace of your host profile
rm -f *.o Makefile .qmake.stash harbour-myapp
rm -f RPMS/*.rpm
~/SailfishOS/bin/sfdk -c target=<new-target> build
```

**Symptoms of stale artifacts:**
- `make: Nothing to be done for 'first'.` right after switching target
- `file not recognized: file format not recognized` during link
- `has wrong architecture` or `nothing provides 'libc.so.6()(64bit)'` during deploy

### Other useful sfdk commands

```bash
# Shell inside the build engine
sfdk engine exec

# Shell inside a target (install packages, inspect sysroot)
sfdk tools target exec <target>

# Install a package into a target
sfdk tools target package-install <target> qt5-qtmultimedia-devel

# List toolings and targets
sfdk tools list
```

---

## Debugging

### Journal logs (most useful)

SSH into the emulator the way your host profile provides (see the profile
reference file): on `ubuntu-native` it listens on local port 2223; on `mac-utm`
port 2223 lives inside the VM and needs an SSH jump from the Mac.

```bash
# ubuntu-native: ssh -p 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/sdk defaultuser@127.0.0.1
# mac-utm (from the Mac): ssh -J sailfishdev -p 2223 -i <key path> defaultuser@localhost

# On the device/emulator, follow app logs:
journalctl -f | grep harbour-myapp

# Or as nemo (for user-session services):
journalctl --user -f
```

### QML console debugging

```qml
Component.onCompleted: console.log("page loaded, count =", myModel.count)
onSomeSignal: console.warn("unexpected state:", JSON.stringify(data))
```

### GDB via IDE

In Qt Creator: select the kit, press F5 (Debug). F9 = breakpoint, F10 = step over,
F11 = step into, Shift+F11 = step out. Works identically for emulator and device.

### sfdk debug (CLI GDB)

```bash
sfdk -c target=<target> -c "device=<device-name>" debug harbour-myapp
```

(Targets and device names come from `sfdk tools list` / `sfdk device list`; on
`mac-utm` run inside the VM with the `DOCKER_DEFAULT_PLATFORM` prefix.)

---

## RPM spec essentials

```spec
Name:       harbour-myapp
Version:    1.0.0
Release:    1
Summary:    My application summary
License:    BSD
Source0:    %{name}-%{version}.tar.bz2
BuildRequires: pkgconfig(sailfishapp) >= 1.0.2
BuildRequires: pkgconfig(Qt5Core)
BuildRequires: pkgconfig(Qt5Qml)
BuildRequires: pkgconfig(Qt5Quick)
BuildRequires: desktop-file-utils

%description
Longer description of the application.

%prep
%autosetup

%build
%qmake5 %{name}.pro
%make_build

%install
%qmake5_install

%files
%{_bindir}/%{name}
%{_datadir}/%{name}/
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
```

Key rules: name **must** start with `harbour-`. No `%post`/`%pre` scriptlets that install
files outside `%{_datadir}` and `%{_bindir}`.

---

## Naming conventions

- App binary and package: `harbour-<appname>` (required for Harbour)
- QML import namespace: `com.<yourname>.<appname>` (for C++ types you register)
- Desktop file: `harbour-<appname>.desktop`
- Icon: `harbour-<appname>.png` at 86×86, 108×108, 128×128, 172×172

---

## Common patterns quick-reference

```qml
// ListItem with context menu
SilicaListView {
    model: myModel
    delegate: ListItem {
        id: listItem
        Label { text: model.name; color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor }
        menu: ContextMenu {
            MenuItem { text: qsTr("Delete"); onClicked: listItem.remorseAction("Deleting", function() { myModel.remove(index) }) }
        }
    }
    VerticalScrollDecorator {}
}

// Empty-state placeholder
ViewPlaceholder {
    enabled: listView.count === 0
    text: qsTr("No items")
    hintText: qsTr("Pull down to add")
}

// Remorse popup (standalone)
RemorsePopup { id: remorse }
MenuItem {
    text: qsTr("Clear all")
    onClicked: remorse.execute("Clearing", function() { myModel.clear() })
}

// TextField with proper labeling
TextField {
    width: parent.width
    label: qsTr("Email")
    placeholderText: qsTr("Email")
    inputMethodHints: Qt.ImhEmailCharactersOnly
    EnterKey.iconSource: "image://theme/icon-m-enter-next"
    EnterKey.onClicked: passwordField.focus = true
}

// Dialog
pageStack.animatorPush(Qt.resolvedUrl("MyDialog.qml"))
// In MyDialog.qml:
Dialog {
    DialogHeader { title: qsTr("Confirm") }
    onAccepted: doSomething()
}
```
