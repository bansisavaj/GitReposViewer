import Combine

@MainActor
final class LanguageByGroupViewModel: ObservableObject {

    // MARK: - UI State

    @Published private(set) var groupedRepos: [RepoGroup] = []
    @Published var grouping: GroupingType = .language

    // MARK: - Dependencies

    let favoritesManager: FavoritesManager
    private let languageCacheProvider: () -> [Int: String]

    // MARK: - Data

    private var repos: [Repository] = []

    // MARK: - Init

    init(
        languageCacheProvider: @escaping () -> [Int: String],
        favoritesManager: FavoritesManager
    ) {
        self.languageCacheProvider = languageCacheProvider
        self.favoritesManager = favoritesManager
    }

    // MARK: - Public API

    func load(repos: [Repository]) {
        self.repos = repos
        updateGrouping()
    }

    func toggleFavorite(_ repo: Repository) {
        favoritesManager.toggleFavorite(repo)
    }

    // MARK: - Grouping

    private func updateGrouping() {
        guard !repos.isEmpty else {
            groupedRepos = []
            return
        }

        let cache = languageCacheProvider()

        switch grouping {
            case .stars:
                groupedRepos = groupByStars()
            case .language:
                groupedRepos = groupByLanguage(cache: cache)
        }
    }

    // MARK: - Grouping strategies
    private func groupByStars() -> [RepoGroup] {
        [RepoGroup(title: "All (Stars)", repos: repos)]
    }

    private func groupByLanguage(cache: [Int: String]) -> [RepoGroup] {
        let grouped = Dictionary(grouping: repos) { repo in
            cache[repo.id] ?? ""
        }
        return grouped
            .map { RepoGroup(title: $0.key, repos: $0.value) }
            .sorted { $0.title < $1.title }
    }
}

// MARK: - Constants 
private enum GroupingConstants {
    static let unknownLanguage = ""
}
