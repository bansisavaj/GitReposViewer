import Foundation
import Combine

struct RepoMetaCache: Codable, Hashable {
    let language: String
    let stargazersCount: Int
}

@MainActor
final class RepoListViewModel: ObservableObject {

    // MARK: - UI State

    @Published var repos: [Repository] = []
    @Published var selectedFilter: RepoFilter = .all
    @Published private(set) var state: LoadingState = .idle
    @Published var path: [Route] = []

    // MARK: - Services

    private let repoService: RepositoryServiceProtocol
    private let repoInfoService: RepoInfoServiceProtocol
    let favoritesManager: FavoritesManager
    private let rateLimiter: RateLimitHandling

    // MARK: - Derived State
    var filteredRepos: [Repository] {
        repos.filter { repo in
            switch selectedFilter {
                case .all:
                    return true
                case .user:
                    return repo.owner.type == "User"
                case .organization:
                    return repo.owner.type == "Organization"
                case .favorites:
                    return favoritesManager.favorites.contains(repo.id)
            }
        }
    }

    // MARK: - Repo Meta Cache

    private(set) var repoMetaCache: [Int: RepoMetaCache] = [:]
    private let cacheKey = "repo_meta_cache"

    /// Tracks in-flight requests (prevents duplicate calls)
    private var inFlightRequests: Set<Int> = []

    // MARK: - Retry State

    var canRetry: Bool = false

    // MARK: - Routing

    enum Route: Hashable {
        case groupByLanguage([Repository])
        case groupByStar([Repository])
    }

    // MARK: - Init

    init(
        repoService: RepositoryServiceProtocol,
        repoInfoService: RepoInfoServiceProtocol,
        favoritesManager: FavoritesManager,
        rateLimiter: RateLimitHandling
    ) {
        self.repoService = repoService
        self.repoInfoService = repoInfoService
        self.favoritesManager = favoritesManager
        self.rateLimiter = rateLimiter

        loadCache()
    }

    // MARK: - Public API

    func updateFilter(_ filter: RepoFilter) {
        selectedFilter = filter
    }

    func toggleFavorite(_ repo: Repository) {
        favoritesManager.toggleFavorite(repo)
    }

    // MARK: - Data Loading

    func loadRepos() async {
        state = .loading

        do {
            let result = try await repoService.fetchRepositories()
            repos = result
            state = .success
        } catch let error as APIError {
            canRetry = error.isRetryable
            state = .failed(error.message)
        } catch {
            state = .failed("Unexpected error")
        }
    }

    // MARK: - Repo Info Loading

    func loadRepoInfoIfNeeded(for repo: Repository) async {
        let id = repo.id

        guard repoMetaCache[id] == nil else { return }
        guard !inFlightRequests.contains(id) else { return }
        guard !rateLimiter.didWarnLowLimit else { return }

        inFlightRequests.insert(id)

        defer {
            inFlightRequests.remove(id)
        }

        do {
            let dict = try await repoInfoService.fetchRepoInfo(owner: repo.owner.login, repo: repo.name)

            repoMetaCache[id] = RepoMetaCache(
                language: dict.language,
                stargazersCount: dict.stargazersCount
            )

            saveCache()

        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Persistence

    private func loadCache() {
        guard
            let data = UserDefaults.standard.data(forKey: cacheKey),
            let decoded = try? JSONDecoder().decode([Int: RepoMetaCache].self, from: data)
        else { return }

        repoMetaCache = decoded
    }

    private func saveCache() {
        guard let data = try? JSONEncoder().encode(repoMetaCache) else { return }

        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}
// MARK: - Test Helpers

@MainActor
extension RepoListViewModel {
    /// Resets RepoMeta cache and optionally clears UserDefaults (for isolated testing)
    func resetRepoMetaCache(clearUserDefaults: Bool = false) {
        repoMetaCache = [:]
        if clearUserDefaults {
            UserDefaults.standard.removeObject(forKey: cacheKey)
        }
    }
    func setRepoMetaCache(for repoID: Int, repoCache: RepoMetaCache) {
        repoMetaCache[repoID] = RepoMetaCache(
            language: repoCache.language,
            stargazersCount: repoCache.stargazersCount
        )
    }
}
