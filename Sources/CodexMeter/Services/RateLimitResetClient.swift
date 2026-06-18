import Foundation

struct RateLimitResetClient {
    private let endpoint = URL(string: "https://chatgpt.com/backend-api/wham/rate-limit-reset-credits")!

    func fetchCredits(accessToken: String) async throws -> RateLimitResetResponse {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RateLimitResetClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw RateLimitResetClientError.httpStatus(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(CreditDateDecoder.decode)
        return try decoder.decode(RateLimitResetResponse.self, from: data)
    }
}

enum RateLimitResetClientError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The reset-credit service returned an invalid response."
        case .httpStatus(let statusCode):
            if statusCode == 401 || statusCode == 403 {
                return "Codex sign-in is not authorized for reset-credit lookup."
            }

            return "The reset-credit service returned HTTP \(statusCode)."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidResponse:
            return "Try refreshing again."
        case .httpStatus(let statusCode) where statusCode == 401 || statusCode == 403:
            return "Sign in to Codex again, then refresh."
        case .httpStatus:
            return "Try again in a moment."
        }
    }
}
