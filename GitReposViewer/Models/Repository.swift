import Foundation

struct Repository: Identifiable, Codable, Hashable {

    let id: Int
    let name: String
    let owner: Owner
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id, name, owner, description
    }
}
struct Owner: Codable, Hashable {
    let type: String
    let login: String
}
