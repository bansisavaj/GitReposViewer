import Foundation
@testable import GitReposViewer

final class MockRateLimiter: RateLimitHandling {
    var didWarnLowLimit = false
    func update(from headers: [AnyHashable : Any]) {}
    func isRateLimited() -> Bool { false }
    func retryAfterSeconds() -> Int? { 10 }
}
