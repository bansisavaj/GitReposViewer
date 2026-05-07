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
                owner: Owner(type: "Organization", login: ""),
                description: "Elegant HTTP Networking in Swift"
            ),
            Repository(
                id: 102,
                name: "SwiftLint",
                owner: Owner(type: "User", login: ""),
                description: "A tool to enforce Swift style and conventions"
            )
        ]
    }
}
