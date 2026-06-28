import AppKit

@MainActor
enum StatusItemIcon {
    static func image() -> NSImage {
        let symbol = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let image = NSImage(systemSymbolName: "gauge.with.dots.needle.67percent", accessibilityDescription: L10n.text("app.name"))
            ?? NSImage(systemSymbolName: "arrow.clockwise.circle", accessibilityDescription: L10n.text("app.name"))
            ?? NSImage(systemSymbolName: "circle.grid.cross", accessibilityDescription: L10n.text("app.name"))
            ?? NSImage(size: NSSize(width: 18, height: 18))

        image.isTemplate = true
        return image.withSymbolConfiguration(symbol) ?? image
    }
}
