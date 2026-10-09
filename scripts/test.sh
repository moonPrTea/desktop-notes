#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
developer_dir="$(xcode-select -p)"
frameworks="$developer_dir/Library/Developer/Frameworks"
interop="$developer_dir/Library/Developer/usr/lib"
if [[ -d "$frameworks/Testing.framework" ]]; then
    swift test --disable-xctest \
        -Xswiftc -F -Xswiftc "$frameworks" \
        -Xlinker -F -Xlinker "$frameworks" \
        -Xlinker -rpath -Xlinker "$frameworks" \
        -Xlinker -rpath -Xlinker "$interop"
else
    swift test
fi
