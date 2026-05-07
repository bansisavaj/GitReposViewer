import Foundation
@testable import GitReposViewer

final class MockLanguageService: LanguageServiceProtocol {
    var languages: [String: Int] = [:]
    var shouldThrow = false

    func fetchLanguages(url: String) async throws -> [String: Int] {
        if shouldThrow { throw APIError.invalidResponse }
        return languages
    }
}
