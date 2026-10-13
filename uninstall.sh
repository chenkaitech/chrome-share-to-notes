#!/bin/bash
# Removes ShareToNotes.app and its native-messaging host registrations.
set -euo pipefail
HOST_NAME="com.kaichen.share_to_notes"
rm -rf "$HOME/Applications/ShareToNotes.app"
find "$HOME/Library/Application Support" -path "*/NativeMessagingHosts/$HOST_NAME.json" -maxdepth 5 -print -delete 2>/dev/null || true
echo "Uninstalled. Remove the extension itself from chrome://extensions."
