import AppKit
import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService: ObservableObject {
    @Published private(set) var status: SMAppService.Status = .notRegistered
    @Published private(set) var isBusy: Bool = false
    @Published private(set) var lastErrorMessage: String?

    func refresh() {
        status = SMAppService.mainApp.status
    }

    var isEnabled: Bool {
        status == .enabled
    }

    var requiresApproval: Bool {
        status == .requiresApproval
    }

    var displaySummary: String {
        switch status {
        case .enabled:
            return L10n.text("launchAtLogin.status.enabled")
        case .requiresApproval:
            return L10n.text("launchAtLogin.status.requiresApproval")
        case .notFound:
            return L10n.text("launchAtLogin.status.notAvailable")
        case .notRegistered:
            return L10n.text("launchAtLogin.status.disabled")
        @unknown default:
            return L10n.text("launchAtLogin.status.unknown")
        }
    }

    func applyLaunchPreference(_ enabled: Bool) async -> Bool {
        isBusy = true
        defer { isBusy = false }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try await SMAppService.mainApp.unregister()
            }

            refresh()
            lastErrorMessage = nil
            return enabled == isEnabled || (enabled && status == .requiresApproval)
        } catch {
            refresh()

            if requiresApproval {
                lastErrorMessage = L10n.text("launchAtLogin.error.requiresApproval")
            } else {
                lastErrorMessage = error.localizedDescription
            }

            return enabled && status == .requiresApproval
        }
    }

    func openLoginItemsSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
