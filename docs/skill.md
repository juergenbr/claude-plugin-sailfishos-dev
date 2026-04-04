---
title: Skill Overview
nav_order: 2
---

  pulley menus, C++/QML integration, or platform APIs (Notifications, DBus, Contacts).
  Also activate for questions about app architecture, the .pro file, .spec file, naming
  conventions, or the emulator. Trigger on any mention of: SailfishOS, Sailfish, Silica,
  sfdk, Harbour, ApplicationWindow, PullDownMenu, PageStack, Cover, or sfdk emulator.
version: 1.0.0
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
QML_IMPORT_PATH =
DISTFILES += \
    qml/harbour-myapp.qml \
    qml/pages/MainPage.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-myapp.spec
```

`CONFIG += sailfishapp` pulls in libsailfishapp and sets correct install paths automatically.

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

### This setup: Ubuntu 25.04, SailfishOS 5.0.0.62

```bash
SDK=~/SailfishOS/bin/sfdk

# --- Emulator (i486) ---
$SDK -c target=SailfishOS-5.0.0.62-i486 build
$SDK emulator start
$SDK -c target=SailfishOS-5.0.0.62-i486 \
     -c "device=Sailfish OS Emulator 5.0.0.62" deploy --sdk
$SDK -c "device=Sailfish OS Emulator 5.0.0.62" run harbour-myapp

# --- Physical device aarch64 (Jolla C2, Xperia, Jolla Phone 2026) ---
$SDK -c target=SailfishOS-5.0.0.62-aarch64 build
$SDK -c target=SailfishOS-5.0.0.62-aarch64 \
     -c device="<device-name>" deploy --sdk
$SDK -c device="<device-name>" run harbour-myapp

# --- List devices ---
$SDK device list

# --- Emulator control ---
$SDK emulator start
$SDK emulator stop
$SDK emulator status
$SDK emulator set downscale=no   # fill window at native resolution
```

### Switching build targets (critical workaround)

`make` reuses stale `.o` files from the previous architecture. Always clean first:

```bash
cd ~/repos/sailfishos-dev/<project>
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
sfdk tools target exec SailfishOS-5.0.0.62-aarch64

# Install a package into a target
sfdk tools target package-install SailfishOS-5.0.0.62-aarch64 qt5-qtmultimedia-devel

# List toolings and targets
sfdk tools list
```

---

## Debugging

### Journal logs (most useful)

```bash
# SSH into emulator
ssh -p 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/sdk defaultuser@127.0.0.1

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
sfdk -c target=SailfishOS-5.0.0.62-i486 \
     -c "device=Sailfish OS Emulator 5.0.0.62" debug harbour-myapp
```

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

desktop-file-install --delete-original \
    --dir %{buildroot}%{_datadir}/applications \
    %{buildroot}%{_datadir}/applications/*.desktop

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
