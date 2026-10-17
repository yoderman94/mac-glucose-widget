# Setup guide for AI coding agents

You are helping a user install a macOS glucose widget. Read this whole file first. Work through the steps in order. Ask one question at a time. Never print or commit the user's passwords or tokens.

## Project map
- `App/`: tiny host app (WidgetKit widgets must ship inside an app).
- `Widget/`: the WidgetKit extension. `Config.swift` reads `Config.generated.swift`, which `install.sh` writes from `config.env`.
- `Tests/`: unit tests for range colors, trend arrows, and JSON decoding.
- `backend/php/`: optional reference backend for a PHP web host.
- `docs/API.md`: the JSON contract any backend must follow.
- `project.yml`: XcodeGen spec. The `.xcodeproj` is generated and gitignored. Don't edit it by hand.
- `install.sh`: generate, build, sign, install to `/Applications`, register, verify.

## Step 1. Check the Mac
Run and report anything missing:
```bash
sw_vers -productVersion          # needs 14.0 or newer
xcode-select -p                  # must point into Xcode.app, not CommandLineTools
xcodebuild -version
brew --version
xcodegen --version || brew install xcodegen
```
If `xcode-select -p` points to CommandLineTools, ask the user to run `sudo xcode-select -s /Applications/Xcode.app`.

## Step 2. Apple signing
The user must sign in to Xcode → Settings → Accounts with an Apple ID. A free account works. You can't do this for them (password + 2FA).

Find the team ID:
```bash
security find-identity -v -p codesigning
```
The 10-character ID in parentheses after "Apple Development: ..." is the team ID. If nothing shows, ask the user to open Xcode → Settings → Accounts, select the Apple ID, and click "Manage Certificates" → "+" → "Apple Development". If several show, ask which one to use.

## Step 3. Check the data source
Ask the user:
1. Does the person who wears the CGM use the Dexcom app with **Share turned on and at least one follower**? If not, stop and explain they must turn it on in the Dexcom app first.
2. Do they already have a backend that returns the JSON in `docs/API.md`? If yes, get its URL and token and skip to Step 5.
3. If not, do they have a web host with PHP 8+ and HTTPS? If yes, go to Step 4. If no, explain the options in `README.md` → "How it works" and help them pick one.

## Step 4. PHP backend
1. Generate a token: `openssl rand -hex 24`.
2. Make `backend/php/config.php` from `config.example.php`. Ask for the Dexcom username, password, and region (`us`, `ous`, `jp`). Let the user type the password into the file themselves if they prefer. `config.php` is gitignored.
3. Tell the user to upload `glucose.php`, `.htaccess`, and `config.php` to a folder on their host. If you have file access to their host (SFTP, cPanel API), you may do it with their permission.
4. Test it:
   ```bash
   curl -s -H "Authorization: Bearer $TOKEN" "$URL"
   ```
   Success is `"available":true`. Use `docs/TROUBLESHOOTING.md` for anything else.

## Step 5. config.env
```bash
cp config.env.example config.env
```
Fill in `DEVELOPMENT_TEAM`, `BUNDLE_ID_PREFIX` (suggest `com.<their-name>.glucosewidget`, lowercase, no spaces), `GLUCOSE_ENDPOINT`, and `GLUCOSE_API_TOKEN`.

## Step 6. Build and install
```bash
./install.sh
```
On success it prints "✅ Widget registered". Then tell the user: right-click the desktop → Edit Widgets → search "Glucose" → drag in the small or medium size.

Optional test run:
```bash
xcodebuild test -project GlucoseWidget.xcodeproj -scheme GlucoseWidget -destination 'platform=macOS' -allowProvisioningUpdates
```

## Rules that cost people hours
- **Keep the App Sandbox on** for both targets. macOS silently refuses to load an unsandboxed third-party widget. No error, it just never appears.
- **Keep `com.apple.security.network.client`** in the extension entitlements, or every fetch fails.
- **Don't build unsigned or ad-hoc.** The widget won't register. Always pass `-allowProvisioningUpdates` so expired certificates renew.
- **`Widget/Info.plist` needs the standard `CFBundle*` keys.** Don't strip them.
- Verify with `pluginkit -m -i "$BUNDLE_ID_PREFIX.GlucoseWidgetExtension"`.

## Customizing
- Color thresholds: `Widget/GlucoseRange.swift`. Update `Tests/GlucoseLogicTests.swift` to match.
- Colors and layout: `Widget/GlucoseView.swift`.
- Refresh timing: `Widget/GlucoseProvider.swift`. macOS throttles widgets, so faster than ~2 minutes won't help.
- Re-run `./install.sh` after any change.

## Safety
This isn't a medical device. If the user asks you to add alarms or treatment advice, remind them to rely on the official Dexcom app for alerts.
