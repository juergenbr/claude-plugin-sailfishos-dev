---
title: Home
nav_order: 1
---

# sailfishos-dev

A [Claude Code](https://claude.ai/code) skill that turns Claude into a SailfishOS app
development expert — covering Silica QML components, sfdk build/deploy commands, design
guidelines, Harbour store submission, and platform APIs.

## Install

```
/plugin install sailfishos-dev@juergenbr/claude-plugin-sailfishos-dev
```

Or browse for it in Claude Code via `/plugin > Discover`.

## What it covers

| Topic | Details |
|---|---|
| **App architecture** | QML + C++ structure, sailfishapp library, .pro file, RPM spec |
| **Silica components** | All major UI types: Page, PullDownMenu, SilicaListView, Cover, Dialog, and more |
| **Build & deploy** | sfdk commands for emulator (i486) and device (aarch64), multi-target switching |
| **Debugging** | Journal logs, QML console, GDB via sfdk |
| **Design guidelines** | Full Theme.* property reference, spacing, colours, UX patterns, pitfalls |
| **Harbour** | Allowed APIs, permissions, icon sizes, RPM rules, submission steps |
| **Platform APIs** | Notifications, DBus, Contacts, Pickers, KeepAlive, Multimedia, MPRIS, OAuth2 |

## Usage

Once installed the skill activates automatically when you work on SailfishOS topics.
You can also invoke it explicitly:

```
/sailfishos-dev  how do I add a PullDownMenu?
```

## Source

[github.com/juergenbr/claude-plugin-sailfishos-dev](https://github.com/juergenbr/claude-plugin-sailfishos-dev)
