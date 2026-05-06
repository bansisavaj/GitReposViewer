import Foundation
import Combine

@MainActor
final class FavoritesManager: ObservableObject {

    // MARK: - State

    @Published var favorites: Set<Int> = []

    private let storage: UserDefaults
    private let key: String

    // MARK: - Init

    init(
        storage: UserDefaults = .standard,
        key: String = "favorite_repos"
    ) {
        self.storage = storage
        self.key = key
        loadFavorites()
    }

    // MARK: - Public API

    func isFavorite(_ id: Int) -> Bool {
        favorites.contains(id)
    }

    func toggleFavorite(_ repo: Repository) {
        if favorites.contains(repo.id) {
            favorites.remove(repo.id)
        } else {
            favorites.insert(repo.id)
        }

        persist()
    }

    // MARK: - Private

    private func loadFavorites() {
        let stored = storage.array(forKey: key) as? [Int] ?? []
        favorites = Set(stored)
    }

    private func persist() {
        storage.set(Array(favorites), forKey: key)
    }
}
