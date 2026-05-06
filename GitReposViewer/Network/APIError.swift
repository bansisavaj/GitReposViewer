import Foundation

enum APIError: Error {

    case rateLimited(retryAfter: Int?)
    case notFound
    case invalidResponse
    case serverError
    case networkError
    case unknown

    var message: String {
        switch self {

            case .rateLimited(let retryAfter):
                if let retryAfter {
                    return "Rate limit exceeded. Try again in \(retryAfter / 60) min."
                }
                return "Rate limit exceeded. Please try again later."

            case .notFound:
                return "Requested resource not found."

            case .invalidResponse:
                return "Invalid request sent to server."

            case .serverError:
                return "Server error. Please try again later."

            case .networkError:
                return "No internet connection. Please check your network."

            case .unknown:
                return "Something went wrong."
        }
    }

    var isRetryable: Bool {
        switch self {
            case .networkError:
                return true
            default:
                return false
        }
    }
}
