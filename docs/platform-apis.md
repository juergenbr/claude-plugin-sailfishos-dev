---
title: Platform APIs
nav_order: 6
---

# SailfishOS Platform APIs

---

## Notifications (`Nemo.Notifications 1.0`)

```qml
import Nemo.Notifications 1.0

Notification {
    id: notification
    summary: "New message"
    body: "You have 3 unread messages"
    previewSummary: "New message"   // shown in banner
    previewBody: "You have 3 unread messages"
    icon: "image://theme/icon-m-mail"
    appName: "My App"
    category: "x-nemo.messaging.im"

    // Optional
    isTransient: true                // brief, not stored in notification centre
    itemCount: 3
    sound: "/usr/share/sounds/jolla-ringtones/stereo/message.wav"
    timestamp: new Date()
    urgency: Notification.Normal    // .Low / .Normal / .Critical

    onClicked: pageStack.animatorPush("MessagesPage.qml")
}

Button {
    text: "Notify"
    onClicked: notification.publish()
}

// To replace/update:
// set replacesId = notification.replacesId after first publish(), then publish() again

// To close:
notification.close()
```

**Signals:** `clicked()`, `actionInvoked(string name)`, `closed(uint reason)`

**Close reasons:** `Notification.Expired`, `Notification.DismissedByUser`, `Notification.Closed`

---

## DBus (`Nemo.DBus 2.0`)

### Calling a system service

```qml
import Nemo.DBus 2.0

DBusInterface {
    id: upower
    service: "org.freedesktop.UPower"
    path: "/org/freedesktop/UPower"
    iface: "org.freedesktop.UPower"
    bus: DBus.SystemBus
    signalsEnabled: true

    // Receive a D-Bus signal (camelCase the method name):
    function deviceAdded(device) {
        console.log("Device added:", device)
    }
}

// Call a method:
upower.call("GetDisplayDevice", [], function(result) {
    console.log("Display device:", result)
}, function(error) {
    console.log("Error:", error)
})

// Typed call (use for complex types):
dbusIface.typedCall("SomeMethod",
    [{"type": "s", "value": "hello"}, {"type": "i", "value": 42}],
    function(result) { console.log(result) }
)

// Set a property:
dbusIface.setProperty("Volume", 80)
```

**DBus type codes:** `s`=string, `i`=int32, `u`=uint32, `b`=bool, `o`=object-path,
`d`=double, `a`=array, `v`=variant

### Exposing your app as a D-Bus service

```qml
import Nemo.DBus 2.0

DBusAdaptor {
    service: "com.example.myapp"
    iface: "com.example.myapp"
    path: "/com/example/myapp"
    bus: DBus.SessionBus

    function openItem(itemId) {
        // Called when another app invokes this method
        mainPage.openItem(itemId)
    }
}
```

---

## Configuration (`Nemo.Configuration 1.0`)

Persistent key-value store backed by DConf.

```qml
import Nemo.Configuration 1.0

ConfigurationValue {
    id: sortOrder
    key: "/apps/harbour-myapp/sortOrder"
    defaultValue: "name"
}

// Read:
console.log(sortOrder.value)

// Write:
sortOrder.value = "date"

// ConfigurationGroup for namespaced access:
ConfigurationGroup {
    id: config
    path: "/apps/harbour-myapp"

    property string sortOrder: "name"
    property bool showCompleted: true
    property int maxItems: 50
}
config.sortOrder = "date"
```

---

## Contacts (`org.nemomobile.contacts 1.0`)

```qml
import org.nemomobile.contacts 1.0

PeopleModel {
    id: contactsModel
    filterType: PeopleModel.FilterAll
    // FilterAll / FilterFavorites / FilterOnline
}

SilicaListView {
    model: contactsModel
    delegate: ListItem {
        Label { text: model.displayLabel }
        Label { text: model.primaryPhoneNumber; font.pixelSize: Theme.fontSizeSmall; color: Theme.secondaryColor }
    }
}
```

Or use `Sailfish.Contacts 1.0` (Harbour-allowed) for the full contacts picker UI.

---

## Sailfish Pickers (`Sailfish.Pickers 1.0`)

Pre-built platform pickers for selecting content.

```qml
import Sailfish.Pickers 1.0

// Image picker:
PageStack.animatorPush(imagePickerPage)
Component {
    id: imagePickerPage
    ImagePickerPage {
        onSelectedContentPropertiesChanged: {
            myImage.source = selectedContentProperties.filePath
        }
    }
}

// File picker:
Component {
    id: filePickerPage
    FilePickerPage {
        nameFilters: ["*.pdf", "*.txt"]
        onSelectedContentPropertiesChanged: {
            openFile(selectedContentProperties.filePath)
        }
    }
}

// Contact picker:
Component {
    id: contactPickerPage
    ContactSelectPage {
        onContactClicked: {
            console.log("Selected:", contact.displayLabel)
        }
    }
}
```

---

## KeepAlive (`Nemo.KeepAlive 1.2`)

Prevent the display from blanking or the CPU from sleeping during active work.

```qml
import Nemo.KeepAlive 1.2

// Keep display on (e.g. during navigation):
DisplayBlanking {
    id: displayBlanking
    preventBlanking: navigationActive
}

// Keep CPU awake for background processing:
BackgroundJob {
    id: syncJob
    frequency: BackgroundJob.TenMinutes
    onTriggered: {
        doSync()
        finished()  // MUST call finished() when done
    }
}

// Manual background wake:
BackgroundJob {
    id: manualJob
    triggeredBy: BackgroundJob.Connectivity
    onTriggered: { doNetworkSync(); finished() }
}
```

---

## Thumbnailer (`Nemo.Thumbnailer 1.0`)

Generate thumbnails for media files.

```qml
import Nemo.Thumbnailer 1.0

Thumbnail {
    width: Theme.iconSizeExtraLarge
    height: width
    source: model.filePath
    mimeType: "image/jpeg"     // or "video/mp4", etc.
    sourceSize.width: width
    sourceSize.height: height
}
```

---

## Qt Multimedia

Audio playback:

```qml
import QtMultimedia 5.6

Audio {
    id: player
    source: "file:///home/defaultuser/Music/song.mp3"
    onStatusChanged: if (status === Audio.Loaded) play()
}

Button { text: "Play"; onClicked: player.play() }
Button { text: "Pause"; onClicked: player.pause() }
Button { text: "Stop"; onClicked: player.stop() }
```

Video:

```qml
VideoOutput {
    anchors.fill: parent
    source: mediaPlayer
}
MediaPlayer {
    id: mediaPlayer
    source: "file:///home/defaultuser/Videos/clip.mp4"
    autoPlay: true
}
```

Camera:

```qml
Camera { id: camera }
VideoOutput { source: camera; anchors.fill: parent }
Button { text: "Capture"; onClicked: camera.imageCapture.capture() }
```

---

## Amber MPRIS (`Amber.Mpris 1.0`)

Expose media player controls to the system (lock screen, event view).

```qml
import Amber.Mpris 1.0

MprisPlayer {
    id: mpris
    serviceName: "harbour-myapp"
    identity: "My Music App"
    canPlay: true
    canPause: true
    canGoPrevious: playlist.hasPrevious
    canGoNext: playlist.hasNext
    playbackStatus: audio.playbackState === Audio.PlayingState
                    ? Mpris.Playing
                    : Mpris.Paused

    onPlayRequested: audio.play()
    onPauseRequested: audio.pause()
    onNextRequested: playlist.next()
    onPreviousRequested: playlist.previous()

    metaData {
        title: currentTrack.title
        artist: currentTrack.artist
        album: currentTrack.album
        duration: audio.duration * 1000  // microseconds
    }
}
```

---

## Amber Web Authorization (`Amber.Web.Authorization 1.0`)

OAuth 1.0 / 2.0 flows.

```qml
import Amber.Web.Authorization 1.0

OAuth2 {
    id: oauth
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    authorizationEndpoint: "https://example.com/oauth/authorize"
    tokenEndpoint: "https://example.com/oauth/token"
    redirectUri: "harbour-myapp://oauth-callback"
    scopes: ["read", "write"]

    onAccessTokenReceived: {
        console.log("Token:", accessToken)
        apiClient.token = accessToken
    }
    onErrorOccurred: console.warn("OAuth error:", error)
}

Button {
    text: "Login"
    onClicked: oauth.authorize()
}
```

---

## Sailfish Share (`Sailfish.Share 1.0`)

```qml
import Sailfish.Share 1.0

ShareAction {
    id: shareAction
    title: qsTr("Share image")
    mimeType: "image/jpeg"
    resources: [{ "status": "ready", "url": "file:///path/to/image.jpg", "name": "photo.jpg" }]
}

Button {
    text: qsTr("Share")
    onClicked: shareAction.trigger()
}
```

---

## WebView (`Sailfish.WebView 1.0`)

```qml
import Sailfish.WebView 1.0
import Sailfish.WebView.Controls 1.0

Page {
    SilicaWebView {
        id: webView
        anchors.fill: parent
        url: "https://example.com"
        header: PageHeader { title: webView.title }
    }
}
```

---

## Platform paths (libsailfishapp)

In C++, use `SailfishApp::pathTo()` to get correct paths regardless of install location:

```cpp
#include <sailfishapp.h>

// Path to a data file inside the app package:
QString dataPath = SailfishApp::pathTo("data/myfile.json").toLocalFile();
// -> /usr/share/harbour-myapp/data/myfile.json

// Path to the QML root:
QUrl qmlPath = SailfishApp::pathTo("qml/harbour-myapp.qml");
```

In QML, use `Qt.resolvedUrl()` for relative paths from the current QML file.
