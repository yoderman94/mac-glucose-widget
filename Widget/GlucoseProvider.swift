import WidgetKit

/// Drives the widget timeline. WidgetKit throttles refreshes, so we target a
/// short cadence and always surface "X min ago" so staleness is visible.
struct GlucoseProvider: TimelineProvider {
    func placeholder(in context: Context) -> GlucoseEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (GlucoseEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }
        Task { completion(await fetchEntry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GlucoseEntry>) -> Void) {
        Task {
            let entry = await fetchEntry()
            // Retry sooner when unreachable (network or backend hiccup); otherwise
            // ~2 min (Dexcom updates ~every 5 min; WidgetKit throttles anyway).
            let minutes = entry.unreachable ? 1 : 2
            let next = Calendar.current.date(byAdding: .minute, value: minutes, to: Date())
                ?? Date().addingTimeInterval(120)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    private func fetchEntry() async -> GlucoseEntry {
        do {
            let reading = try await GlucoseAPI.fetchCurrent()
            return GlucoseEntry(date: Date(), reading: reading, unreachable: false)
        } catch {
            return GlucoseEntry(date: Date(), reading: nil, unreachable: true)
        }
    }
}
