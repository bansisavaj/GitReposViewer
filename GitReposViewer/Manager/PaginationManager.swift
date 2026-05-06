import Foundation
import Combine

@MainActor
final class PaginationManager<Item>: ObservableObject {

    @Published private(set) var items: [Item] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var canLoadMore: Bool = true

    private var nextURL: URL?
    private let fetcher: (URL?) async throws -> (items: [Item], nextURL: URL?)

    init(initialURL: URL?, fetcher: @escaping (URL?) async throws -> (items: [Item], nextURL: URL?)) {
        self.nextURL = initialURL
        self.fetcher = fetcher
    }

    func loadMore() async {
        guard !isLoading, canLoadMore else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await fetcher(nextURL)
            items.append(contentsOf: result.items)
            nextURL = result.nextURL
            canLoadMore = nextURL != nil
        } catch {
            print("Pagination fetch error:", error)
            canLoadMore = false
        }
    }

    func reset(with url: URL?) {
        items = []
        nextURL = url
        canLoadMore = true
    }
}
extension Dictionary where Key == AnyHashable, Value == Any {
    func githubNextPageURL() -> URL? {
        guard let linkHeader = self["Link"] as? String else { return nil }
        // Example: <https://api.github.com/repositories?since=364>; rel="next", <...>; rel="last"
        let links = linkHeader.split(separator: ",")
        for link in links {
            let parts = link.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2, parts[1] == #"rel="next""# {
                let urlString = parts[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                return URL(string: urlString)
            }
        }
        return nil
    }
}
