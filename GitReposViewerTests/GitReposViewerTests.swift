import XCTest
@testable import GitReposViewer

@MainActor
final class GitReposViewerTests: XCTestCase {

    var viewModel: RepoListViewModel!
    var repoService: MockRepoService!
    var languageService: MockLanguageService!
    var favoritesManager: FavoritesManager!
    var rateLimiter: MockRateLimiter!

    override func setUp() async throws {
        try await super.setUp()
        repoService = MockRepoService()
        languageService = MockLanguageService()
        favoritesManager = FavoritesManager()
        rateLimiter = MockRateLimiter()
        viewModel = RepoListViewModel(
            repoService: repoService,
            languageService: languageService,
            favoritesManager: favoritesManager,
            rateLimiter: rateLimiter
        )
        viewModel.resetLanguageCache()
    }

    override func tearDown() {
        viewModel = nil
        repoService = nil
        languageService = nil
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
                owner: Owner(type: "Organization"),
                description: "Elegant HTTP Networking in Swift",
                languagesURL: "https://api.github.com/repos/Alamofire/Alamofire/languages"
            ),
            Repository(
                id: 102,
                name: "SwiftLint",
                owner: Owner(type: "User"),
                description: "A tool to enforce Swift style and conventions",
                languagesURL: "https://api.github.com/repos/realm/SwiftLint/languages"
            ),
            Repository(
                id: 103,
                name: "SwiftLint",
                owner: Owner(type: "User"),
                description: "A tool to enforce Swift style and conventions",
                languagesURL: "https://api.github.com/repos/realm/SwiftLint/languages"
            )
        ]
        viewModel.repos = repos

        viewModel.selectedFilter = .all
        XCTAssertEqual(viewModel.filteredRepos.count, 3)

        viewModel.selectedFilter = .user
        XCTAssertEqual(viewModel.filteredRepos.count, 2)
        XCTAssertEqual(viewModel.filteredRepos.first?.id, 102)

        viewModel.selectedFilter = .organization
        XCTAssertEqual(viewModel.filteredRepos.count, 1)
        XCTAssertEqual(viewModel.filteredRepos.first?.id, 101)
    }

    func testLoadLanguageIfNeededSuccess() async throws {
        let repo = makeRepo(id: 101, name: "Alamofire", ownerType: "Organization")
        languageService.languages = ["Swift": 90000, "Objective-C": 10000]
        await viewModel.loadLanguageIfNeeded(for: repo)
        XCTAssertEqual(viewModel.languageCache[repo.id], "Swift")
    }

    func testLoadLanguageIfNeededWithCache() async throws {
        let repo = makeRepo(id: 102, name: "SwiftLint", ownerType: "User")
        viewModel.setLanguageCache(for: repo.id, language: "Ruby")
        languageService.languages = ["Swift": 80000, "Ruby": 20000]
        await viewModel.loadLanguageIfNeeded(for: repo)
        XCTAssertEqual(viewModel.languageCache[repo.id], "Ruby")
    }

    func testLoadLanguageIfNeededFailure() async throws {
        let repo = makeRepo(id: 103, name: "Kingfisher", ownerType: "User")
        languageService.shouldThrow = true
        await viewModel.loadLanguageIfNeeded(for: repo)
        XCTAssertNil(viewModel.languageCache[repo.id])
    }

    func testLoadLanguageRespectsRateLimiter() async throws {
        let repo = makeRepo(id: 101, name: "Alamofire", ownerType: "Organization")
        rateLimiter.didWarnLowLimit = true
        languageService.languages = ["Swift": 90000]
        await viewModel.loadLanguageIfNeeded(for: repo)
        XCTAssertNil(viewModel.languageCache[repo.id])
    }

    private func makeRepo(id: Int, name: String, ownerType: String) -> Repository {
        Repository(
            id: id,
            name: name,
            owner: Owner(type: ownerType),
            description: "Dummy description for \(name)",
            languagesURL: "https://api.github.com/repos/\(name)/languages"
        )
    }
}
