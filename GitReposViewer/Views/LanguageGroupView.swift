import SwiftUI

struct LanguageGroupView: View {

    @ObservedObject var viewModel: LanguageByGroupViewModel

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
        .navigationTitle("By Language")
    }
}
