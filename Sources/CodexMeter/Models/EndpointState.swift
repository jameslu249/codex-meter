import Foundation

enum WidgetEndpoint: String, CaseIterable, Sendable {
    case usage
    case resetCredits

    var title: String {
        switch self {
        case .usage:
            return L10n.text("endpoint.usage.title")
        case .resetCredits:
            return L10n.text("endpoint.resetCredits.title")
        }
    }

    /// Top-level response keys this app already understands. Used to keep
    /// diagnostics from echoing arbitrary server-controlled key names onto the
    /// clipboard — only allow-listed keys are reported by name.
    var knownTopLevelKeys: Set<String> {
        switch self {
        case .usage:
            return [
                "plan_type",
                "rate_limit",
                "additional_rate_limits",
                "credits",
                "rate_limit_reset_credits"
            ]
        case .resetCredits:
            return ["available_count", "credits"]
        }
    }

    var diagnosticName: String {
        switch self {
        case .usage:
            return "usage"
        case .resetCredits:
            return "reset_credits"
        }
    }

    var path: String {
        switch self {
        case .usage:
            return "/backend-api/wham/usage"
        case .resetCredits:
            return "/backend-api/wham/rate-limit-reset-credits"
        }
    }
}

enum EndpointFailureCategory: String, Sendable {
    case missingAuth
    case expiredSession
    case httpFailure
    case networkFailure
    case invalidResponse
    case malformedPayload
    case schemaMismatch
    case unknown
}

struct EndpointFailure: Error, Equatable, Sendable {
    let endpoint: WidgetEndpoint
    let category: EndpointFailureCategory
    let statusCode: Int?
    let decoderPath: String?
    let recognizedKeys: [String]
    let message: String
    let recoverySuggestion: String?

    init(
        endpoint: WidgetEndpoint,
        category: EndpointFailureCategory,
        statusCode: Int? = nil,
        decoderPath: String? = nil,
        recognizedKeys: [String] = [],
        message: String,
        recoverySuggestion: String? = nil
    ) {
        self.endpoint = endpoint
        self.category = category
        self.statusCode = statusCode
        self.decoderPath = decoderPath
        self.recognizedKeys = recognizedKeys
        self.message = message
        self.recoverySuggestion = recoverySuggestion
    }

    var statusTitle: String {
        switch category {
        case .missingAuth:
            return L10n.text("failure.status.missingAuth")
        case .expiredSession:
            return L10n.text("failure.status.expiredSession")
        case .schemaMismatch, .malformedPayload:
            return L10n.text("failure.status.schemaMismatch")
        case .httpFailure:
            return L10n.text("failure.status.httpFailure", endpoint.title)
        case .networkFailure:
            return L10n.text("failure.status.networkFailure", endpoint.title)
        case .invalidResponse, .unknown:
            return L10n.text("failure.status.needsAttention", endpoint.title)
        }
    }

    var detailText: String {
        switch category {
        case .missingAuth:
            return L10n.text("failure.detail.missingAuth")
        case .expiredSession:
            return L10n.text("failure.detail.expiredSession")
        case .schemaMismatch, .malformedPayload:
            return L10n.text("failure.detail.schemaMismatch", endpointDiagnosticLabel)
        case .httpFailure:
            return L10n.text("failure.detail.httpFailure", endpointDiagnosticLabel)
        case .networkFailure:
            return L10n.text("failure.detail.networkFailure", endpointDiagnosticLabel)
        case .invalidResponse:
            return L10n.text("failure.detail.invalidResponse", endpointDiagnosticLabel)
        case .unknown:
            return message
        }
    }

    private var endpointDiagnosticLabel: String {
        switch endpoint {
        case .usage:
            return L10n.text("endpoint.usage.diagnosticLabel")
        case .resetCredits:
            return L10n.text("endpoint.resetCredits.diagnosticLabel")
        }
    }
}

enum EndpointRefreshPhase: String, Sendable {
    case idle
    case refreshing
    case live
    case stale
    case unavailable
}

enum EndpointStatusTone: Sendable {
    case neutral
    case progress
    case live
    case warning
    case error
}

struct EndpointRefreshState: Equatable, Sendable {
    let endpoint: WidgetEndpoint
    var phase: EndpointRefreshPhase
    var lastSuccessAt: Date?
    var failure: EndpointFailure?
    var refreshStartedAt: Date?
    var hasPriorData: Bool

    static func idle(_ endpoint: WidgetEndpoint) -> EndpointRefreshState {
        EndpointRefreshState(
            endpoint: endpoint,
            phase: .idle,
            lastSuccessAt: nil,
            failure: nil,
            refreshStartedAt: nil,
            hasPriorData: false
        )
    }

    mutating func beginRefresh(at date: Date, hasPriorData: Bool) {
        phase = .refreshing
        refreshStartedAt = date
        self.hasPriorData = hasPriorData
    }

    mutating func recordSuccess(at date: Date, hasPriorData: Bool = true) {
        phase = .live
        lastSuccessAt = date
        failure = nil
        refreshStartedAt = nil
        self.hasPriorData = hasPriorData
    }

    mutating func recordFailure(_ failure: EndpointFailure, hasPriorData: Bool) {
        phase = hasPriorData ? .stale : .unavailable
        self.failure = failure
        refreshStartedAt = nil
        self.hasPriorData = hasPriorData
    }

    var isRefreshing: Bool {
        phase == .refreshing
    }

    var isLive: Bool {
        phase == .live
    }

    var isStale: Bool {
        phase == .stale
    }

    var isUnavailable: Bool {
        phase == .unavailable
    }

    var tone: EndpointStatusTone {
        switch phase {
        case .idle:
            return .neutral
        case .refreshing:
            return .progress
        case .live:
            return .live
        case .stale:
            return .warning
        case .unavailable:
            return failure?.category == .missingAuth ? .warning : .error
        }
    }

    var systemName: String {
        switch phase {
        case .idle:
            return "clock"
        case .refreshing:
            return "arrow.triangle.2.circlepath"
        case .live:
            return "checkmark.circle.fill"
        case .stale:
            return "clock.badge.exclamationmark"
        case .unavailable:
            return failure?.category == .missingAuth ? "person.crop.circle.badge.exclamationmark" : "exclamationmark.triangle.fill"
        }
    }

    var title: String {
        switch phase {
        case .idle:
            return L10n.text("refreshState.title.notUpdated")
        case .refreshing:
            return hasPriorData ? L10n.text("refreshState.title.refreshing") : L10n.text("refreshState.title.loading")
        case .live:
            return L10n.text("refreshState.title.live")
        case .stale:
            if failure?.category == .expiredSession {
                return L10n.text("failure.status.expiredSession")
            }

            if failure?.category == .schemaMismatch || failure?.category == .malformedPayload {
                return L10n.text("refreshState.title.schemaChanged")
            }

            switch endpoint {
            case .usage:
                return L10n.text("refreshState.title.usageStale")
            case .resetCredits:
                return L10n.text("refreshState.title.resetBankStale")
            }
        case .unavailable:
            return failure?.statusTitle ?? L10n.text("failure.status.networkFailure", endpoint.title)
        }
    }

    func timestampText(now: Date, timeFormatter: DateFormatter, relativeFormatter: RelativeDateTimeFormatter) -> String {
        if isRefreshing, !hasPriorData {
            return L10n.text("refreshState.timestamp.loadingLatest")
        }

        guard let lastSuccessAt else {
            return L10n.text("refreshState.timestamp.notUpdatedYet")
        }

        if phase == .live {
            return L10n.text("refreshState.timestamp.updated", timeFormatter.string(from: lastSuccessAt))
        }

        let relative = relativeAge(from: lastSuccessAt, now: now, formatter: relativeFormatter)
        return L10n.text("refreshState.timestamp.dataFrom", relative)
    }

    func relativeDataAge(now: Date, formatter: RelativeDateTimeFormatter) -> String? {
        guard let lastSuccessAt else {
            return nil
        }

        return L10n.text("refreshState.timestamp.dataFrom", relativeAge(from: lastSuccessAt, now: now, formatter: formatter))
    }

    private func relativeAge(from date: Date, now: Date, formatter: RelativeDateTimeFormatter) -> String {
        if date > now {
            return L10n.text("relative.justNow")
        }

        return formatter.localizedString(for: date, relativeTo: now)
    }
}

struct WidgetSnapshot: Equatable, Sendable {
    var usage: UsageResponse?
    var availableCount: Int?
    var credits: [RateLimitResetCredit]
    var capturedAt: Date?

    static let empty = WidgetSnapshot(
        usage: nil,
        availableCount: nil,
        credits: [],
        capturedAt: nil
    )
}
