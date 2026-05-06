import Foundation

protocol LanguageServiceProtocol {
    func fetchLanguages(url: String) async throws -> [String: Int]
}

final class LanguageRequest: LanguageServiceProtocol {
    
    func fetchLanguages(url: String) async throws -> [String: Int] {
        try await APIClient.shared.request(
            .languages(url: url),
            token: authToken,
            type: [String: Int].self
        )
    }
}
