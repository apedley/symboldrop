import SwiftUI
import AppKit

@MainActor
@Observable
final class SymbolBrowserViewModel {
    var searchText: String = ""
    var selectedCategory: SymbolCategory = .all
    var lastCopiedSymbol: SFSymbol?

    private let allSymbols: [SFSymbol] = SFSymbols.allSymbols

    private static let recentSymbolsKey = "recentSymbolIDs"
    private static let maxRecentSymbols = 20

    private(set) var recentSymbolIDs: [String] {
        didSet {
            UserDefaults.standard.set(recentSymbolIDs, forKey: Self.recentSymbolsKey)
        }
    }

    init() {
        self.recentSymbolIDs = UserDefaults.standard.stringArray(forKey: Self.recentSymbolsKey) ?? []
    }

    // Cache mapping symbol names to their Unicode characters
    private static var symbolToCharacter: [String: String]?

    var filteredSymbols: [SFSymbol] {
        var result: [SFSymbol]

        // Filter by category
        if selectedCategory == .recent {
            // Return symbols in recent order (most recent first)
            result = recentSymbolIDs.compactMap { id in
                allSymbols.first { $0.id == id }
            }
        } else if selectedCategory != .all {
            result = allSymbols.filter { $0.category == selectedCategory }
        } else {
            result = allSymbols
        }

        // Filter by search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { symbol in
                symbol.name.lowercased().contains(query)
            }
        }

        return result
    }

    var categories: [SymbolCategory] {
        SymbolCategory.allCases
    }

    func copySymbol(_ symbol: SFSymbol) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        // Try to get the actual Unicode character for this symbol
        if let character = Self.getCharacter(for: symbol.name) {
            pasteboard.setString(character, forType: .string)
        } else {
            // Fallback to symbol name
            pasteboard.setString(symbol.name, forType: .string)
        }

        addToRecents(symbol)
        lastCopiedSymbol = symbol
        resetCopiedSymbolAfterDelay(symbol)
    }

    func copySymbolName(_ symbol: SFSymbol) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(symbol.name, forType: .string)

        addToRecents(symbol)
        lastCopiedSymbol = symbol
        resetCopiedSymbolAfterDelay(symbol)
    }

    private func addToRecents(_ symbol: SFSymbol) {
        var recents = recentSymbolIDs
        recents.removeAll { $0 == symbol.id }
        recents.insert(symbol.id, at: 0)
        if recents.count > Self.maxRecentSymbols {
            recents = Array(recents.prefix(Self.maxRecentSymbols))
        }
        recentSymbolIDs = recents
    }

    private func resetCopiedSymbolAfterDelay(_ symbol: SFSymbol) {
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            if lastCopiedSymbol?.id == symbol.id {
                lastCopiedSymbol = nil
            }
        }
    }

    // MARK: - Symbol to Unicode Character Mapping

    private static func getCharacter(for symbolName: String) -> String? {
        // Build cache if needed
        if symbolToCharacter == nil {
            symbolToCharacter = loadSymbolMapping()
        }
        return symbolToCharacter?[symbolName]
    }

    private static func loadSymbolMapping() -> [String: String] {
        var cache: [String: String] = [:]

        // Load from bundled JSON file
        guard let url = Bundle.main.url(forResource: "SFSymbolsUnicode", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return cache
        }

        // Parse JSON: array of [name, character] pairs
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String]] else {
            return cache
        }

        for pair in jsonArray {
            if pair.count == 2 {
                let name = pair[0]
                let character = pair[1]
                cache[name] = character
            }
        }

        return cache
    }
}
