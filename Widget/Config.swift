import Foundation

/// Single place to configure how the widget reaches your backend.
/// `install.sh` overwrites the values in Config.generated.swift from config.env,
/// so you normally never edit this file. See docs/API.md for the JSON contract.
enum Config {
    /// Full URL of the endpoint that returns the current reading,
    /// for example "https://example.com/glucose.php".
    static let endpoint = GeneratedConfig.endpoint

    /// Optional shared secret. Sent as "Authorization: Bearer <token>" when set.
    static let apiToken = GeneratedConfig.apiToken

    static var apiCurrentURL: URL { URL(string: endpoint)! }
}
