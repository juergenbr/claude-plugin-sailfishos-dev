---
title: Harbour Submission
nav_order: 5
---

# Harbour Store Submission Guide

Harbour is the official Jolla app store for SailfishOS. Apps must pass automated QA
validation before appearing in the store.

---

## Naming rules

- Package/binary name **must** start with `harbour-`
  - e.g. `harbour-myapp`, `harbour-weather-viewer`
- This applies to: RPM `Name:`, binary, `.desktop` filename, icon filename
- Avoid `com.jolla`, `com.nokia`, `com.meego`, `org.sailfishos` namespaces

---

## Allowed QML imports

Only the following are permitted in Harbour submissions:

### Sailfish
```
Sailfish.Silica 1.0
Sailfish.Pickers 1.0
Sailfish.Share 1.0
Sailfish.WebView 1.0        (and .Controls, .Pickers, .Popups)
Sailfish.WebEngine 1.0
Sailfish.Secrets 1.0
Sailfish.Crypto 1.0
Sailfish.Media 1.0
Sailfish.Contacts 1.0
Sailfish.Accounts 1.0
Sailfish.Bluetooth 1.0
Sailfish.Telephony 1.0
```

### Qt
```
QtQml 2.0 – 2.2
QtQuick 2.0 – 2.6
QtQuick.Layouts 1.0 – 1.1
QtQuick.LocalStorage 2.0
QtQuick.Particles 2.0
QtQuick.Window 2.0 – 2.2
QtQuick.XmlListModel 2.0
QtMultimedia 5.0 – 5.6
QtWebSockets 1.0 – 1.1
QtSensors 5.0 – 5.2
QtGraphicalEffects 1.0
QtPositioning 5.2, 5.4
QtLocation 5.0, 5.3, 5.4
QtQml.Models 2.1 – 2.3
QtFeedback 5.0
```

### Platform / third-party
```
Nemo.Notifications 1.0
Nemo.DBus 2.0
Nemo.Configuration 1.0
Nemo.Thumbnailer 1.0
Nemo.KeepAlive 1.2
org.nemomobile.contacts 1.0
Amber.Web.Authorization 1.0
Amber.Mpris 1.0
org.freedesktop.contextkit 1.0
io.thp.pyotherside 1.0 – 1.5
org.kde.bluezqt 1.0
```

**Forbidden patterns** (except as whitelisted above):
`Amber.*`, `Bluetooth.*`, `Meego.*`, `Mer.*`, `Nemo.*`, `NemoMobile.*`, `Sailfish.*`,
`Qt*`, `org.nemomobile.*`, `org.sailfishos.*`, `com.jolla.*`, `com.nokia.*`, `com.meego.*`

---

## Allowed C++ libraries (link against these only)

### Core
- `libsailfishapp.so.1`, `libsailfishsilica.so.1`, `libmdeclarativecache5.so.0`
- Qt 5: `libQt5Core.so.5`, `libQt5Quick.so.5`, `libQt5Qml.so.5`, `libQt5Network.so.5`, `libQt5Gui.so.5`
- Additional Qt: Concurrent, Multimedia, Sql, Svg, Xml, XmlPatterns, DBus, Sensors, Positioning, WebSockets, Location (all `.so.5`)

### Security
- `libsailfishcrypto.so.0`, `libsailfishsecrets.so.0`, `libsailfishsecretscrypto.so.0`
- `libsailfishaccounts.so.0`, `libamberwebauthorization.so.1`
- `libssl.so.1.1`, `libcrypto.so.1.1`

### Media / audio
- `libpulse.so.0`, `libpulse-simple.so.0`, `libaudioresource.so.1`
- `libogg.so.0`, `libvorbis.so.0`, `libsndfile.so.1`

### Utilities
- `libmlite5.so.0`, `libcurl.so.4`, `libxml2.so.2`, `libsqlite3.so.0`, `libz.so.1`
- `libnemonotifications-qt5.so.1`, `libnemothumbnailer-qt5.so.1`, `libkeepalive.so.1`
- `libKF5BluezQt.so.6`

### Web
- `libqt5embedwidget.so.1`, `libsailfishwebengine.so.1`

### Graphics
- `libEGL.so.1`, `libGLESv1_CM.so.1`, `libGLESv2.so.2`
- All SDL2 libraries, `libwayland-client.so.0`, `libwayland-cursor.so.0`, `libwayland-egl.so.1`

### Standard C/C++ runtime
- `libc.so.6`, `libstdc++.so.6`, `libm.so.6`, `libpthread.so.0`, `libdl.so.2`, etc.

**Not allowed:** `libQt5WebKit.so.5` (removed since 4.5.0)

---

## Allowed permissions (X-Sailjail section in .desktop)

```ini
[X-Sailjail]
Permissions=Internet;Notifications
OrganizationName=com.example
ApplicationName=harbour-myapp
```

Allowed permission tokens:
`Audio`, `Bluetooth`, `Camera`, `Internet`, `Location`, `MediaIndexing`, `Microphone`,
`NFC`, `RemovableMedia`, `UserDirs`, `WebView`, `Documents`, `Downloads`, `Music`,
`Pictures`, `PublicDir`, `Videos`, `Compatibility`, `Secrets`, `Contacts`, `Accounts`

---

## App icon requirements

| Size | Path in package |
|---|---|
| 86×86 px | `/usr/share/icons/hicolor/86x86/apps/harbour-myapp.png` |
| 108×108 px | `/usr/share/icons/hicolor/108x108/apps/harbour-myapp.png` |
| 128×128 px | `/usr/share/icons/hicolor/128x128/apps/harbour-myapp.png` |
| 172×172 px | `/usr/share/icons/hicolor/172x172/apps/harbour-myapp.png` |

Icons must be square PNG files. No transparency requirement.

---

## .desktop file

```ini
[Desktop Entry]
Type=Application
Name=My App
Icon=harbour-myapp
Exec=harbour-myapp
X-Nemo-Application-Type=silica-qt5
X-Nemo-Single-Instance=yes

[X-Sailjail]
Permissions=Internet
OrganizationName=com.example
ApplicationName=harbour-myapp
```

---

## RPM spec requirements

- `Name:` must be `harbour-<appname>`
- No `%pre` / `%post` / `%preun` / `%postun` scriptlets that install/modify files
  outside standard RPM install paths
- Files must install only to: `%{_bindir}`, `%{_datadir}/%{name}`,
  `%{_datadir}/applications`, `%{_datadir}/icons`
- Must not require packages that aren't in the Harbour-allowed list
- `BuildRequires` should reference `pkgconfig(sailfishapp)`, `pkgconfig(Qt5Core)`, etc.

---

## Validation process

The Harbour validator runs automatically when you build via sfdk. To run it manually:

```bash
# The SDK's built-in validator checks the RPM:
~/SailfishOS/bin/sfdk -c target=SailfishOS-5.0.0.62-aarch64 build
# Then inspect RPMS/*.rpm — the build output shows any violations
```

Common validator failures:
- QML imports not on the allowed list
- Linked libraries not on the allowed list
- Missing icon sizes
- `Name:` not starting with `harbour-`
- `.desktop` file missing `X-Sailjail` section

---

## Submission steps

1. Build a release RPM with aarch64 target
2. Run the Harbour validator (automated during build)
3. Log in to https://harbour.jolla.com
4. Create a new application entry
5. Upload the `.rpm` file
6. Fill in name, description, screenshots, category
7. Submit for QA review
8. QA team reviews (typically 1–5 business days)
9. App appears in store after approval

---

## Screenshots

- Minimum 1, recommended 3–5
- Taken on a real device or emulator at native resolution
- Portrait orientation preferred
- Show actual app content, not placeholder data
- Accepted formats: PNG or JPEG
