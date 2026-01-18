# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build the app
xcodebuild -scheme SymbolPicker -destination 'platform=macOS' build

# Run unit tests
xcodebuild -scheme SymbolPicker -destination 'platform=macOS' test

# Run a single test (example)
xcodebuild -scheme SymbolPicker -destination 'platform=macOS' test -only-testing:SymbolPickerTests/SymbolPickerTests/viewModelFiltersByCategory
```

## Architecture

**SymbolDrop** is a macOS menu bar app for browsing and copying SF Symbols. It uses `MenuBarExtra` with `.window` style to present a resizable popover window from the menu bar.

### Key Components

- **SymbolPickerApp.swift** - App entry point using `MenuBarExtra` (no dock icon, menu bar only)
- **ContentView.swift** - Main UI with sidebar category list, symbol grid, and settings popover
- **SymbolBrowserViewModel.swift** - `@Observable` view model handling search, filtering, favorites, recents, copy format, and clipboard operations
- **Views/SymbolGridItemView.swift** - Individual symbol item with hover states and click handlers (left/right-click)
- **Views/SettingsView.swift** - Settings popover for configuring copy format
- **Models/SFSymbol.swift** - Symbol data model (id, name, category)
- **Models/SymbolCategory.swift** - Category enum with icons (includes Recent and Favorites)
- **Resources/SFSymbols.swift** - Static list of ~2000 symbol names organized by category
- **Resources/SFSymbolsUnicode.json** - Mapping from symbol names to Unicode characters (for copy functionality)

### Copy Functionality

The app supports configurable copy formats via Settings:

- **Left-click** - Copies using the configured format:
  - **Unicode Character** (default) - Copies the Unicode character from the Private Use Area (e.g., `"􀋃"` for "star.fill"). Allows pasting into apps that support SF Pro font.
  - **Symbol Name** - Copies the symbol name (e.g., `"star.fill"`)
  - **SwiftUI Code** - Copies as SwiftUI code (e.g., `Image(systemName: "star.fill")`)
- **Right-click** - Always copies the symbol name string, regardless of settings.

Both actions trigger visual feedback with a green checkmark and "Copied!" message. The right-click functionality uses `NSViewRepresentable` with an event monitor since SwiftUI doesn't natively support right-click gestures.

### Features

- **Favorites** - Toggle favorite status via context menu, persisted in UserDefaults
- **Recent Symbols** - Last 20 copied symbols, shown in "Recent" category
- **Resizable Window** - Window size persisted via `@AppStorage`
- **Settings** - Copy format preference persisted in UserDefaults

### UI Structure

```
HStack
├── Sidebar (VStack, 170px)
│   ├── ScrollView with category buttons (including Recent, Favorites)
│   └── Quit button
└── Main content (VStack)
    ├── Search bar + Settings gear button
    ├── Symbol count
    └── LazyVGrid of symbols
```
