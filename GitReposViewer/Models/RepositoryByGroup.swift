import Foundation

struct RepoGroup: Identifiable {
    let title: String
    let repos: [Repository]

    var id: String {
        title
    }
}
