---
title: Design Guidelines
nav_order: 4
---

# SailfishOS Design Guidelines & Theme Reference

---

## Theme — full property reference

### Colors

| Property | Purpose |
|---|---|
| `Theme.primaryColor` | Primary text; interactive element labels |
| `Theme.secondaryColor` | De-emphasized / secondary text |
| `Theme.highlightColor` | Non-interactive text; pressed-state highlight |
| `Theme.secondaryHighlightColor` | Less prominent highlight |
| `Theme.highlightBackgroundColor` | Background behind selected text |
| `Theme.highlightDimmerColor` | Darker highlight shade for dimming |
| `Theme.darkPrimaryColor` | Primary text on light backgrounds (e.g. documents) |
| `Theme.darkSecondaryColor` | Secondary text on light backgrounds |
| `Theme.lightPrimaryColor` | Primary text on dark backgrounds (e.g. video) |
| `Theme.lightSecondaryColor` | Secondary text on dark backgrounds |
| `Theme.errorColor` | Validation errors |
| `Theme.overlayBackgroundColor` | System dialogs over the app |

**Rule:** Interactive labels/icons use `primaryColor`. Non-interactive, decorative, or pressed-state elements use `highlightColor`.

### Fonts

| Property | Use |
|---|---|
| `Theme.fontSizeTiny` | Status-bar micro text |
| `Theme.fontSizeExtraSmall` | Timestamps, metadata |
| `Theme.fontSizeSmall` | Secondary body text |
| `Theme.fontSizeMedium` | Default Label size; most body text |
| `Theme.fontSizeLarge` | Section headings, cover labels |
| `Theme.fontSizeExtraLarge` | Page-level headings |
| `Theme.fontSizeHuge` | Hero text, very prominent displays |
| `Theme.fontFamily` | Body font family |
| `Theme.fontFamilyHeading` | Heading font family |

`fontSizeTinyBase` … `fontSizeHugeBase` — same sizes but unaffected by the user's
accessibility font-size setting. Prefer the non-Base variants so users with large fonts
benefit.

### Item sizes (use for `contentHeight`, `height`)

| Property | Use |
|---|---|
| `Theme.itemSizeExtraSmall` | Smallest controls, pulley menu entries |
| `Theme.itemSizeSmall` | Minimum touch-target height; single-line list items |
| `Theme.itemSizeMedium` | Two-line list items (most common) |
| `Theme.itemSizeLarge` | Multi-line items; PageHeader height |
| `Theme.itemSizeExtraLarge` | Thumbnail delegates |
| `Theme.itemSizeHuge` | Full-screen grid thumbnails |

**Rule:** No interactive element should be shorter than `Theme.itemSizeSmall`.

### Spacing

| Property | Use |
|---|---|
| `Theme.horizontalPageMargin` | Left/right content margin on pages |
| `Theme.paddingSmall` | Tight spacing between closely related elements |
| `Theme.paddingMedium` | Normal inter-component gap |
| `Theme.paddingLarge` | Major section separation; default Column spacing |

### Icon sizes

| Property | Use |
|---|---|
| `Theme.iconSizeExtraSmall` | Status area indicators |
| `Theme.iconSizeSmall` | Cover action icons, event feed |
| `Theme.iconSizeSmallPlus` | Notification icons |
| `Theme.iconSizeMedium` | List-item icons (most common) |
| `Theme.iconSizeLarge` | Prominent icon displays |
| `Theme.iconSizeExtraLarge` | Large icon displays |
| `Theme.iconSizeLauncher` | Home-screen grid icons |

### Button widths

| Property | Meaning |
|---|---|
| `Theme.buttonWidthTiny` | Icon buttons |
| `Theme.buttonWidthExtraSmall` | Three fit portrait width |
| `Theme.buttonWidthSmall` | Two fit portrait width (default single button) |
| `Theme.buttonWidthMedium` | Medium |
| `Theme.buttonWidthLarge` | One fills portrait width |

### Opacity

| Property | Use |
|---|---|
| `Theme.opacityFaint` | Unavailable/placeholder content |
| `Theme.opacityLow` | Disabled content |
| `Theme.opacityHigh` | De-emphasized content |
| `Theme.opacityOverlay` | Overlay elements |

### Motion & display

| Property | Use |
|---|---|
| `Theme.flickDeceleration` | Apply to custom Flickable for consistent feel |
| `Theme.maximumFlickVelocity` | Apply to custom Flickable |
| `Theme.startDragDistance` | Threshold for initiating drag |
| `Theme.pixelRatio` | Display DPI ratio |
| `Theme.colorScheme` | `Theme.LightOnDark` or `Theme.DarkOnLight` |

### Cover sizes

```qml
Theme.coverSizeSmall   // QSize: small multitasking cover
Theme.coverSizeLarge   // QSize: large multitasking cover
```

---

## Layout conventions

```qml
// Standard page content margin
x: Theme.horizontalPageMargin
width: parent.width - 2 * Theme.horizontalPageMargin

// Standard Column spacing between major sections
Column {
    spacing: Theme.paddingLarge
}

// List item with icon + text
ListItem {
    contentHeight: Theme.itemSizeMedium

    Image {
        id: icon
        anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin; verticalCenter: parent.verticalCenter }
        width: Theme.iconSizeMedium; height: width
        source: model.iconUrl
    }
    Label {
        anchors { left: icon.right; leftMargin: Theme.paddingMedium; right: parent.right; rightMargin: Theme.horizontalPageMargin; verticalCenter: parent.verticalCenter }
        text: model.name
        truncationMode: TruncationMode.Fade
    }
}
```

---

## Gesture navigation

Sailfish apps navigate by gesture, not buttons:

- **Swipe left** — go back (pops page stack)
- **Swipe right** — go forward (if enabled)
- **Pull down** — PullDownMenu
- **Pull up** — PushUpMenu
- **Long-press on ListItem** — opens ContextMenu
- **Task switcher** — swipe up from bottom edge (shows covers)

**Do not** add Back buttons or toolbar navigation buttons. The platform handles all back
navigation via edge swipes. Use `Dialog` for accept/cancel flows — it provides the correct
gestures automatically.

---

## Orientations

```qml
// Most apps: portrait only
allowedOrientations: Orientation.Portrait

// All orientations:
allowedOrientations: Orientation.All

// Inherit from app-level (preferred — lets users set per-app):
allowedOrientations: defaultAllowedOrientations

// Landscape-only (e.g. video player):
allowedOrientations: Orientation.Landscape | Orientation.LandscapeInverted
```

---

## Common pitfalls

### 1. Missing cover actions
Provide a meaningful cover — show app state summary and at least one CoverAction for the
most common task. A blank CoverBackground is technically valid but poor UX.

### 2. Wrong color for context
- `primaryColor` for interactive / actionable labels
- `highlightColor` for static / descriptive / pressed labels
- On press: `color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor`

### 3. Touch targets too small
Minimum height = `Theme.itemSizeSmall`. Most interactive rows should be `itemSizeMedium`
or larger.

### 4. Too many pulley menu items
Maximum 4. Platform apps use 1–3. If you need more, push a settings page or use a
ContextMenu.

### 5. Showing disabled pulley menus
```qml
PullDownMenu {
    visible: someConditionThatMakesItemsEnabled
    MenuItem { text: qsTr("Do thing") }
}
```
Hide the entire menu rather than showing only disabled items.

### 6. Missing ScrollDecorator
Every SilicaFlickable/SilicaListView/SilicaGridView needs `VerticalScrollDecorator {}`.

### 7. Back buttons or toolbar buttons
Remove them. Use edge-swipe navigation and PullDownMenu instead.

### 8. Text fields without label + placeholderText
Both must be set to the same descriptive string.

### 9. Enter key not configured
Every TextField should set `EnterKey.iconSource` and `EnterKey.onClicked` to advance
focus, submit, search, or close keyboard.

### 10. Deep page stacks
After completing a flow (e.g. a wizard), use `pageStack.animatorReplace()` or
`pageStack.clear()` + push rather than leaving all wizard pages in the stack.

### 11. Using Column+Repeater instead of SilicaListView
For lists of more than ~10 items, SilicaListView is significantly more performant because
it virtualises delegates. Column+Repeater instantiates everything at once.

---

## Localisation

Every user-visible string must be wrapped in `qsTr()`:

```qml
text: qsTr("Hello")
placeholderText: qsTr("Search")
```

In C++: `tr("Hello")` or `QObject::tr("Hello")`.

Add to .pro file:
```qmake
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-myapp-de.ts
```

---

## Performance guidelines

- Use `SilicaListView` not `Column` + `Repeater` for dynamic lists
- Keep delegates lightweight; defer heavy content with `Loader`
- Avoid `anchors.fill` on items inside Column (use `width: parent.width` instead)
- Use `asynchronous: true` on `Image` items loading remote URLs
- Profile with Qt Creator's QML Profiler before optimising
- Move CPU-intensive work off the UI thread into a Worker/C++ thread
- Respect `Theme.flickDeceleration` and `Theme.maximumFlickVelocity` for custom scrollables

---

## App icon sizes

Harbour requires icons at these exact sizes (PNG):

| Size | Location |
|---|---|
| 86×86 | `icons/86x86/harbour-myapp.png` |
| 108×108 | `icons/108x108/harbour-myapp.png` |
| 128×128 | `icons/128x128/harbour-myapp.png` |
| 172×172 | `icons/172x172/harbour-myapp.png` |

Install them via .pro:

```qmake
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

Or use `sailfishapp_icons` CONFIG in newer SDK versions which handles this automatically.
