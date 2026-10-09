#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release
app="dist/Desktop Notes.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp .build/release/DesktopNotes "$app/Contents/MacOS/DesktopNotes"
cp scripts/Info.plist "$app/Contents/Info.plist"
swift scripts/make-icon.swift "$app/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$app"
printf 'Built: %s/%s\n' "$PWD" "$app"
