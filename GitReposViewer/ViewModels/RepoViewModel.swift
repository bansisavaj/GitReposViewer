import Foundation
import Combine

@MainActor
final class RepoListViewModel: ObservableObject {

    // MARK: - UI State

    @Published var repos: [Repository] = []
    @Published var selectedFilter: RepoFilter = .all
    @Published private(set) var state: LoadingState = .idle
    @Published var path: [Route] = []
    @Published var canRetry: Bool = false

    // MARK: - Services

    private let repoService: RepositoryServiceProtocol
    private let languageService: LanguageServiceProtocol
    let favoritesManager: FavoritesManager
    private let rateLimiter: RateLimitHandling

    // MARK: - Language cache

    @Published private(set) var languageCache: [Int: String] = [:]

    /// Tracks in-flight requests (prevents duplicate calls)
    private var inFlightRequests: Set<Int> = []

//    @Published var pagination: PaginationManager<Repository>

    // MARK: - Routing

    enum Route: Hashable {
        case groupByLanguage([Repository])
        case groupByStar([Repository])
    }

    // MARK: - Init

    init(
        repoService: RepositoryServiceProtocol,
        languageService: LanguageServiceProtocol,
        favoritesManager: FavoritesManager,
        rateLimiter: RateLimitHandling
    ) {
        self.repoService = repoService
        self.languageService = languageService
        self.favoritesManager = favoritesManager
        self.rateLimiter = rateLimiter
        loadCache()
    }
    // MARK: - Derived state

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

    func updateFilter(_ filter: RepoFilter) {
        selectedFilter = filter
    }

    // MARK: - Data loading

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

//    func loadRepos() async {
//        state = .loading
//        do {
//            await pagination.loadMore()
//            state = .success
//        } catch let error as APIError {
//            canRetry = error.isRetryable
//            state = .failed(error.message)
//        } catch {
//            state = .failed("Unexpected error")
//        }
//    }
//
//    func loadNextPageIfNeeded(currentItem: Repository) async {
//        guard !pagination.isLoading else { return }
//        guard let last = repos.last, last.id == currentItem.id else { return }
//        guard pagination.canLoadMore else { return }
//
//        await loadRepos()
//    }

    // MARK: - Favorites

    func toggleFavorite(_ repo: Repository) {
        favoritesManager.toggleFavorite(repo)
    }

    // MARK: - Language loading

    func loadLanguageIfNeeded(for repo: Repository) async {
        let id = repo.id

        guard languageCache[id] == nil else { return }
        guard !inFlightRequests.contains(id) else { return }
        guard !rateLimiter.didWarnLowLimit else { return }

        inFlightRequests.insert(id)

        defer {
            inFlightRequests.remove(id)
        }

        do {
            let dict = try await languageService.fetchLanguages(url: repo.languagesURL)

            let dominantLanguage = dict.max(by: { $0.value < $1.value })?.key ?? ""

            languageCache[id] = dominantLanguage
            saveCache()

        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Persistence

    private let cacheKey = "repo_language_cache"

    private func loadCache() {
        guard
            let data = UserDefaults.standard.data(forKey: cacheKey),
            let decoded = try? JSONDecoder().decode([Int: String].self, from: data)
        else { return }

        languageCache = decoded
    }

    private func saveCache() {
        guard let data = try? JSONEncoder().encode(languageCache) else { return }

        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}
