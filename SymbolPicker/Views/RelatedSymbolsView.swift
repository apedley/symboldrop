import SwiftUI

struct RelatedSymbolsView: View {
  let symbol: SFSymbol
  var viewModel: SymbolBrowserViewModel

  private let columns = [
    GridItem(.adaptive(minimum: 60, maximum: 70), spacing: 4)
  ]

  private var relatedSymbols: [SFSymbol] {
    viewModel.getRelatedSymbols(for: symbol)
  }

  private var baseName: String {
    symbol.name.split(separator: ".").first.map(String.init) ?? symbol.name
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: symbol.name)
          .font(.system(size: 20))
        Text("Related to: \(baseName)")
          .font(.headline)
        Spacer()
        Text("\(relatedSymbols.count) symbols")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Divider()

      if relatedSymbols.isEmpty {
        Text("No related symbols found")
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical, 20)
      } else {
        ScrollView {
          LazyVGrid(columns: columns, spacing: 4) {
            ForEach(relatedSymbols) { related in
              SymbolGridItemView(
                symbol: related,
                isCopied: viewModel.lastCopiedSymbol?.id == related.id,
                isFavorite: viewModel.isFavorite(related),
                hasRelated: false,
                onCopy: {
                  viewModel.copySymbol(related)
                },
                onCopyName: {
                  viewModel.copySymbolName(related)
                },
                onToggleFavorite: {
                  viewModel.toggleFavorite(related)
                },
                onShowRelated: {}
              )
            }
            .focusable(false)
          }
        }
        .frame(maxHeight: 250)
      }
    }
    .padding(16)
    .frame(width: 350)
  }
}

#Preview {
  RelatedSymbolsView(
    symbol: SFSymbol(id: "star.fill", category: .general),
    viewModel: SymbolBrowserViewModel()
  )
}
