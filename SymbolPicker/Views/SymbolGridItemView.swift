import SwiftUI
import AppKit

struct SymbolGridItemView: View {
    let symbol: SFSymbol
    let isCopied: Bool
    let onCopy: () -> Void
    let onCopyName: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onCopy) {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: symbol.name)
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                        .foregroundStyle(isCopied ? .green : .primary)

                    if isCopied {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.green)
                            .offset(x: 16, y: -16)
                    }
                }

                if isHovered || isCopied {
                    Text(isCopied ? "Copied!" : symbol.name)
                        .font(.caption2)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(isCopied ? .green : .secondary)
                } else {
                    Text(" ")
                        .font(.caption2)
                }
            }
            .frame(width: 70, height: 70)
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
            monitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
                guard let self = self,
                      let window = self.window,
                      event.window == window else {
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
            symbol: SFSymbol(id: "star.fill", category: .general),
            isCopied: false,
            onCopy: {},
            onCopyName: {}
        )
        SymbolGridItemView(
            symbol: SFSymbol(id: "heart.fill", category: .general),
            isCopied: true,
            onCopy: {},
            onCopyName: {}
        )
    }
    .padding()
}
