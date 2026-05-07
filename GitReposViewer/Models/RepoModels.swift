import Foundation

enum RepoFilter: String, CaseIterable {
    case all = "All"
    case user = "User"
    case organization = "Organization"
    case favorites = "Favorites"
}

enum GroupingType: String {
    case none = ""
    case language = "By Language"
    case stars = "By Stars"
}

enum StarBand: Int, CaseIterable {
    case new = 0
    case growing
    case popular
    case trending

    var title: String {
        switch self {
            case .new: return "🌱 New & Unnoticed"
            case .growing: return "🌿 Gaining traction"
            case .popular: return "⭐ Popular"
            case .trending: return "🔥 Trending repositories"
        }
    }
}


struct RepoGroup: Identifiable {
    let title: String
    let repos: [Repository]

    var id: String {
        title
    }
}

