import SwiftUI

struct RepoRowView: View {

    let repo: Repository
    let onFavoriteTap: () -> Void
    @ObservedObject var favoritesManager = FavoritesManager()

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(repo.name)
                    .font(.headline)

                Spacer()

                Button(action: onFavoriteTap) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }

            Text(repo.description?.cleaned ?? "No description available")
                .lineLimit(2)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(repo.owner.type)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Derived state
    private var isFavorite: Bool {
        favoritesManager.isFavorite(repo.id)
    }
}
