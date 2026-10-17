import Foundation

/// Mirrors the JSON shape of `GET /api/current` on your backend.
/// Handles both the `available:true` payload and the `available:false` fallback.
struct GlucoseReading: Codable, Equatable {
    let available: Bool
    let value: Int?
    let mmolL: Double?
    let trend: Int?
    let trendDirection: String?
    let trendDescription: String?
    let trendArrow: String?
    let minutesAgo: Int?
    let stale: Bool?
    let readingTime: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case available, value, trend, stale, message
        case mmolL = "mmol_l"
        case trendDirection = "trend_direction"
        case trendDescription = "trend_description"
        case trendArrow = "trend_arrow"
        case minutesAgo = "minutes_ago"
        case readingTime = "reading_time"
    }
}
