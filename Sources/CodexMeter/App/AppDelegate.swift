import AppKit
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = WidgetStore()
    private var widgetController: WidgetWindowController?
    private var settingsController: SettingsWindowController?
    private var statusItem: NSStatusItem?
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let controller = WidgetWindowController(store: store)
        widgetController = controller
        settingsController = SettingsWindowController(store: store)
        configureStatusItem()
        controller.show()
        configureAutoRefresh()
        Task {
            await store.refresh()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        refreshTimer?.invalidate()
        store.save()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = StatusItemIcon.image()
        item.button?.imagePosition = .imageOnly
        item.button?.toolTip = "Codex Meter"
        item.button?.target = self
        item.button?.action = #selector(statusItemClicked(_:))
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem = item
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh Now", action: #selector(refreshCredits), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: widgetController?.isVisible == true ? "Hide Codex Meter" : "Show Codex Meter", action: #selector(toggleWidget), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Reset Position and Size", action: #selector(resetWidgetPlacement), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Codex Meter", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        return menu
    }

    private func configureAutoRefresh() {
        store.$autoRefreshEnabled
            .combineLatest(store.$refreshIntervalSeconds)
            .sink { [weak self] _, _ in
                self?.restartRefreshTimer()
            }
            .store(in: &cancellables)

        restartRefreshTimer()
    }

    private func restartRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil

        guard store.autoRefreshEnabled else {
            return
        }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: store.refreshIntervalSeconds, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.store.refresh()
            }
        }
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            makeMenu().popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height + 5), in: sender)
        } else {
            toggleWidget()
        }
    }

    @objc private func toggleWidget() {
        if widgetController?.isVisible == true {
            hideWidget()
        } else {
            showWidget()
        }
    }

    @objc private func showWidget() {
        widgetController?.show()
        Task {
            await store.refreshIfStale()
        }
    }

    @objc private func refreshCredits() {
        widgetController?.show()
        Task {
            await store.refresh()
        }
    }

    @objc private func hideWidget() {
        widgetController?.hide()
    }

    @objc private func snapWidget() {
        widgetController?.snapToTopRight(animated: true)
    }

    @objc private func resetWidgetPlacement() {
        widgetController?.resetPositionAndSize(animated: true)
    }

    @objc private func showSettings() {
        settingsController?.show()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    @objc private func screenParametersChanged() {
        widgetController?.snapToTopRight(animated: true)
    }
}
