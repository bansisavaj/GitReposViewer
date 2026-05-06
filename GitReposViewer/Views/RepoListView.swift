import SwiftUI

struct RepoListView: View {

    @StateObject private var viewModel: RepoListViewModel

    init(
        repoService: RepositoryServiceProtocol,
        favoritesManager: FavoritesManager,
        rateLimiter: RateLimitHandling,
        languageService: LanguageServiceProtocol
    ) {

        let repoVM = RepoListViewModel(
            repoService: repoService,
            languageService: languageService,
            favoritesManager: favoritesManager,
            rateLimiter: rateLimiter
        )

        _viewModel = StateObject(wrappedValue: repoVM)
    }

    var body: some View {

        NavigationStack(path: $viewModel.path) {

            VStack(spacing: 0) {

                headerControls

                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("GitHub Repos")
            .task {
                guard viewModel.repos.isEmpty else { return }
                await viewModel.loadRepos()
            }
            .navigationDestination(for: RepoListViewModel.Route.self) { route in
                routeView(route)
            }
        }
    }
}
private extension RepoListView {

    @ViewBuilder
    func routeView(_ route: RepoListViewModel.Route) -> some View {
        switch route {

            case .groupByLanguage(let repos):

                let vm = LanguageByGroupViewModel(
                    languageCacheProvider: { viewModel.languageCache },
                    favoritesManager: viewModel.favoritesManager
                )

                LanguageGroupView(
                    viewModel: vm
                )
                .task {
                    vm.grouping = .language
                    vm.load(repos: repos)
                }

            case .groupByStar:
                VStack {
                    Text("Group by Stars")
                        .font(.headline)

                    Text("This feature is not implemented yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
        }
    }
}
private extension RepoListView {

    @ViewBuilder
    var headerControls: some View {

        if !viewModel.repos.isEmpty {

            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(RepoFilter.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Menu("Group By") {

                Button("Language") {
                    viewModel.path.append(.groupByLanguage(viewModel.filteredRepos))
                }

                Button("Stars") {
                    viewModel.path.append(.groupByStar(viewModel.filteredRepos))
                }
            }
            .padding()
        }
    }
}
private extension RepoListView {

    @ViewBuilder
    var contentView: some View {

        switch viewModel.state {

            case .loading:
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }

            case .failed(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .multilineTextAlignment(.center)

                    if viewModel.canRetry {
                        Button("Retry") {
                            Task {
                                await viewModel.loadRepos()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()

            default:
                if viewModel.filteredRepos.isEmpty {
                    VStack {
                        Spacer()
                        Text("No repositories found")
                        Spacer()
                    }
                } else {
                    repoList
                }
        }
    }
}
private extension RepoListView {

    var repoList: some View {
        List {

            ForEach(viewModel.filteredRepos, id: \.id) { repo in

                RepoRowView(
                    repo: repo,
                    onFavoriteTap: {
                        viewModel.toggleFavorite(repo)
                    },
                    favoritesManager: viewModel.favoritesManager
                )
                .task {
                    await viewModel.loadLanguageIfNeeded(for: repo)
                }
                
            }
        }
        .contentMargins(.top, 24)
    }
}
