# SymbolDrop

A lightweight macOS menu bar app for browsing and copying SF Symbols. Unapologetically vibe coded as an alternative to the paid options in the App Store.

This app also lets you copy the symbol itself instead of just the name which is useful for pasting into design tools like Figma. Left click to copy (configurable format), right-click to copy the symbol name.

[![SymbolDrop Screenshot](./screenshot.png)](./screenshot.png)

## Features

- **Menu Bar Access** - Lives in your menu bar, no dock icon
- **Resizable Window** - Drag to resize, size is remembered between sessions
- **Browse Symbols** - Organized by category (Communication, Weather, Transportation, etc.)
- **Quick Search** - Filter symbols by name
- **Favorites** - Mark symbols as favorites for quick access
- **Recent Symbols** - Quickly access your recently copied symbols
- **Configurable Copy Format** (left-click):
  - Unicode character (paste into Notes, Pages, Figma, etc.)
  - Symbol name (e.g., "star.fill")
  - SwiftUI code (e.g., `Image(systemName: "star.fill")`)
- **Right-click** - Always copies symbol name
- **Visual Feedback** - Green checkmark confirms copy action

## Build & Run

```bash
# Build
xcodebuild -scheme SymbolPicker -destination 'platform=macOS' build

# Run tests
xcodebuild -scheme SymbolPicker -destination 'platform=macOS' test
```

Or open `SymbolPicker.xcodeproj` in Xcode and press ⌘R.

## Requirements

- macOS 14.0+
- Xcode 15.0+
