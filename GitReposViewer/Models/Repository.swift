import Foundation

struct Repository: Identifiable, Codable, Hashable {

    let id: Int
    let name: String
    let owner: Owner
    let description: String?
    let languagesURL: String

    enum CodingKeys: String, CodingKey {
        case id, name, owner, description
        case languagesURL = "languages_url"
    }
}
struct Owner: Codable, Hashable {
    let type: String
}
