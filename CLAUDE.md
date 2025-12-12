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

**SymbolPicker** is a macOS menu bar app for browsing and copying SF Symbols. It uses `MenuBarExtra` with `.window` style to present a popover window from the menu bar.

### Key Components

- **SymbolPickerApp.swift** - App entry point using `MenuBarExtra` (no dock icon, menu bar only)
- **ContentView.swift** - Main UI with sidebar category list and symbol grid
- **SymbolBrowserViewModel.swift** - `@Observable` view model handling search, filtering, and clipboard operations
- **Views/SymbolGridItemView.swift** - Individual symbol item with hover states and click handlers (left/right-click)
- **Models/SFSymbol.swift** - Symbol data model (id, name, category)
- **Models/SymbolCategory.swift** - Category enum with icons
- **Resources/SFSymbols.swift** - Static list of ~2000 symbol names organized by category
- **Resources/SFSymbolsUnicode.json** - Mapping from symbol names to Unicode characters (for copy functionality)

### Copy Functionality

The app supports two copy modes:

- **Left-click** - Copies the Unicode character from the Private Use Area (e.g., `"􀋃"` for "star.fill"). The mapping is loaded from `SFSymbolsUnicode.json`. This allows pasting into apps that support SF Pro font (Notes, Pages, design tools like Figma, etc.).
- **Right-click** - Copies the symbol name string (e.g., `"star.fill"`). Useful for developers referencing symbols in code.

Both actions trigger visual feedback with a green checkmark and "Copied!" message. The right-click functionality uses `NSViewRepresentable` with an event monitor since SwiftUI doesn't natively support right-click gestures.

### UI Structure

```
HStack
├── Sidebar (VStack, 170px)
│   ├── ScrollView with category buttons
│   └── Quit button
└── Main content (VStack)
    ├── Search bar
    ├── Symbol count
    └── LazyVGrid of symbols
```
