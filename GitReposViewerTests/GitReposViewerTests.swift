import XCTest
@testable import GitReposViewer

@MainActor
final class GitReposViewerTests: XCTestCase {

    var viewModel: RepoListViewModel!
    var repoService: MockRepoService!
    var repoInfoService: MockRepoInfoService!
    var favoritesManager: FavoritesManager!
    var rateLimiter: MockRateLimiter!
    let defaultRepoInfo = RepoInfo(id: 1, language: "Swift", stargazersCount: 100)

    override func setUp() {
        repoService = MockRepoService()
        repoInfoService = MockRepoInfoService()
        favoritesManager = FavoritesManager()
        rateLimiter = MockRateLimiter()

        viewModel = RepoListViewModel(
            repoService: repoService,
            repoInfoService: repoInfoService,
            favoritesManager: favoritesManager,
            rateLimiter: rateLimiter
        )

        viewModel.resetRepoMetaCache()
    }

    override func tearDown() {
        viewModel = nil
        repoService = nil
        repoInfoService = nil
        favoritesManager = nil
        rateLimiter = nil
        super.tearDown()
    }

    func testLoadReposSuccess() async throws {
        await viewModel.loadRepos()
        XCTAssertEqual(viewModel.repos.count, 2)
        XCTAssertEqual(viewModel.state, .success)
    }

    func testLoadReposFailure() async throws {
        repoService.shouldThrow = true
        repoService.apiError = .networkError
        await viewModel.loadRepos()
        XCTAssertEqual(viewModel.state, .failed(APIError.networkError.message))
        XCTAssertTrue(viewModel.canRetry)
    }

    func testFilteredRepos() {
        let repos = [
            Repository(
                id: 101,
                name: "Alamofire",
                owner: Owner(type: "Organization", login: ""),
                description: "Elegant HTTP Networking in Swift"
            ),
            Repository(
                id: 102,
                name: "SwiftLint",
                owner: Owner(type: "User", login: ""),
                description: "A tool to enforce Swift style and conventions"
            ),
            Repository(
                id: 103,
                name: "SwiftLint",
                owner: Owner(type: "User", login: ""),
                description: "A tool to enforce Swift style and conventions"
            )
        ]
        viewModel.repos = repos

        viewModel.selectedFilter = .all
        XCTAssertEqual(viewModel.filteredRepos.count, 3)

        viewModel.selectedFilter = .user
        XCTAssertEqual(viewModel.filteredRepos.count, 2)
        XCTAssertTrue(viewModel.filteredRepos.contains { $0.id == 102 })

        viewModel.selectedFilter = .organization
        XCTAssertEqual(viewModel.filteredRepos.count, 1)
        XCTAssertEqual(viewModel.filteredRepos.first?.id, 101)
    }

    func testLoadRepoInfoIfNeededSuccess() async throws {
        let repo = makeRepo(id: 101, name: "Alamofire", ownerType: "Organization")
                repoInfoService.repoInfo = defaultRepoInfo
        await viewModel.loadRepoInfoIfNeeded(for: repo)
        XCTAssertEqual(viewModel.repoMetaCache[repo.id]?.language, "Swift")

    }

    func testLoadRepoInfoIfNeededWithCache() async throws {
        let repo = makeRepo(id: 102, name: "SwiftLint", ownerType: "User")
        viewModel.setRepoMetaCache(for: repo.id, repoCache:
                                    RepoMetaCache(language: "Swift",
                                                  stargazersCount: 100))
        repoInfoService.repoInfo = defaultRepoInfo
        await viewModel.loadRepoInfoIfNeeded(for: repo)
        XCTAssertEqual(viewModel.repoMetaCache[repo.id], RepoMetaCache(
            language: "Swift",
            stargazersCount: 100
        ))
    }

    func testLoadRepoInfoIfNeededFailure() async throws {
        let repo = makeRepo(id: 103, name: "Kingfisher", ownerType: "User")
        repoInfoService.shouldThrow = true
        await viewModel.loadRepoInfoIfNeeded(for: repo)
        XCTAssertNil(viewModel.repoMetaCache[repo.id])
    }

    func testLoadRepoInfoRespectsRateLimiter() async throws {
        let repo = makeRepo(id: 101, name: "Alamofire", ownerType: "Organization")
        rateLimiter.didWarnLowLimit = true
        repoInfoService.repoInfo = defaultRepoInfo
        await viewModel.loadRepoInfoIfNeeded(for: repo)
        XCTAssertNil(viewModel.repoMetaCache[repo.id])
    }

    private func makeRepo(id: Int, name: String, ownerType: String) -> Repository {
        Repository(
            id: id,
            name: name,
            owner: Owner(type: ownerType, login: ""),
            description: "Dummy description for \(name)"
        )
    }
}
