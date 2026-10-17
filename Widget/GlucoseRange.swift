import Foundation

/// Blood-sugar range classification. SINGLE source of truth for range thresholds.
///
/// Default thresholds (mg/dL). Edit them here to suit your care plan:
///   value == nil        -> gray
///   value < 55 || > 250 -> red
///   value < 70 || > 180 -> yellow
///   otherwise           -> green
/// A stale reading (the API's `stale` flag) forces gray.
enum GlucoseRange: Equatable {
    case red, yellow, green, gray

    static func from(value: Int?, stale: Bool) -> GlucoseRange {
        if stale { return .gray }
        guard let v = value else { return .gray }
        if v < 55 || v > 250 { return .red }
        if v < 70 || v > 180 { return .yellow }
        return .green
    }
}
