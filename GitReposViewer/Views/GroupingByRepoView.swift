import SwiftUI

struct GroupingByRepoView: View {

    @ObservedObject var viewModel: GroupingByRepoViewModel

    var body: some View {

        List {
            ForEach(viewModel.groupedRepos) { group in

                if !group.title.isEmpty && !group.repos.isEmpty {

                    Section(header: Text(group.title)) {

                        ForEach(group.repos) { repo in

                            RepoRowView(
                                repo: repo,
                                onFavoriteTap: {
                                    viewModel.toggleFavorite(repo)
                                },
                                favoritesManager: viewModel.favoritesManager
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.grouping.rawValue)
    }
}
