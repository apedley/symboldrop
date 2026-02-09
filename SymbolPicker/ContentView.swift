//
//  ContentView.swift
//  SymbolPicker
//
//  Created by Andrew Pedley on 12/11/25.
//

import SwiftUI
import Combine

/// Makes the MenuBarExtra window resizable and tracks size changes
struct WindowResizeHelper: NSViewRepresentable {
  @Binding var width: Double
  @Binding var height: Double

  class HelperView: NSView {
    var cancellable: AnyCancellable?
    var didChangeSize: ((CGSize) -> Void)?

    override func viewWillMove(toWindow newWindow: NSWindow?) {
      super.viewWillMove(toWindow: newWindow)
      Task {
        newWindow?.styleMask.insert(.resizable)
      }
      cancellable = NotificationCenter.default.publisher(
        for: NSWindow.didResizeNotification,
        object: newWindow
      )
      .sink { [weak self] _ in
        self?.didChangeSize?(newWindow?.contentView?.bounds.size ?? .zero)
      }
    }
  }

  func makeNSView(context: Context) -> HelperView {
    HelperView()
  }

  func updateNSView(_ nsView: HelperView, context: Context) {
    nsView.didChangeSize = {
      width = $0.width
      height = $0.height
    }
  }
}

struct ContentView: View {
  @State private var viewModel = SymbolBrowserViewModel()
  @FocusState private var isSearchFocused: Bool
  @State private var showSettings = false
  @State private var symbolForRelated: SFSymbol?
  @AppStorage("windowWidth") private var windowWidth: Double = 550
  @AppStorage("windowHeight") private var windowHeight: Double = 550

  private let columns = [
    GridItem(.adaptive(minimum: 60, maximum: 70), spacing: 4)
  ]

  var body: some View {
    ZStack {
      WindowResizeHelper(width: $windowWidth, height: $windowHeight)
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
        // Search bar and settings
        HStack {
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

          // Settings button
          Button {
            showSettings.toggle()
          } label: {
            Image(systemName: "gear")
              .font(.system(size: 18))
              .foregroundStyle(.secondary)
              .frame(width: 36, height: 36)
          }
          .buttonStyle(.plain)
          .popover(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
          }
        }
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
                isFavorite: viewModel.isFavorite(symbol),
                hasRelated: !viewModel.getRelatedSymbols(for: symbol).isEmpty,
                onCopy: {
                  viewModel.copySymbol(symbol)
                },
                onCopyName: {
                  viewModel.copySymbolName(symbol)
                },
                onToggleFavorite: {
                  viewModel.toggleFavorite(symbol)
                },
                onShowRelated: {
                  symbolForRelated = symbol
                }
              )
            }
          }
          .padding(.horizontal, 6)
          .padding(.vertical, 6)
        }
        .popover(item: $symbolForRelated) { symbol in
          RelatedSymbolsView(symbol: symbol, viewModel: viewModel)
        }
      }
      } // end HStack
    } // end ZStack
    .frame(width: windowWidth, height: windowHeight)
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
    .frame(minWidth: 400, maxWidth: 800, minHeight: 400, maxHeight: 800)
}
