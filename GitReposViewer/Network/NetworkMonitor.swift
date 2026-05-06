import Foundation

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    func checkInternet() async -> Bool {
        guard let url = URL(string: "https://clients3.google.com/generate_204") else {
            return false
        }

        do {
            let (_, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 204
            }
            return false
        } catch {
            return false
        }
    }
}
