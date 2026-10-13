const HOST = "com.kaichen.share_to_notes";
const t = (key, ...subs) => chrome.i18n.getMessage(key, subs);

function flash(tabId, text, color) {
  chrome.action.setBadgeBackgroundColor({ tabId, color });
  chrome.action.setBadgeText({ tabId, text });
  setTimeout(() => chrome.action.setBadgeText({ tabId, text: "" }), 2500);
}

async function share(url, title, tabId) {
  if (!/^https?:\/\//i.test(url || "")) {
    flash(tabId, "!", "#d33");
    chrome.action.setTitle({ tabId, title: t("errorUnsupportedUrl") });
    return;
  }
  try {
    const res = await chrome.runtime.sendNativeMessage(HOST, { url, title });
    if (!res || !res.ok) throw new Error(res && res.error || "unknown error");
    flash(tabId, "✓", "#2a2");
  } catch (e) {
    console.error("Share to Notes failed:", e);
    flash(tabId, "!", "#d33");
    chrome.action.setTitle({ tabId, title: t("errorShareFailed", e.message) });
  }
}

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({ id: "share-page", title: t("menuSharePage"), contexts: ["page"] });
  chrome.contextMenus.create({ id: "share-link", title: t("menuShareLink"), contexts: ["link"] });
});

chrome.action.onClicked.addListener((tab) => share(tab.url, tab.title, tab.id));

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === "share-link") share(info.linkUrl, info.selectionText || "", tab && tab.id);
  else share(tab.url, tab.title, tab.id);
});
