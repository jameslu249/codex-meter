import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    private let store: WidgetStore
    private let window: NSWindow

    init(store: WidgetStore) {
        self.store = store
        self.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 390, height: 292),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        configureWindow()
    }

    func show() {
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func configureWindow() {
        window.title = "Codex Meter Settings"
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.contentView = NSHostingView(rootView: SettingsView(store: store))
    }
}
