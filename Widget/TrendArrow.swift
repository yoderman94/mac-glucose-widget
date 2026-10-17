import Foundation

/// Maps the API's pydexcom `trend` int (0–9) to SF Symbol name(s) for crisp
/// rendering. Returns an empty array for unknown/none values (0, 8, 9, nil) —
/// callers should then fall back to the unicode `trend_arrow` string.
///
/// pydexcom trend values:
///   1 DoubleUp, 2 SingleUp, 3 FortyFiveUp, 4 Flat,
///   5 FortyFiveDown, 6 SingleDown, 7 DoubleDown,
///   0 None, 8 NotComputable, 9 RateOutOfRange
enum TrendArrow {
    static func symbols(trend: Int?) -> [String] {
        switch trend {
        case 1: return ["arrow.up", "arrow.up"]
        case 2: return ["arrow.up"]
        case 3: return ["arrow.up.right"]
        case 4: return ["arrow.right"]
        case 5: return ["arrow.down.right"]
        case 6: return ["arrow.down"]
        case 7: return ["arrow.down", "arrow.down"]
        default: return []
        }
    }
}
