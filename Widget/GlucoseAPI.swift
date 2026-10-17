import Foundation

enum GlucoseAPIError: Error {
    case badResponse
}

/// Fetches the current reading from your backend (see docs/API.md).
enum GlucoseAPI {
    static func fetchCurrent() async throws -> GlucoseReading {
        var request = URLRequest(url: Config.apiCurrentURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 10
        if !Config.apiToken.isEmpty {
            request.setValue("Bearer \(Config.apiToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw GlucoseAPIError.badResponse
        }
        return try JSONDecoder().decode(GlucoseReading.self, from: data)
    }
}
