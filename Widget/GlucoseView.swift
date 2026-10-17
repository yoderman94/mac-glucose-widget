import SwiftUI
import WidgetKit

/// Range -> background color:
/// green #1b5e20, yellow #8d6e00, red #7f1d1d, gray #2b2b2b.
extension GlucoseRange {
    var background: Color {
        switch self {
        case .green:  return Color(red: 0.106, green: 0.369, blue: 0.125)
        case .yellow: return Color(red: 0.553, green: 0.431, blue: 0.0)
        case .red:    return Color(red: 0.498, green: 0.114, blue: 0.114)
        case .gray:   return Color(red: 0.169, green: 0.169, blue: 0.169)
        }
    }
}

struct GlucoseWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: GlucoseEntry

    var body: some View {
        Group {
            switch family {
            case .systemMedium: mediumView
            default: smallView
            }
        }
        .foregroundStyle(.white)
        .opacity(isStale ? 0.5 : 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(entry.range.background, for: .widget)
    }

    // MARK: - Families

    private var smallView: some View {
        VStack(spacing: 2) {
            Text(valueText)
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            arrows(size: 26)
            Text(agoText)
                .font(.caption2)
                .opacity(0.85)
        }
        .padding(8)
    }

    private var mediumView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(valueText)
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    arrows(size: 24)
                }
                Text("mg/dL").font(.caption).opacity(0.7)
            }
            Spacer(minLength: 12)
            VStack(alignment: .trailing, spacing: 6) {
                if let desc = descriptionText {
                    Text(desc).font(.headline).lineLimit(2).multilineTextAlignment(.trailing)
                }
                Text(agoText).font(.subheadline).opacity(0.9)
            }
        }
        .padding()
    }

    // MARK: - Trend arrows

    @ViewBuilder
    private func arrows(size: CGFloat) -> some View {
        let symbols = TrendArrow.symbols(trend: entry.reading?.trend)
        if symbols.isEmpty {
            Text(entry.reading?.trendArrow ?? "")
                .font(.system(size: size, weight: .bold))
        } else {
            HStack(spacing: -size * 0.15) {
                ForEach(Array(symbols.enumerated()), id: \.offset) { _, name in
                    Image(systemName: name)
                        .font(.system(size: size, weight: .bold))
                }
            }
        }
    }

    // MARK: - Derived text

    private var isStale: Bool { entry.reading?.stale ?? true }

    private var valueText: String {
        if let v = entry.reading?.value, entry.reading?.available == true {
            return "\(v)"
        }
        return "—"
    }

    private var descriptionText: String? {
        guard entry.reading?.available == true,
              let desc = entry.reading?.trendDescription, !desc.isEmpty else { return nil }
        return desc.prefix(1).uppercased() + desc.dropFirst()
    }

    private var agoText: String {
        if entry.unreachable { return "unreachable" }
        guard let m = entry.reading?.minutesAgo else { return "—" }
        let prefix = isStale ? "STALE — " : ""
        switch m {
        case ..<1: return prefix + "just now"
        case 1:    return prefix + "1 min ago"
        default:   return "\(prefix)\(m) min ago"
        }
    }
}
