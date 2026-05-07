import Combine

@MainActor
final class GroupingByRepoViewModel: ObservableObject {

    // MARK: - UI State

    @Published private(set) var groupedRepos: [RepoGroup] = []
    @Published var grouping: GroupingType = .none

    // MARK: - Dependencies

    let favoritesManager: FavoritesManager
    private let repoMetaCacheProvider: () -> [Int: RepoMetaCache]

    // MARK: - Data

    private var repos: [Repository] = []

    // MARK: - Init

    init(
        repoMetaCacheProvider: @escaping () -> [Int: RepoMetaCache],
        favoritesManager: FavoritesManager
    ) {
        self.repoMetaCacheProvider = repoMetaCacheProvider
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

        let cache = repoMetaCacheProvider()

        switch grouping {
            case .stars:
                groupedRepos = groupByStars(cache: cache)
            case .language:
                groupedRepos = groupByLanguage(cache: cache)
            case .none:
                break
        }
    }

    // MARK: - Grouping strategies
    private func groupByStars(cache: [Int: RepoMetaCache]) -> [RepoGroup] {

        let validRepos = repos.filter {
            cache[$0.id]?.stargazersCount != nil
        }
        let grouped = Dictionary(grouping: validRepos) { repo in
            let stars = cache[repo.id]?.stargazersCount ?? 0
            return band(for: stars)
        }

        let order: [StarBand] = [.trending, .popular, .growing, .new]

        return order.map { band in
            RepoGroup(
                title: band.title,
                repos: grouped[band] ?? []
            )
        }
    }

    private func groupByLanguage(cache: [Int: RepoMetaCache]) -> [RepoGroup] {
        let grouped = Dictionary(grouping: repos) { repo in
            cache[repo.id]?.language ?? ""
        }

        return grouped
            .map { RepoGroup(title: $0.key, repos: $0.value) }
            .sorted { $0.title < $1.title }
    }

    private func band(for stars: Int) -> StarBand {
        switch stars {
            case 0...10: return .new
            case 11...100: return .growing
            case 101...1000: return .popular
            default: return .trending
        }
    }

}
