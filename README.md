# Share to Notes · 分享到备忘录

**English** | [简体中文](README.zh-CN.md)

A Chrome extension that shares the current page (or any link) to **Apple Notes** on macOS, just like Safari's *Share → Notes*. Notes builds its rich link preview card with the page title, thumbnail and domain.

## How it works

A Chrome extension can't open the macOS share menu by itself, so the project has two parts:

```
Chrome extension ──native messaging──▶ ShareToNotes.app ──NSSharingService──▶ Notes share panel
 (extension/)                           (host/main.swift)   com.apple.Notes.SharingExtension
```

1. The extension sends the page URL to the local `ShareToNotes.app` via [Native Messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging).
2. The helper runs as a separate process and opens the system Notes share extension (the same one Safari uses). In the Notes panel you can pick a folder, add text and save.
3. Notes fetches the page itself and generates the preview card.

## Install

Requires macOS 12+ and the Xcode Command Line Tools for `swiftc` (`xcode-select --install`).

```bash
git clone https://github.com/chenkaitech/chrome-share-to-notes.git
cd chrome-share-to-notes
./install.sh
```

`install.sh` builds and installs `~/Applications/ShareToNotes.app` and registers the native messaging host for Chrome. It also registers Chrome Beta/Canary, Chromium, Edge, Brave and Arc if they are installed.

Then open `chrome://extensions`, turn on **Developer mode**, click **Load unpacked** and choose the repo's `extension` folder.

> The `key` in `manifest.json` pins the extension ID to `bgbbbhjmdfilodloihdblkchenonacjb`, which matches `allowed_origins` in the host manifest. If you change the `key`, update `tools/extension-id.txt` and run `install.sh` again.

## Usage

- Click the extension's toolbar icon, or press **⌥⇧N**
- Right-click a page → **Share This Page to Notes**
- Right-click a link → **Share This Link to Notes**

The extension UI follows Chrome's language: Simplified Chinese for `zh-CN`, English otherwise.

A green ✓ on the icon means the link reached the helper. A red ! means it failed; hover over the icon to see why (usually `install.sh` hasn't been run). Only http/https pages are supported.

## Uninstall

```bash
./uninstall.sh
```

Then remove the extension from `chrome://extensions`.

## Project layout

```
extension/          Chrome extension (Manifest V3)
  manifest.json
  background.js
  _locales/         en and zh_CN strings
  icons/
host/
  main.swift        native messaging host + share panel helper
  Info.plist
tools/
  extension-id.txt  fixed extension ID (used by install.sh)
  make-icons.swift  generates the extension icons
install.sh / uninstall.sh
```

## License

MIT
