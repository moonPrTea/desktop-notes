# desktop-notes

Minimal white sticky notes for the macOS desktop, built with Swift and AppKit.
No external dependencies, accounts, or cloud sync. The current interface is in Russian.

## Getting started

The repository contains two build options: a lightweight app with floating notes,
and an Xcode app with a native WidgetKit extension. The command below builds only
the lightweight app; it does **not** install a system widget.

Requires macOS 13+ and Swift 6 (Xcode or Command Line Tools).

```sh
bash scripts/build-app.sh
open "dist/Desktop Notes.app"
```

Move the built app to Applications if you like. It lives in the menu bar,
without a Dock icon. Local builds are ad hoc signed and are not notarized.
The build script targets the architecture of your current Mac.

## Native desktop widgets

Requires macOS 14+, full Xcode 16+ with Swift 6, and an Apple development signing
identity. Standalone Command Line Tools and ad hoc signing are not sufficient for
the signed app-group setup used here.

1. Open `DesktopNotes.xcodeproj` in Xcode.
2. Select your development team in Signing & Capabilities for **both** targets:
   `DesktopNotes` and `DesktopNotesWidget`. Keep automatic signing enabled.
3. Build and run the `DesktopNotes` scheme on My Mac. Quit the old lightweight app
   first. Both variants use the same local notes file, so existing notes are kept.
4. Keep the signed app in Applications and launch it once before adding widgets.
5. Right-click the desktop → **Edit Widgets** → **Desktop Notes**. Add a small,
   medium, or large note.
6. Right-click the widget → **Edit Widget** to choose its note. Each instance can
   show a different note. Clicking a widget opens that note in the app for editing.

Hide the app's note windows from its menu bar if you want only system widgets.
Widgets retain the last saved text when the app quits. Deleted notes disappear
from the picker; hidden notes stay available. macOS schedules refreshes, so changes
may not appear immediately. Text is edited in the app, not inside WidgetKit.

For a configured signing identity, you can also build from Terminal:

```sh
TEAM_ID=YOUR_TEAM_ID bash scripts/build-native.sh
```

The macOS-only app group uses `TEAM_ID.com.moonprtea.desktop-notes`. Xcode expands
the same value in both entitlements and Info.plists. The app publishes an atomic,
read-only snapshot for the extension; the original notes file remains the source
of truth. See Apple's [app group signing guidance](https://developer.apple.com/documentation/xcode/accessing-app-group-containers).

The native target has been source-checked with the macOS SDK. Full Xcode signing,
installation, gallery discovery, and live widget refresh still need verification
on a Mac configured with Xcode and a signing identity.

## Using notes

- Create a note from the menu bar, or press ⌘N while the app is active.
- Write directly on the paper; press ⌘Z to undo an edit.
- Drag the white margin to move a note, or drag an edge to resize it.
- The first line becomes a heading; the rest stays small and readable.
- Open the ellipsis menu for new notes, floating above windows, hiding, and trash.
- Swipe horizontally with two fingers over the margin or press ⌘W to hide a note.
- Restore hidden notes from the menu bar. The trash action moves a note
  into a recoverable trash menu.

Notes appear across Spaces. Text, size, position, and visibility
are saved automatically on your Mac in
`~/Library/Application Support/DesktopNotes/notes.json`.
Legacy color values are retained in storage; all notes now use a white surface.
If this file cannot be read, the app leaves the original untouched.

## Development

```sh
swift build
bash scripts/test.sh
bash scripts/check-widget.sh
```

The model and persistence layer are separate from windows, drawing, and menus.
Tests cover persistence, recovery, corrupted files, and write failures.
The test script also locates Swift Testing in standalone Command Line Tools.
Keep commits under 200 added and deleted lines combined, with a short,
lowercase subject. Repository author email: `masapodolina@icloud.com`.
