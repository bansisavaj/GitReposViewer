import Foundation
@testable import GitReposViewer

final class MockRepoInfoService: RepoInfoServiceProtocol {
    var repoInfo: RepoInfo!
    var shouldThrow = false

    func fetchRepoInfo(owner: String, repo: String) async throws -> GitReposViewer.RepoInfo {
        if shouldThrow { throw APIError.invalidResponse }
        return repoInfo
    }
}
