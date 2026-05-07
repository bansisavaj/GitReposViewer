import Foundation

protocol RepositoryServiceProtocol {
    func fetchRepositories() async throws -> [Repository]
//    func fetchRepositories(url: URL?) async throws -> (repos: [Repository], nextURL: URL?)
}

final class RepositoryRequest: RepositoryServiceProtocol {

    func fetchRepositories() async throws -> [Repository] {
        let repos: [Repository] = try await APIClient.shared.request(
            .repositories,
            token: authToken,
            type: [Repository].self
        )
        return repos
    }

    // MARK: - Paginated fetch
 /*  func fetchRepositories(url: URL?) async throws -> (repos: [Repository], nextURL: URL?) {

        guard let url = url else { return ([], nil) }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle non-200 errors
        let repos: [Repository] = try await APIClient.shared.request(
            .repositories(page: repoUrl),
            type: [Repository].self
        )

        // Parse pagination Link header
        var nextURL: URL? = nil
        if let linkHeader = httpResponse.value(forHTTPHeaderField: "Link") {
            nextURL = parseNextLink(from: linkHeader)
        }

        return (repos: repos, nextURL: nextURL)
    }

    private func parseNextLink(from header: String) -> URL? {
        // GitHub Link header example:
        // <https://api.github.com/repositories?since=364>; rel="next", <https://api.github.com/repositories{?since}>; rel="first"
        let links = header.split(separator: ",")
        for link in links {
            let parts = link.split(separator: ";")
            guard parts.count == 2 else { continue }
            let urlPart = parts[0].trimmingCharacters(in: CharacterSet(charactersIn: " <>"))
            let relPart = parts[1].trimmingCharacters(in: .whitespaces)
            if relPart == "rel=\"next\"", let url = URL(string: urlPart) {
                return url
            }
        }
        return nil
    } */

}
