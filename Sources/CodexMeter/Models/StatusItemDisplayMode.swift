import Foundation

enum StatusItemDisplayMode: String, CaseIterable, Identifiable {
    case percentageOnly
    case percentageWithResetTime
    case primaryAndWeekly
    case lowestWindowOnly
    case iconOnly

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .percentageOnly:
            return L10n.text("statusItem.mode.percentageOnly")
        case .percentageWithResetTime:
            return L10n.text("statusItem.mode.percentageWithResetTime")
        case .primaryAndWeekly:
            return L10n.text("statusItem.mode.primaryAndWeekly")
        case .lowestWindowOnly:
            return L10n.text("statusItem.mode.lowestWindowOnly")
        case .iconOnly:
            return L10n.text("statusItem.mode.iconOnly")
        }
    }

    var isIconOnly: Bool {
        self == .iconOnly
    }
}

struct StatusItemUsageWindow: Identifiable, Equatable {
    let id: String
    let source: String
    let shortLabel: String
    let menuBarLabel: String
    let menuLabelPrefix: String
    let percent: Int
    let resetAt: Date?
    let resetAfterSeconds: Int
    let isSpark: Bool
    let sortPriority: Int

    var remainingText: String {
        StatusItemFormatter.remainingTimeText(resetAfterSeconds)
    }

    var shortMenuLabel: String {
        menuBarLabel
    }

    var menuLabel: String {
        return L10n.text("statusItem.menu.windowLabel", menuLabelPrefix, percent, remainingText)
    }
}

struct StatusItemSnapshot {
    let windows: [StatusItemUsageWindow]
    let mode: StatusItemDisplayMode
    let isLoading: Bool
    let errorMessage: String?
    let lastUpdated: Date?
    let staleAfterSeconds: TimeInterval

    init(
        usage: UsageResponse?,
        showSparkUsage: Bool,
        mode: StatusItemDisplayMode,
        isLoading: Bool,
        errorMessage: String?,
        lastUpdated: Date?,
        staleAfterSeconds: TimeInterval
    ) {
        self.windows = Self.makeWindows(from: usage, showSparkUsage: showSparkUsage)
        self.mode = mode
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.lastUpdated = lastUpdated
        self.staleAfterSeconds = staleAfterSeconds
    }

    var hasWindowData: Bool {
        !windows.isEmpty
    }

    var isStale: Bool {
        guard let lastUpdated else {
            return false
        }

        return Date().timeIntervalSince(lastUpdated) > staleAfterSeconds
    }

    var statusText: String {
        statusText(for: mode)
    }

    func statusText(for mode: StatusItemDisplayMode) -> String {
        guard hasWindowData else {
            if mode.isIconOnly {
                return ""
            }

            if isLoading {
                return "--%"
            }

            if errorMessage != nil {
                return "ERR"
            }

            return "--%"
        }

        switch mode {
        case .percentageOnly:
            return "\(headlineCodexWindow.percent)%"
        case .percentageWithResetTime:
            return "\(headlineCodexWindow.percent)% · \(headlineCodexWindow.remainingText)"
        case .primaryAndWeekly:
            return compactPrimaryAndWeeklyText()
        case .lowestWindowOnly:
            return "\(lowestWindow.shortMenuLabel) \(lowestWindow.percent)%"
        case .iconOnly:
            return ""
        }
    }

    func previewText(for mode: StatusItemDisplayMode) -> String {
        if hasWindowData {
            let text = statusText(for: mode)
            return text.isEmpty ? L10n.text("statusItem.preview.iconOnly") : text
        }

        switch mode {
        case .percentageOnly:
            return "67%"
        case .percentageWithResetTime:
            return L10n.text("statusItem.preview.percentageWithResetTime")
        case .primaryAndWeekly:
            return L10n.text("statusItem.preview.primaryAndWeekly")
        case .lowestWindowOnly:
            return L10n.text("statusItem.preview.lowestWindowOnly")
        case .iconOnly:
            return L10n.text("statusItem.preview.iconOnly")
        }
    }

    var tooltipText: String {
        var base = L10n.text("app.name")

        if hasWindowData {
            if isStale {
                base += L10n.text("statusItem.tooltip.staleSuffix")
            }
        } else if isLoading {
            base += L10n.text("statusItem.tooltip.loadingSuffix")
        } else if let errorMessage {
            base += " · \(errorMessage)"
        } else {
            base += L10n.text("statusItem.tooltip.noDataSuffix")
        }

        if let lastUpdated {
            base += L10n.text("statusItem.tooltip.updatedSuffix", Self.timeFormatter.string(from: lastUpdated))
        }

        return base
    }

    var menuRows: [String] {
        windows.map { $0.menuLabel }
    }

    var menuActionSummary: String {
        guard hasWindowData else {
            return L10n.text("statusItem.menu.noUsageData")
        }

        if windows.count == 1 {
            let window = windows[0]
            return "\(window.shortMenuLabel) \(window.percent)%"
        }

        if mode == .percentageOnly || mode == .percentageWithResetTime {
            return L10n.text("statusItem.menu.headlinePercent", headlineCodexWindow.menuLabelPrefix, headlineCodexWindow.percent)
        }

        if mode == .primaryAndWeekly {
            return compactPrimaryAndWeeklyText()
        }

        return L10n.text("statusItem.menu.lowest", lowestWindow.shortMenuLabel, lowestWindow.percent)
    }

    private var headlineCodexWindow: StatusItemUsageWindow {
        primaryWindow ?? weeklyWindow ?? lowestWindow
    }

    private var lowestWindow: StatusItemUsageWindow {
        windows.min { lhs, rhs in
            if lhs.percent != rhs.percent {
                return lhs.percent < rhs.percent
            }

            if lhs.resetAfterSeconds != rhs.resetAfterSeconds {
                return lhs.resetAfterSeconds < rhs.resetAfterSeconds
            }

            if let lhsResetAt = lhs.resetAt, let rhsResetAt = rhs.resetAt, lhsResetAt != rhsResetAt {
                return lhsResetAt < rhsResetAt
            }

            if lhs.sortPriority != rhs.sortPriority {
                return lhs.sortPriority < rhs.sortPriority
            }

            return lhs.id < rhs.id
        } ?? windows[0]
    }

    private var primaryWindow: StatusItemUsageWindow? {
        windows.first { $0.shortLabel == "P" && !$0.isSpark }
    }

    private var weeklyWindow: StatusItemUsageWindow? {
        windows.first { $0.shortLabel == "W" && !$0.isSpark }
    }

    private func compactPrimaryAndWeeklyText() -> String {
        let primary = primaryWindow.map { "\($0.menuBarLabel) \($0.percent)%" }
        let weekly = weeklyWindow.map { "\($0.menuBarLabel) \($0.percent)%" }

        switch (primary, weekly) {
        case let (p?, w?):
            return "\(p) · \(w)"
        case let (p?, nil):
            return p
        case let (nil, w?):
            return w
        default:
            return statusTextFallback
        }
    }

    private var statusTextFallback: String {
        "\(lowestWindow.percent)%"
    }

    private static func makeWindows(from usage: UsageResponse?, showSparkUsage: Bool) -> [StatusItemUsageWindow] {
        guard let usage else {
            return []
        }

        var windows: [StatusItemUsageWindow] = []
        var priority = 0

        if let primaryWindow = usage.rateLimit?.primaryWindow {
            windows.append(
                StatusItemUsageWindow(
                    id: "codex-primary",
                    source: "Codex",
                    shortLabel: "P",
                    menuBarLabel: primaryWindow.durationTitle,
                    menuLabelPrefix: L10n.text("statusItem.window.codexPrimary", primaryWindow.durationTitle),
                    percent: primaryWindow.remainingPercent,
                    resetAt: primaryWindow.resetAt,
                    resetAfterSeconds: primaryWindow.resetAfterSeconds,
                    isSpark: false,
                    sortPriority: priority
                )
            )

            priority += 1
        }

        if let secondaryWindow = usage.rateLimit?.secondaryWindow {
            windows.append(
                StatusItemUsageWindow(
                    id: "codex-weekly",
                    source: "Codex",
                    shortLabel: "W",
                    menuBarLabel: L10n.text("statusItem.window.weeklyShort"),
                    menuLabelPrefix: L10n.text("statusItem.window.codexWeekly"),
                    percent: secondaryWindow.remainingPercent,
                    resetAt: secondaryWindow.resetAt,
                    resetAfterSeconds: secondaryWindow.resetAfterSeconds,
                    isSpark: false,
                    sortPriority: priority
                )
            )

            priority += 1
        }

        guard showSparkUsage else {
            return windows
        }

        guard let sparkRateLimit = usage.additionalRateLimits
            .first(where: { $0.meteredFeature == "codex_bengalfox" || $0.displayName == "Codex-Spark" })?
            .rateLimit
        else {
            return windows
        }

        if let primaryWindow = sparkRateLimit.primaryWindow {
            windows.append(
                StatusItemUsageWindow(
                    id: "spark-primary",
                    source: "Spark",
                    shortLabel: "P",
                    menuBarLabel: "Spark",
                    menuLabelPrefix: L10n.text("statusItem.window.sparkPrimary", primaryWindow.durationTitle),
                    percent: primaryWindow.remainingPercent,
                    resetAt: primaryWindow.resetAt,
                    resetAfterSeconds: primaryWindow.resetAfterSeconds,
                    isSpark: true,
                    sortPriority: priority
                )
            )

            priority += 1
        }

        if let secondaryWindow = sparkRateLimit.secondaryWindow {
            windows.append(
                StatusItemUsageWindow(
                    id: "spark-weekly",
                    source: "Spark",
                    shortLabel: "W",
                    menuBarLabel: L10n.text("statusItem.window.sparkWeeklyShort"),
                    menuLabelPrefix: L10n.text("statusItem.window.sparkWeekly"),
                    percent: secondaryWindow.remainingPercent,
                    resetAt: secondaryWindow.resetAt,
                    resetAfterSeconds: secondaryWindow.resetAfterSeconds,
                    isSpark: true,
                    sortPriority: priority
                )
            )
        }

        return windows
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

enum StatusItemFormatter {
    static func remainingTimeText(_ seconds: Int) -> String {
        if seconds <= 0 {
            return L10n.text("statusItem.remaining.reset")
        }

        let hourPart = seconds / 3600
        let minutePart = (seconds % 3600) / 60

        if hourPart > 0 && minutePart > 0 {
            return L10n.text("statusItem.remaining.hoursMinutes", hourPart, minutePart)
        }

        if hourPart > 0 {
            return L10n.text("statusItem.remaining.hours", hourPart)
        }

        return L10n.text("statusItem.remaining.minutes", minutePart)
    }
}
