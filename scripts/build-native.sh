#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! xcodebuild -version >/dev/null 2>&1; then
    printf 'Full Xcode 16+ is required. Command Line Tools cannot build the widget target.\n' >&2
    exit 1
fi
if [[ -z "${TEAM_ID:-}" ]]; then
    printf 'Set TEAM_ID to your Apple development team, or build in Xcode after selecting a team.\n' >&2
    exit 1
fi
xcodebuild -project DesktopNotes.xcodeproj -scheme DesktopNotes \
    -configuration Release -derivedDataPath .build/native \
    DEVELOPMENT_TEAM="$TEAM_ID" build
printf 'Built: %s/.build/native/Build/Products/Release/Desktop Notes.app\n' "$PWD"
