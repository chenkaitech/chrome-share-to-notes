# Share to Notes · 分享到备忘录

一个 Chrome 扩展：把当前网页或链接分享到 macOS **备忘录 (Notes)**，效果与 Safari 的「分享 → 备忘录」完全一致——备忘录会自动生成带标题、缩略图和域名的网页预览卡片。

A Chrome extension that shares the current page (or any link) to macOS Notes through the same system share extension Safari uses, so Notes creates its rich link preview card.

## 原理

Chrome 扩展无法直接调用 macOS 分享菜单，所以分两部分：

```
Chrome 扩展 ──native messaging──▶ ShareToNotes.app ──NSSharingService──▶ 备忘录分享面板
 (extension/)                      (host/main.swift)   com.apple.Notes.SharingExtension
```

1. 扩展把网页 URL 通过 [Native Messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging) 发给本地的 `ShareToNotes.app`。
2. 辅助程序以独立进程调用系统的备忘录分享扩展（与 Safari 相同），弹出备忘录面板，可选择文件夹、添加文字后存储。
3. 预览卡片由备忘录自行抓取生成。

## 安装

需要 macOS 12+ 和 Xcode Command Line Tools（提供 `swiftc`：`xcode-select --install`）。

```bash
git clone https://github.com/<you>/chrome-share-to-notes.git
cd chrome-share-to-notes
./install.sh
```

`install.sh` 会编译并安装 `~/Applications/ShareToNotes.app`，并为 Chrome（以及已安装的 Chrome Beta/Canary、Chromium、Edge、Brave、Arc）注册 native messaging host。

然后在 Chrome 打开 `chrome://extensions`，开启「开发者模式」，点「加载已解压的扩展程序」，选择仓库里的 `extension` 文件夹。

> 扩展 ID 由 `manifest.json` 中的 `key` 固定为 `bgbbbhjmdfilodloihdblkchenonacjb`，与 host 清单的 `allowed_origins` 对应。如果你修改了 `key`，需同步更新 `tools/extension-id.txt` 并重新运行 `install.sh`。

## 使用

- 点击工具栏上的扩展图标，或按 **⌥⇧N**
- 在网页空白处右键 →「分享此网页到备忘录」
- 在链接上右键 →「分享此链接到备忘录」

图标出现绿色 ✓ 表示已发送给辅助程序；红色 ! 表示失败，鼠标悬停在图标上可查看原因（通常是没有运行 `install.sh`）。只支持 http/https 网页。

## 卸载

```bash
./uninstall.sh
```

再到 `chrome://extensions` 移除扩展即可。

## 目录结构

```
extension/          Chrome 扩展 (Manifest V3)
  manifest.json
  background.js
  icons/
host/
  main.swift        native messaging host + 分享面板辅助程序
  Info.plist
tools/
  extension-id.txt  固定的扩展 ID（install.sh 使用）
  make-icons.swift  生成扩展图标
install.sh / uninstall.sh
```

## License

MIT
