import AppKit
import SwiftUI

struct SymbolGridItemView: View {
  let symbol: SFSymbol
  let isCopied: Bool
  let isFavorite: Bool
  let hasRelated: Bool
  let onCopy: () -> Void
  let onCopyName: () -> Void
  let onToggleFavorite: () -> Void
  let onShowRelated: () -> Void

  @State private var isHovered = false

  var body: some View {
    Button(action: onCopy) {
      VStack(spacing: 4) {
        ZStack {
          Image(systemName: symbol.name)
            .font(.system(size: 24))
            .frame(width: 44, height: 44, alignment: .centerFirstTextBaseline)
            .foregroundStyle(isCopied ? .green : .primary)

          // Favorite star - top-left, visible on hover or when favorited
          if isHovered || isFavorite {
            Button(action: onToggleFavorite) {
              Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.system(size: 12))
                .foregroundStyle(isFavorite ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
            .offset(x: -25, y: -16)
          }

          // Copied checkmark - top-right
          if isCopied {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 16))
              .foregroundStyle(.green)
              .offset(x: 16, y: -16)
          }

          // Related symbols button - top-right (only when hovering and has related, not when copied)
          if isHovered && hasRelated && !isCopied {
            Button(action: onShowRelated) {
              Image(systemName: "square.on.square")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .offset(x: 20, y: -16)
          }
        }

        Text(isHovered || isCopied ? (isCopied ? "Copied!" : symbol.name) : " ")
          .font(.caption2)
          .lineLimit(2)
          .multilineTextAlignment(.center)
          .foregroundStyle(isCopied ? .green : .secondary)
          .frame(height: 26, alignment: .center)
      }
      .frame(width: 70, height: 80)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .onHover { hovering in
      isHovered = hovering
    }
    .help(symbol.name)
    .onRightClick(perform: onCopyName)
  }
}

struct RightClickHandler: NSViewRepresentable {
  let action: () -> Void

  func makeNSView(context: Context) -> RightClickNSView {
    let view = RightClickNSView()
    view.action = action
    return view
  }

  func updateNSView(_ nsView: RightClickNSView, context: Context) {
    nsView.action = action
  }
}

class RightClickNSView: NSView {
  var action: (() -> Void)?
  private var monitor: Any?

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    if window != nil {
      monitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) {
        [weak self] event in
        guard let self = self,
          let window = self.window,
          event.window == window
        else {
          return event
        }
        let locationInView = self.convert(event.locationInWindow, from: nil)
        if self.bounds.contains(locationInView) {
          self.action?()
        }
        return event
      }
    } else if let monitor = monitor {
      NSEvent.removeMonitor(monitor)
      self.monitor = nil
    }
  }

  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil
  }

  deinit {
    if let monitor = monitor {
      NSEvent.removeMonitor(monitor)
    }
  }
}

extension View {
  func onRightClick(perform action: @escaping () -> Void) -> some View {
    overlay(RightClickHandler(action: action))
  }
}

#Preview {
  HStack {
    SymbolGridItemView(
      symbol: SFSymbol(id: "heart.slash.circle", category: .general),
      isCopied: false,
      isFavorite: false,
      hasRelated: true,
      onCopy: {},
      onCopyName: {},
      onToggleFavorite: {},
      onShowRelated: {}
    )
    SymbolGridItemView(
      symbol: SFSymbol(id: "heart", category: .general),
      isCopied: false,
      isFavorite: false,
      hasRelated: true,
      onCopy: {},
      onCopyName: {},
      onToggleFavorite: {},
      onShowRelated: {}
    )
    SymbolGridItemView(
      symbol: SFSymbol(id: "heart.fill", category: .general),
      isCopied: true,
      isFavorite: true,
      hasRelated: false,
      onCopy: {},
      onCopyName: {},
      onToggleFavorite: {},
      onShowRelated: {}
    )
  }
  .padding()
}
