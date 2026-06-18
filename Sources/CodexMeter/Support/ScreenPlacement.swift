import AppKit

@MainActor
enum ScreenPlacement {
    static func topRightFrame(size: NSSize, margin: CGFloat) -> NSRect {
        let visibleFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let x = visibleFrame.maxX - size.width - margin
        let y = visibleFrame.maxY - size.height - margin

        return NSRect(
            x: max(visibleFrame.minX + margin, x),
            y: max(visibleFrame.minY + margin, y),
            width: size.width,
            height: size.height
        )
    }
}
