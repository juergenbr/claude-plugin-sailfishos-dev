# Sailfish Silica Component Reference

Import: `import Sailfish.Silica 1.0`

---

## ApplicationWindow

Top-level root of every Sailfish app.

```qml
ApplicationWindow {
    initialPage: Component { MainPage {} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations  // inherits from Page
}
```

---

## Page

Single screen. Always fills the window. Width/height auto-sized to screen.

| Property | Type | Description |
|---|---|---|
| `allowedOrientations` | enum | `Orientation.Portrait`, `.Landscape`, `.PortraitInverted`, `.LandscapeInverted`, `.All` |
| `backNavigation` | bool | Whether user can swipe back (default true) |
| `forwardNavigation` | bool | Whether forward swipe is active |
| `status` | enum | `PageStatus.Inactive`, `.Activating`, `.Active`, `.Deactivating` |
| `isPortrait` / `isLandscape` | bool | Current orientation |
| `navigationStyle` | enum | `PageNavigation.Horizontal` (default) or `.Vertical` |
| `showNavigationIndicator` | bool | Edge navigation hint (default true) |

```qml
Page {
    id: page
    allowedOrientations: Orientation.All

    onStatusChanged: {
        if (status === PageStatus.Active) loadData()
    }
}
```

---

## PageStack

Managed by `ApplicationWindow`. Access via `pageStack` from any page.

```qml
pageStack.animatorPush("SecondPage.qml")
pageStack.animatorPush("SecondPage.qml", { title: "Hi" })
pageStack.animatorReplace("NewPage.qml")   // replace without growing stack
pageStack.pop()
pageStack.navigateBack()
pageStack.clear()
pageStack.depth  // number of pages
```

---

## SilicaFlickable

Flickable with Sailfish styling. Required wrapper to host PullDownMenu/PushUpMenu.

```qml
SilicaFlickable {
    anchors.fill: parent
    contentHeight: column.height   // or contentWidth for horizontal

    PullDownMenu { ... }

    Column {
        id: column
        width: parent.width
        // content here
    }

    VerticalScrollDecorator {}
}
```

---

## SilicaListView

Preferred for lists (more performant than Column + Repeater).

```qml
SilicaListView {
    id: listView
    anchors.fill: parent
    model: myModel

    header: PageHeader { title: qsTr("Items") }

    delegate: ListItem {
        id: listItem
        contentHeight: Theme.itemSizeMedium

        Label {
            anchors.verticalCenter: parent.verticalCenter
            x: Theme.horizontalPageMargin
            text: model.name
            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
        }

        onClicked: pageStack.animatorPush("DetailPage.qml", { item: model })
    }

    ViewPlaceholder {
        enabled: listView.count === 0
        text: qsTr("No items")
    }

    VerticalScrollDecorator {}
}
```

---

## SilicaGridView

Grid layout with Sailfish styling. Same pull-menu and scroll-decorator support as SilicaListView.

```qml
SilicaGridView {
    anchors.fill: parent
    cellWidth: width / 3
    cellHeight: cellWidth
    model: photoModel
    delegate: GridItem {
        Image { anchors.fill: parent; source: model.url }
    }
    VerticalScrollDecorator {}
}
```

---

## PullDownMenu / PushUpMenu

Must be a direct child of a `SilicaFlickable` (or SilicaListView/SilicaGridView).
Maximum 4 items. Hide the entire menu if all items would be disabled.

```qml
PullDownMenu {
    MenuItem {
        text: qsTr("Settings")
        onClicked: pageStack.animatorPush("SettingsPage.qml")
    }
    MenuItem {
        text: qsTr("Refresh")
        enabled: !loading
        onClicked: refresh()
    }
}

PushUpMenu {
    MenuItem {
        text: qsTr("Load more")
        onClicked: loadMore()
    }
}
```

---

## PageHeader

Standard page title. Place at top of Column inside SilicaFlickable.

```qml
PageHeader {
    title: qsTr("Settings")
    description: qsTr("Optional subtitle")
}
```

---

## Label

```qml
Label {
    text: qsTr("Hello")
    color: Theme.highlightColor          // for descriptive/secondary text
    // color: Theme.primaryColor         // for primary/interactive text
    font.pixelSize: Theme.fontSizeMedium
    wrapMode: Text.Wrap
    truncationMode: TruncationMode.Fade  // alternative to elide
}
```

---

## TextField / TextArea

Always set both `label` and `placeholderText` with identical strings.

```qml
TextField {
    width: parent.width
    label: qsTr("Username")
    placeholderText: qsTr("Username")
    focus: true
    EnterKey.iconSource: "image://theme/icon-m-enter-next"
    EnterKey.onClicked: nextField.focus = true
}

PasswordField {
    width: parent.width
    label: qsTr("Password")
    placeholderText: qsTr("Password")
    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
    EnterKey.onClicked: doLogin()
}

SearchField {
    width: parent.width
    placeholderText: qsTr("Search")
    onTextChanged: filterModel(text)
}

TextArea {
    width: parent.width
    label: qsTr("Notes")
    placeholderText: qsTr("Notes")
}
```

**EnterKey icon sources:**
- `icon-m-enter-next` — move to next field
- `icon-m-enter-accept` — submit/confirm
- `icon-m-enter-close` — close keyboard
- `icon-m-enter-search` — search action

---

## Button / IconButton

```qml
Button {
    text: qsTr("OK")
    width: Theme.buttonWidthMedium
    onClicked: accept()
}

IconButton {
    icon.source: "image://theme/icon-m-add"
    onClicked: addItem()
}

// Arrange multiple buttons:
ButtonLayout {
    Button { preferredWidth: Theme.buttonWidthMedium; text: qsTr("Cancel") }
    Button { preferredWidth: Theme.buttonWidthMedium; text: qsTr("OK") }
}
```

---

## BackgroundItem / ListItem

`BackgroundItem` — simple touchable area with press highlight.
`ListItem` — adds context menu, remorse actions, and drag support.

```qml
// Simple touchable row
BackgroundItem {
    height: Theme.itemSizeMedium
    onClicked: doSomething()
    Label { anchors.verticalCenter: parent.verticalCenter; x: Theme.horizontalPageMargin; text: "Tap me" }
}

// List item with context menu
ListItem {
    id: listItem
    contentHeight: Theme.itemSizeLarge

    menu: ContextMenu {
        MenuItem {
            text: qsTr("Edit")
            onClicked: openEditor()
        }
        MenuItem {
            text: qsTr("Delete")
            onClicked: listItem.remorseAction("Deleting", function() {
                model.remove(index)
            })
        }
    }

    onClicked: menu.open(listItem)  // or open on long-press (default)
}
```

---

## ComboBox

```qml
ComboBox {
    width: parent.width
    label: qsTr("Sort by")
    currentIndex: 0
    menu: ContextMenu {
        MenuItem { text: qsTr("Name") }
        MenuItem { text: qsTr("Date") }
        MenuItem { text: qsTr("Size") }
    }
    onCurrentIndexChanged: sortBy(currentIndex)
}
```

---

## TextSwitch / Switch

```qml
TextSwitch {
    text: qsTr("Enable notifications")
    description: qsTr("Show alerts for new messages")
    checked: settings.notificationsEnabled
    onCheckedChanged: settings.notificationsEnabled = checked
}
```

---

## Slider

```qml
Slider {
    width: parent.width
    minimumValue: 0
    maximumValue: 100
    value: 50
    stepSize: 1
    label: qsTr("Volume")
    valueText: value + "%"
    onValueChanged: setVolume(value)
}
```

---

## Dialog

A page that is accepted or rejected. Push with `pageStack.animatorPush`.

```qml
// Launching the dialog:
var dialog = pageStack.animatorPush(Qt.resolvedUrl("MyDialog.qml"), { initialText: "hello" })
dialog.accepted.connect(function() { console.log("accepted") })

// MyDialog.qml:
Dialog {
    id: dialog
    property string initialText

    canAccept: textField.text.length > 0

    DialogHeader {
        title: qsTr("New Item")
        // acceptText / cancelText to customize button labels
    }

    TextField {
        id: textField
        width: parent.width
        label: qsTr("Name")
        placeholderText: qsTr("Name")
        text: dialog.initialText
    }

    onAccepted: createItem(textField.text)
}
```

---

## Remorse / RemorseItem / RemorsePopup

Brief countdown before a destructive action executes.

```qml
// In a ListItem (most common):
ListItem {
    onClicked: remorseAction("Deleting", function() { model.remove(index) })
    // or: remorseAction("Deleting", function() { ... }, 4000)  // 4s timeout
}

// Standalone popup (e.g. "Clear all"):
RemorsePopup { id: remorse }
MenuItem {
    text: qsTr("Clear all")
    onClicked: remorse.execute("Clearing all items", function() { model.clear() })
}
```

---

## ViewPlaceholder

Shown when a view is empty.

```qml
ViewPlaceholder {
    enabled: listView.count === 0
    text: qsTr("No items yet")
    hintText: qsTr("Pull down to add your first item")
}
```

---

## DockedPanel

Panel anchored to screen edge that slides in/out.

```qml
DockedPanel {
    id: panel
    width: parent.width
    height: Theme.itemSizeExtraLarge + Theme.paddingLarge
    dock: Dock.Bottom

    Button { text: qsTr("Action"); onClicked: doSomething() }
}
// Open/close:
panel.open = true
```

---

## BusyIndicator / PageBusyIndicator

```qml
BusyIndicator {
    size: BusyIndicatorSize.Large
    anchors.centerIn: parent
    running: loading
}

// Full-page busy (covers content):
PageBusyIndicator { running: initialLoading }
```

---

## SectionHeader / DetailItem / Separator

```qml
SectionHeader { text: qsTr("Account") }

DetailItem {
    label: qsTr("Username")
    value: user.name
}

Separator {
    width: parent.width
    color: Theme.primaryColor
    horizontalAlignment: Qt.AlignHCenter
}
```

---

## Icon

Monochrome icons from the platform icon theme.

```qml
Icon {
    source: "image://theme/icon-m-mail"
    color: Theme.primaryColor          // recolour to any colour
    highlighted: mouseArea.pressed
}
```

Common icon name prefixes: `icon-m-` (medium), `icon-s-` (small), `icon-l-` (large),
`icon-cover-` (cover actions). Browse available icons at
`/usr/share/themes/sailfish-default/meegotouch/icons/` on the emulator.

---

## ScrollDecorator

Always add to scrollable views.

```qml
VerticalScrollDecorator {}
HorizontalScrollDecorator {}
```

---

## Cover / CoverBackground / CoverActionList / CoverAction

```qml
// cover/CoverPage.qml
CoverBackground {
    // Content summarising app state
    Label {
        anchors.centerIn: parent
        text: appState.itemCount + " items"
        font.pixelSize: Theme.fontSizeLarge
    }

    CoverActionList {
        // Max 2 actions
        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: appState.sync()
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-new-note"
            onTriggered: appState.addItem()
        }
    }
}
```

---

## Theme (key properties — see design-guidelines.md for full list)

```qml
// Colors
Theme.primaryColor          // primary text, interactive elements
Theme.highlightColor        // non-interactive / pressed state text
Theme.secondaryColor        // de-emphasized text
Theme.secondaryHighlightColor

// Fonts
Theme.fontSizeTiny / ExtraSmall / Small / Medium / Large / ExtraLarge / Huge
Theme.fontFamily
Theme.fontFamilyHeading

// Item heights (use for contentHeight)
Theme.itemSizeSmall         // single-line row minimum
Theme.itemSizeMedium        // two-line row
Theme.itemSizeLarge         // prominent items, page header
Theme.itemSizeExtraLarge    // image thumbnails

// Spacing
Theme.horizontalPageMargin  // left/right margin
Theme.paddingSmall
Theme.paddingMedium
Theme.paddingLarge          // standard vertical gap

// Icons
Theme.iconSizeSmall / Medium / Large / ExtraLarge / Launcher
```
