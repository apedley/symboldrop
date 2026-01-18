# Repository Guidelines

## Project Structure & Module Organization
- `SymbolPicker/` contains the SwiftUI app sources (entry point, views, view model, models).
- `SymbolPicker/Resources/` holds SF Symbols data and menu bar assets.
- `SymbolPicker/Assets.xcassets/` contains app icons and color assets.
- `SymbolPickerTests/` includes unit tests.
- `SymbolPickerUITests/` includes UI tests.
- `SymbolPicker.xcodeproj/` is the Xcode project.

## Build, Test, and Development Commands
- `xcodebuild -scheme SymbolPicker -destination 'platform=macOS' build` builds the app from the command line.
- `xcodebuild -scheme SymbolPicker -destination 'platform=macOS' test` runs all tests.
- `xcodebuild -scheme SymbolPicker -destination 'platform=macOS' test -only-testing:SymbolPickerTests/SymbolPickerTests/viewModelFiltersByCategory` runs a single test.
- Open `SymbolPicker.xcodeproj` in Xcode and press `⌘R` to run locally.

## Coding Style & Naming Conventions
- SwiftUI code lives in `SymbolPicker/` and uses clear, descriptive type names (e.g., `SymbolBrowserViewModel`).
- Follow existing formatting in each file; the codebase mixes 2-space (UI) and 4-space (tests) indentation.
- Prefer SwiftUI conventions: `View` structs named after their responsibility and `@State`/`@Observable` for state.

## Testing Guidelines
- Tests use the Swift Testing framework (`import Testing`).
- Keep tests small and focused, naming test functions for the behavior under test (e.g., `sfSymbolsHaveValidCategories`).
- Add unit tests under `SymbolPickerTests/` and UI coverage under `SymbolPickerUITests/` when changing user flows.

## Commit & Pull Request Guidelines
- Recent commits use short, sentence-style summaries without prefixes (e.g., “Main window resizable”).
- Keep commit messages concise and scoped to one change.
- PRs should include a clear description, testing notes, and screenshots for UI changes.
- Link related issues when applicable.

## Configuration Tips
- Requirements: macOS 14+ and Xcode 15+.
- Symbol data lives in `SymbolPicker/Resources/SFSymbols.swift` and `SymbolPicker/Resources/SFSymbolsUnicode.json`; update both when adding symbols.
