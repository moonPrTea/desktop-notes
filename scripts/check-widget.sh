#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
xcrun swiftc -typecheck -parse-as-library -swift-version 6 \
    -application-extension -target "$(uname -m)-apple-macos14.0" \
    -sdk "$(xcrun --show-sdk-path)" \
    Sources/DesktopNotes/WidgetSnapshot.swift Widget/*.swift
