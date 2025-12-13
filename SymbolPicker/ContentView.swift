//
//  ContentView.swift
//  SymbolPicker
//
//  Created by Andrew Pedley on 12/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = SymbolBrowserViewModel()
    @FocusState private var isSearchFocused: Bool

    private let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 70), spacing: 4)
    ]

    var body: some View {
        HStack(spacing: 0) {
            // Category sidebar
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(viewModel.categories) { category in
                            SidebarCategoryButton(
                                category: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Divider()

                Button {
                    NSApp.terminate(nil)
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Quit")
                    }
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .frame(width: 170)
            .background(.quaternary.opacity(0.5))

            Divider()

            // Main content
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search symbols...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .focused($isSearchFocused)

                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
                .background(.quaternary)
                .cornerRadius(8)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // Symbol count
                HStack {
                    Text("\(viewModel.filteredSymbols.count) symbols")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 4)

                Divider()

                // Symbol grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(viewModel.filteredSymbols) { symbol in
                            SymbolGridItemView(
                                symbol: symbol,
                                isCopied: viewModel.lastCopiedSymbol?.id == symbol.id,
                                onCopy: {
                                    viewModel.copySymbol(symbol)
                                },
                                onCopyName: {
                                    viewModel.copySymbolName(symbol)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
            }
        }
        .task {
            // Delay focus to avoid window responder issues
            try? await Task.sleep(for: .milliseconds(100))
            isSearchFocused = true
        }
    }
}

struct SidebarCategoryButton: View {
    let category: SymbolCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                    .frame(width: 16)
                Text(category.rawValue)
                    .font(.system(size: 12))
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.clear)
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
    }
}

#Preview {
    ContentView()
        .frame(width: 500, height: 500)
}
