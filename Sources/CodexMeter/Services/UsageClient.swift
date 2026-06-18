import Foundation

struct UsageClient {
    private let endpoint = URL(string: "https://chatgpt.com/backend-api/wham/usage")!

    func fetchUsage(accessToken: String) async throws -> UsageResponse {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsageClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw UsageClientError.httpStatus(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(UsageResponse.self, from: data)
    }
}

enum UsageClientError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The usage service returned an invalid response."
        case .httpStatus(let statusCode):
            if statusCode == 401 || statusCode == 403 {
                return "Codex sign-in is not authorized for usage lookup."
            }

            return "The usage service returned HTTP \(statusCode)."
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
