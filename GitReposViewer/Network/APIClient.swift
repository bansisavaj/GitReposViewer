import Foundation

final class APIClient {

    static let shared = APIClient()
    private init() {}

    // MARK: - Public API

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        token: String? = nil,
        type: T.Type
    ) async throws -> T {

        let request = try await makeRequest(endpoint, token: token)

        let (data, response) = try await URLSession.shared.data(for: request)

        let httpResponse = try validateResponse(response)

        try handleStatusCode(httpResponse)

        return try decode(data, type: T.self)
    }

    // MARK: - Request Builder

    private func makeRequest(
        _ endpoint: APIEndpoint,
        token: String?
    ) async throws -> URLRequest {

        guard await NetworkMonitor.shared.checkInternet() else {
            throw APIError.networkError
        }

        var request = URLRequest(url: endpoint.url)

        if let token {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    // MARK: - Response Validation

    private func validateResponse(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Rate limit tracking
        RateLimitHandler.shared.update(from: httpResponse.allHeaderFields)

        return httpResponse
    }

    // MARK: - Status Handling

    private func handleStatusCode(_ response: HTTPURLResponse) throws {
        switch response.statusCode {

            case 200:
                return

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
    }

    // MARK: - Decoding

    private func decode<T: Decodable>(_ data: Data, type: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            print(error.localizedDescription)
            throw APIError.invalidResponse
        }
    }
}
