import WidgetKit
import Foundation

/// A single timeline entry. Holds the decoded reading (or nil when the fetch
/// failed entirely — for example, no network), plus a flag so the view can show
/// an "unreachable" state distinct from a stale-but-known value.
struct GlucoseEntry: TimelineEntry {
    let date: Date
    let reading: GlucoseReading?
    let unreachable: Bool

    /// Range color, derived from the reading. Missing value or stale -> gray.
    var range: GlucoseRange {
        GlucoseRange.from(value: reading?.value, stale: reading?.stale ?? true)
    }

    /// A plausible in-range sample for the widget gallery / placeholder.
    static let placeholder = GlucoseEntry(
        date: Date(),
        reading: GlucoseReading(
            available: true, value: 120, mmolL: 6.7, trend: 4,
            trendDirection: "Flat", trendDescription: "steady", trendArrow: "→",
            minutesAgo: 2, stale: false, readingTime: nil, message: nil
        ),
        unreachable: false
    )
}
