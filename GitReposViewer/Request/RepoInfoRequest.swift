import Foundation

protocol RepoInfoServiceProtocol {
    func fetchRepoInfo(owner: String, repo: String) async throws -> RepoInfo
}

final class RepoInfoRequest: RepoInfoServiceProtocol {

    func fetchRepoInfo(owner: String, repo: String) async throws -> RepoInfo {
        try await APIClient.shared.request(
            APIEndpoint.details(owner: owner, repo: repo),
            token: authToken,
            type: RepoInfo.self
        )
    }
}
