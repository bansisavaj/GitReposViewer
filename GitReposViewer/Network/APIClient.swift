import Foundation

final class APIClient {

    static let shared = APIClient()
    private init() {}

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        token: String? = nil,
        type: T.Type
    ) async throws -> T {

        guard await NetworkMonitor.shared.checkInternet() else {
            throw APIError.networkError
        }

        guard let url = endpoint.url else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Rate limit update (global)
        RateLimitHandler.shared.update(from: httpResponse.allHeaderFields)

        switch httpResponse.statusCode {
            case 200:
                break

            case 304:
                throw APIError.unknown

            case 403:
                throw APIError.rateLimited(
                    retryAfter: RateLimitHandler.shared.retryAfterSeconds()
                )

            case 404:
                throw APIError.notFound

            case 500...599:
                throw APIError.serverError

            default:
                throw APIError.unknown
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.invalidResponse
        }
    }

    static func requestWithHeaders<T: Decodable>(
        _ request: URLRequest,
        type: T.Type
    ) async throws -> (items: T, headers: [AnyHashable: Any]) {

        let (data, response) = try await URLSession.shared.data(for: request)

        let decoded = try JSONDecoder().decode(T.self, from: data)
        let headers = (response as? HTTPURLResponse)?.allHeaderFields ?? [:]

        return (items: decoded, headers: headers)
    }

}
