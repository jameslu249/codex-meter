import Foundation

struct UsageResponse: Decodable {
    let planType: String?
    let rateLimit: UsageRateLimit?
    let additionalRateLimits: [AdditionalUsageRateLimit]
    let credits: UsageCredits?
    let rateLimitResetCredits: ResetCreditCount?

    enum CodingKeys: String, CodingKey {
        case planType = "plan_type"
        case rateLimit = "rate_limit"
        case additionalRateLimits = "additional_rate_limits"
        case credits
        case rateLimitResetCredits = "rate_limit_reset_credits"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        planType = try container.decodeIfPresent(String.self, forKey: .planType)
        rateLimit = try container.decodeIfPresent(UsageRateLimit.self, forKey: .rateLimit)
        additionalRateLimits = try container.decodeIfPresent([AdditionalUsageRateLimit].self, forKey: .additionalRateLimits) ?? []
        credits = try container.decodeIfPresent(UsageCredits.self, forKey: .credits)
        rateLimitResetCredits = try container.decodeIfPresent(ResetCreditCount.self, forKey: .rateLimitResetCredits)
    }
}

struct ResetCreditCount: Decodable {
    let availableCount: Int

    enum CodingKeys: String, CodingKey {
        case availableCount = "available_count"
    }
}

struct AdditionalUsageRateLimit: Decodable, Identifiable {
    let meteredFeature: String
    let rateLimit: UsageRateLimit

    var id: String {
        meteredFeature
    }

    var displayName: String {
        if meteredFeature == "codex_bengalfox" {
            return "Codex-Spark"
        }

        return meteredFeature
            .replacingOccurrences(of: "codex_", with: "")
            .split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case meteredFeature = "metered_feature"
        case rateLimit = "rate_limit"
    }
}

struct UsageRateLimit: Decodable, Equatable {
    let allowed: Bool
    let limitReached: Bool
    let primaryWindow: UsageWindow?
    let secondaryWindow: UsageWindow?

    enum CodingKeys: String, CodingKey {
        case allowed
        case limitReached = "limit_reached"
        case primaryWindow = "primary_window"
        case secondaryWindow = "secondary_window"
    }
}

struct UsageWindow: Decodable, Equatable {
    let usedPercent: Int
    let limitWindowSeconds: Int
    let resetAfterSeconds: Int
    let resetAt: Date?

    var remainingPercent: Int {
        max(0, min(100, 100 - usedPercent))
    }

    var durationTitle: String {
        if limitWindowSeconds >= 604_800 {
            return "Weekly"
        }

        if limitWindowSeconds >= 86_400 {
            let days = limitWindowSeconds / 86_400
            return "\(days)d"
        }

        let hours = max(1, limitWindowSeconds / 3_600)
        return "\(hours)h"
    }

    enum CodingKeys: String, CodingKey {
        case usedPercent = "used_percent"
        case limitWindowSeconds = "limit_window_seconds"
        case resetAfterSeconds = "reset_after_seconds"
        case resetAt = "reset_at"
    }

    init(usedPercent: Int, limitWindowSeconds: Int, resetAfterSeconds: Int, resetAt: Date?) {
        self.usedPercent = usedPercent
        self.limitWindowSeconds = limitWindowSeconds
        self.resetAfterSeconds = resetAfterSeconds
        self.resetAt = resetAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        usedPercent = try container.decode(Int.self, forKey: .usedPercent)
        limitWindowSeconds = try container.decode(Int.self, forKey: .limitWindowSeconds)
        resetAfterSeconds = try container.decode(Int.self, forKey: .resetAfterSeconds)

        if let timestamp = try container.decodeIfPresent(Double.self, forKey: .resetAt) {
            resetAt = Date(timeIntervalSince1970: timestamp)
        } else {
            resetAt = nil
        }
    }
}

struct UsageCredits: Decodable {
    let hasCredits: Bool
    let unlimited: Bool
    let overageLimitReached: Bool
    let balance: String?

    enum CodingKeys: String, CodingKey {
        case hasCredits = "has_credits"
        case unlimited
        case overageLimitReached = "overage_limit_reached"
        case balance
    }
}
