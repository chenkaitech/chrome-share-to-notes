#!/bin/bash
# Builds ShareToNotes.app into ~/Applications and registers it as a Chrome native-messaging host.
set -euo pipefail
cd "$(dirname "$0")"

HOST_NAME="com.kaichen.share_to_notes"
EXT_ID="$(cat tools/extension-id.txt)"
APP="$HOME/Applications/ShareToNotes.app"

rm -rf build && mkdir -p build
swiftc -O host/main.swift -o build/ShareToNotes

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp host/Info.plist "$APP/Contents/Info.plist"
cp build/ShareToNotes "$APP/Contents/MacOS/ShareToNotes"
codesign --force --sign - "$APP" >/dev/null

MANIFEST=$(cat <<JSON
{
  "name": "$HOST_NAME",
  "description": "Share to macOS Notes",
  "path": "$APP/Contents/MacOS/ShareToNotes",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://$EXT_ID/"]
}
JSON
)

# Google Chrome is always registered; other Chromium browsers only if installed.
SUPPORT="$HOME/Library/Application Support"
for dir in "Google/Chrome" "Google/Chrome Beta" "Google/Chrome Canary" "Chromium" \
           "Microsoft Edge" "BraveSoftware/Brave-Browser" "Arc/User Data"; do
  if [ "$dir" = "Google/Chrome" ] || [ -d "$SUPPORT/$dir" ]; then
    mkdir -p "$SUPPORT/$dir/NativeMessagingHosts"
    echo "$MANIFEST" > "$SUPPORT/$dir/NativeMessagingHosts/$HOST_NAME.json"
    echo "Registered host for: $dir"
  fi
done

echo
echo "Installed $APP"
echo "Extension ID: $EXT_ID"
echo "Now load the 'extension' folder in chrome://extensions (Developer mode → Load unpacked)."
