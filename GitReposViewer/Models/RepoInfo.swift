import Foundation

struct RepoInfo: Identifiable, Codable, Hashable {

    let id: Int
    let language: String
    let stargazersCount: Int

    enum CodingKeys: String, CodingKey {
        case id, language
        case stargazersCount = "stargazers_count"
    }
}
