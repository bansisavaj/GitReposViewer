import Foundation
@testable import GitReposViewer

final class MockRepoService: RepositoryServiceProtocol {
    var shouldThrow = false
    var apiError: APIError = .unknown

    func fetchRepositories() async throws -> [Repository] {
        if shouldThrow { throw apiError }
        return [
            Repository(
                id: 101,
                name: "Alamofire",
                owner: Owner(type: "Organization"),
                description: "Elegant HTTP Networking in Swift",
                languagesURL: "https://api.github.com/repos/Alamofire/Alamofire/languages"
            ),
            Repository(
                id: 102,
                name: "SwiftLint",
                owner: Owner(type: "User"),
                description: "A tool to enforce Swift style and conventions",
                languagesURL: "https://api.github.com/repos/realm/SwiftLint/languages"
            )
        ]
    }
}
