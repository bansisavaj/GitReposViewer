import Foundation

enum RepoFilter: String, CaseIterable {
    case all = "All"
    case user = "User"
    case organization = "Organization"
    case favorites = "Favorites"
}

enum GroupingType {
    case none
    case language
    case stars
}
