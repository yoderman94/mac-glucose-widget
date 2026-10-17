import WidgetKit
import SwiftUI

struct GlucoseWidget: Widget {
    let kind = "GlucoseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GlucoseProvider()) { entry in
            GlucoseWidgetView(entry: entry)
        }
        .configurationDisplayName("Glucose")
        .description("Live blood sugar from your Dexcom Share backend.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
