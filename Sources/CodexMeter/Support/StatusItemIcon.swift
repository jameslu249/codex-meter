import AppKit

@MainActor
enum StatusItemIcon {
    static func image() -> NSImage {
        let symbol = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let image = NSImage(systemSymbolName: "gauge.with.dots.needle.67percent", accessibilityDescription: "Codex Meter")
            ?? NSImage(systemSymbolName: "arrow.clockwise.circle", accessibilityDescription: "Codex Meter")
            ?? NSImage(systemSymbolName: "circle.grid.cross", accessibilityDescription: "Codex Meter")
            ?? NSImage(size: NSSize(width: 18, height: 18))

        image.isTemplate = true
        return image.withSymbolConfiguration(symbol) ?? image
    }
}
