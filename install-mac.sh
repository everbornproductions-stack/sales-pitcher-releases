#!/bin/bash
# Sales Pitcher for Mac: downloads the newest build for this Mac, puts it in Applications and opens it.
# Run it by pasting this one line into Terminal:
#   curl -fsSL https://raw.githubusercontent.com/everbornproductions-stack/sales-pitcher-releases/main/install-mac.sh | bash
# A file downloaded with curl carries no "downloaded from the internet" flag, so macOS does not stop the app with a
# "cannot be opened" or "damaged" warning. The same line updates an existing copy. Your pitches, calls and keys stay.
set -e
REPO="everbornproductions-stack/sales-pitcher-releases"
[ "$(uname -m)" = "arm64" ] && ARCH="arm64" || ARCH="x64"
echo "Looking for the newest Sales Pitcher for a Mac with an ${ARCH} chip..."
URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases?per_page=10" | grep -o "https://[^\"]*Sales-Pitcher-[0-9.]*-mac-${ARCH}\.zip" | head -1 || true)
if [ -z "$URL" ]; then echo "No Mac build is published yet. Tell Chris."; exit 1; fi
echo "Downloading ${URL##*/}"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
curl -fL --progress-bar "$URL" -o "$TMP/sp.zip"
ditto -xk "$TMP/sp.zip" "$TMP/new"
NEW=$(find "$TMP/new" -maxdepth 1 -name "*.app" | head -1)
[ -n "$NEW" ] || { echo "The download did not contain the app."; exit 1; }
DEST="/Applications"
if [ ! -w "$DEST" ]; then DEST="$HOME/Applications"; mkdir -p "$DEST"; fi
if pgrep -x "Sales Pitcher" >/dev/null 2>&1; then echo "Closing the running Sales Pitcher..."; osascript -e 'tell application "Sales Pitcher" to quit' >/dev/null 2>&1 || true; sleep 3; fi
rm -rf "$DEST/Sales Pitcher.app"
ditto "$NEW" "$DEST/Sales Pitcher.app"
xattr -dr com.apple.quarantine "$DEST/Sales Pitcher.app" 2>/dev/null || true
echo "Installed in $DEST. Opening it..."
open "$DEST/Sales Pitcher.app"
