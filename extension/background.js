const HOST = "com.kaichen.share_to_notes";

function flash(tabId, text, color) {
  chrome.action.setBadgeBackgroundColor({ tabId, color });
  chrome.action.setBadgeText({ tabId, text });
  setTimeout(() => chrome.action.setBadgeText({ tabId, text: "" }), 2500);
}

async function share(url, title, tabId) {
  if (!/^https?:\/\//i.test(url || "")) {
    flash(tabId, "!", "#d33");
    chrome.action.setTitle({ tabId, title: "只能分享 http/https 网页" });
    return;
  }
  try {
    const res = await chrome.runtime.sendNativeMessage(HOST, { url, title });
    if (!res || !res.ok) throw new Error(res && res.error || "unknown error");
    flash(tabId, "✓", "#2a2");
  } catch (e) {
    console.error("Share to Notes failed:", e);
    flash(tabId, "!", "#d33");
    chrome.action.setTitle({ tabId, title: "分享失败：" + e.message + "（是否已运行 install.sh？）" });
  }
}

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({ id: "share-page", title: "分享此网页到备忘录", contexts: ["page"] });
  chrome.contextMenus.create({ id: "share-link", title: "分享此链接到备忘录", contexts: ["link"] });
});

chrome.action.onClicked.addListener((tab) => share(tab.url, tab.title, tab.id));

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === "share-link") share(info.linkUrl, info.selectionText || "", tab && tab.id);
  else share(tab.url, tab.title, tab.id);
});
