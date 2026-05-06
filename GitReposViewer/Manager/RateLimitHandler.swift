import Foundation
import Combine

protocol RateLimitHandling {
    var didWarnLowLimit: Bool { get }
    func update(from headers: [AnyHashable: Any])
    func isRateLimited() -> Bool
    func retryAfterSeconds() -> Int?
}

@MainActor
final class RateLimitHandler: ObservableObject, RateLimitHandling {

    // MARK: - Singleton (optional but kept as-is)
    static let shared = RateLimitHandler()
    private init() {}

    // MARK: - State

    private(set) var resetDate: Date?
    private(set) var remainingRequests: Int = 0

    @Published private var didHitLowLimit = false

    var didWarnLowLimit: Bool {
        didHitLowLimit
    }

    var onLowLimitWarning: (() -> Void)?

    // MARK: - Update

    func update(from headers: [AnyHashable: Any]) {

        updateResetDate(from: headers)
        updateRemainingRequests(from: headers)
    }

    // MARK: - Helpers

    private func updateResetDate(from headers: [AnyHashable: Any]) {
        guard
            let reset = headers["x-ratelimit-reset"] as? String,
            let timestamp = Double(reset)
        else { return }

        resetDate = Date(timeIntervalSince1970: timestamp)
    }

    private func updateRemainingRequests(from headers: [AnyHashable: Any]) {

        guard
            let remainingStr = headers["x-ratelimit-remaining"] as? String,
            let remaining = Int(remainingStr)
        else { return }

        remainingRequests = remaining

        if remaining <= 5 {
            triggerLowLimitWarningIfNeeded()
        } else {
            didHitLowLimit = false
        }
    }

    private func triggerLowLimitWarningIfNeeded() {
        guard !didHitLowLimit else { return }
        didHitLowLimit = true
        onLowLimitWarning?()
    }

    // MARK: - Rate limit checks

    func isRateLimited() -> Bool {
        guard let resetDate else { return false }
        return Date() < resetDate
    }

    func retryAfterSeconds() -> Int? {
        guard let resetDate else { return nil }
        return max(0, Int(resetDate.timeIntervalSinceNow))
    }
}
