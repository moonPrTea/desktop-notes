# desktop-notes

Minimal white sticky notes for the macOS desktop, built with Swift and AppKit.
No external dependencies, accounts, or cloud sync. The current interface is in Russian.

## Getting started

Requires macOS 13+ and Swift 6 (Xcode or Command Line Tools).

```sh
bash scripts/build-app.sh
open "dist/Desktop Notes.app"
```

Move the built app to Applications if you like. It lives in the menu bar,
without a Dock icon. Local builds are ad hoc signed and are not notarized.
The build script targets the architecture of your current Mac.

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
```

The model and persistence layer are separate from windows, drawing, and menus.
Tests cover persistence, recovery, corrupted files, and write failures.
The test script also locates Swift Testing in standalone Command Line Tools.
Keep commits under 200 added and deleted lines combined, with a short,
lowercase subject. Repository author email: `masapodolina@icloud.com`.
