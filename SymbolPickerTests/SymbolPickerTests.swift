//
//  SymbolPickerTests.swift
//  SymbolPickerTests
//
//  Created by Andrew Pedley on 12/11/25.
//

import Testing
@testable import SymbolPicker

struct SymbolPickerTests {

    // MARK: - SFSymbol Tests

    @Test func sfSymbolHasCorrectProperties() {
        let symbol = SFSymbol(id: "star.fill", category: .general)
        #expect(symbol.id == "star.fill")
        #expect(symbol.name == "star.fill")
        #expect(symbol.category == .general)
    }

    @Test func sfSymbolIsHashable() {
        let symbol1 = SFSymbol(id: "star.fill", category: .general)
        let symbol2 = SFSymbol(id: "star.fill", category: .general)
        let symbol3 = SFSymbol(id: "heart.fill", category: .health)

        #expect(symbol1 == symbol2)
        #expect(symbol1 != symbol3)
    }

    // MARK: - SymbolCategory Tests

    @Test func symbolCategoryHasAllCases() {
        let allCases = SymbolCategory.allCases
        #expect(allCases.count > 0)
        #expect(allCases.contains(.all))
        #expect(allCases.contains(.general))
        #expect(allCases.contains(.communication))
    }

    @Test func symbolCategoryHasIcon() {
        for category in SymbolCategory.allCases {
            #expect(!category.icon.isEmpty, "Category \(category.rawValue) should have an icon")
        }
    }

    @Test func symbolCategoryHasRawValue() {
        #expect(SymbolCategory.all.rawValue == "All")
        #expect(SymbolCategory.general.rawValue == "General")
        #expect(SymbolCategory.communication.rawValue == "Communication")
    }

    // MARK: - SFSymbols Data Tests

    @Test func sfSymbolsAllSymbolsNotEmpty() {
        let symbols = SFSymbols.allSymbols
        #expect(symbols.count > 0)
    }

    @Test func sfSymbolsContainsExpectedSymbols() {
        let symbols = SFSymbols.allSymbols
        let symbolNames = Set(symbols.map { $0.name })

        #expect(symbolNames.contains("star"))
        #expect(symbolNames.contains("star.fill"))
        #expect(symbolNames.contains("heart"))
        #expect(symbolNames.contains("heart.fill"))
    }

    @Test func sfSymbolsHaveValidCategories() {
        let symbols = SFSymbols.allSymbols
        let validCategories = Set(SymbolCategory.allCases)

        for symbol in symbols {
            #expect(validCategories.contains(symbol.category),
                   "Symbol \(symbol.name) has invalid category \(symbol.category)")
        }
    }

    // MARK: - ViewModel Tests

    @MainActor
    @Test func viewModelInitialState() {
        let viewModel = SymbolBrowserViewModel()

        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.selectedCategory == .all)
        #expect(viewModel.lastCopiedSymbol == nil)
    }

    @MainActor
    @Test func viewModelFiltersByCategory() {
        let viewModel = SymbolBrowserViewModel()

        viewModel.selectedCategory = .all
        let allCount = viewModel.filteredSymbols.count

        viewModel.selectedCategory = .general
        let generalCount = viewModel.filteredSymbols.count

        #expect(generalCount < allCount)
        #expect(generalCount > 0)

        for symbol in viewModel.filteredSymbols {
            #expect(symbol.category == .general)
        }
    }

    @MainActor
    @Test func viewModelFiltersBySearchText() {
        let viewModel = SymbolBrowserViewModel()

        viewModel.searchText = ""
        let allCount = viewModel.filteredSymbols.count

        viewModel.searchText = "star"
        let starCount = viewModel.filteredSymbols.count

        #expect(starCount < allCount)
        #expect(starCount > 0)

        for symbol in viewModel.filteredSymbols {
            #expect(symbol.name.lowercased().contains("star"))
        }
    }

    @MainActor
    @Test func viewModelFiltersByCategoryAndSearch() {
        let viewModel = SymbolBrowserViewModel()

        viewModel.selectedCategory = .general
        viewModel.searchText = "star"

        for symbol in viewModel.filteredSymbols {
            #expect(symbol.category == .general)
            #expect(symbol.name.lowercased().contains("star"))
        }
    }

    @MainActor
    @Test func viewModelCategoriesIncludesAll() {
        let viewModel = SymbolBrowserViewModel()
        let categories = viewModel.categories

        #expect(categories.contains(.all))
        #expect(categories.count == SymbolCategory.allCases.count)
    }

    @MainActor
    @Test func viewModelSearchIsCaseInsensitive() {
        let viewModel = SymbolBrowserViewModel()

        viewModel.searchText = "STAR"
        let upperCount = viewModel.filteredSymbols.count

        viewModel.searchText = "star"
        let lowerCount = viewModel.filteredSymbols.count

        viewModel.searchText = "Star"
        let mixedCount = viewModel.filteredSymbols.count

        #expect(upperCount == lowerCount)
        #expect(lowerCount == mixedCount)
    }
}
