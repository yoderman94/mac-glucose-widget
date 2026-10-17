import SwiftUI

/// Minimal host app. WidgetKit widgets ship inside an app; this window just
/// tells you how to add the widget.
@main
struct GlucoseWidgetApp: App {
    var body: some Scene {
        WindowGroup("Glucose Widget") {
            ContentView()
        }
        .defaultSize(width: 460, height: 300)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.fill")
                .font(.system(size: 40))
                .foregroundStyle(.red)
            Text("Glucose Widget")
                .font(.title2.bold())
            Text("This app just ships the widget. Add it from Notification Center "
                 + "or right-click the desktop → Edit Widgets, then search for "
                 + "\"Glucose\".")
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
            Text("Set your backend URL in config.env, then run ./install.sh.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(40)
    }
}
