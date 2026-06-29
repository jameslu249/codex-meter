import Foundation

struct CodexAuthTokenReader {
    func accessToken() throws -> String {
        let authURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".codex/auth.json")

        guard FileManager.default.fileExists(atPath: authURL.path) else {
            throw CodexAuthError.missingAuthFile
        }

        let data = try Data(contentsOf: authURL)
        let authFile = try JSONDecoder().decode(CodexAuthFile.self, from: data)
        let token = authFile.tokens.accessToken.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !token.isEmpty else {
            throw CodexAuthError.missingAccessToken
        }

        return token
    }
}

private struct CodexAuthFile: Decodable {
    let tokens: CodexTokens
}

private struct CodexTokens: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

enum CodexAuthError: LocalizedError {
    case missingAuthFile
    case missingAccessToken

    var errorDescription: String? {
        switch self {
        case .missingAuthFile:
            return L10n.text("auth.error.missingFile")
        case .missingAccessToken:
            return L10n.text("auth.error.missingAccessToken")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingAuthFile:
            return L10n.text("failure.detail.missingAuth")
        case .missingAccessToken:
            return L10n.text("auth.recovery.refreshSignIn")
        }
    }
}
