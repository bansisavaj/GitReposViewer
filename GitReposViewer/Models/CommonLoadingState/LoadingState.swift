import Foundation

enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case failed(String)
}
