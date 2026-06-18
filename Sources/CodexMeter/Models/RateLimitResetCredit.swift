import Foundation

struct RateLimitResetResponse: Decodable {
    let availableCount: Int
    let credits: [RateLimitResetCredit]

    enum CodingKeys: String, CodingKey {
        case availableCount = "available_count"
        case credits
    }
}

struct RateLimitResetCredit: Decodable, Equatable, Identifiable {
    let id: String
    let resetType: String
    let status: String
    let grantedAt: Date
    let expiresAt: Date
    let redeemedAt: Date?

    var isAvailable: Bool {
        status == "available" && redeemedAt == nil
    }

    var statusTitle: String {
        if isAvailable {
            return "Available"
        }

        return status
            .split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case resetType = "reset_type"
        case status
        case grantedAt = "granted_at"
        case expiresAt = "expires_at"
        case redeemedAt = "redeemed_at"
    }
}

enum CreditDateDecoder {
    static func decode(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = fractionalFormatter.date(from: value) {
            return date
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        if let date = formatter.date(from: value) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid ISO8601 date: \(value)"
        )
    }
}
