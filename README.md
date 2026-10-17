# Mac Glucose Widget (beta)

> **Beta. Provided as is, with no support or warranty.** It works on the author's Mac. The PHP backend is new and lightly tested. Expect rough edges, and please open an issue if something breaks.

A native macOS desktop and Notification Center widget that shows a live Dexcom CGM reading: the number, the trend arrow, and how old the reading is. The background turns green, yellow, red, or gray so you can read it at a glance from across the room.

Built for parents and caregivers who follow someone's blood sugar and spend the day at a Mac.

> **Not a medical device.** This is a hobby project. Readings can be late, wrong, or missing. Never use it to make treatment decisions. Always confirm with the CGM receiver or the official Dexcom app. Not affiliated with or endorsed by Dexcom, Inc.

## How it works

```
Dexcom CGM → Dexcom app on the wearer's phone → Dexcom Share (cloud)
          → your backend (small server you run) → this widget on your Mac
```

The widget never talks to Dexcom directly. It calls one URL on **your own backend**, which returns the latest reading as JSON. You choose the backend:

- **Easiest:** upload the included PHP script ([`backend/php/`](backend/php/)) to any basic web host with PHP 8 and HTTPS (a typical cPanel host works).
- **Your own:** any server that returns the JSON in [`docs/API.md`](docs/API.md). A Raspberry Pi, a NAS, a cloud function, or an existing Nightscout setup with a small adapter all work.

## What you need

### On your Mac
- macOS 14 Sonoma or newer
- Xcode (free from the App Store), opened once so it finishes setup
- [Homebrew](https://brew.sh) and XcodeGen: `brew install xcodegen`
- A free Apple ID signed in to Xcode → Settings → Accounts. No paid developer account needed.

### For the data
- A Dexcom G6, G7, or ONE+ with the Dexcom app on the wearer's phone
- **Dexcom Share turned on**, with at least one follower invited (Share stays off until someone follows)
- The wearer's Dexcom username and password (the backend logs in as them)

### A backend
- A web host with PHP 8+, cURL, and HTTPS, **or** your own server that follows [`docs/API.md`](docs/API.md)

## Set it up with an AI coding tool (recommended)

Open this folder in Claude Code, Cursor, Codex, or a similar tool and say:

> Set up this glucose widget for me.

The tool reads [`AGENTS.md`](AGENTS.md), asks you a few questions, and does the rest. You'll still need to sign in to Xcode yourself (Apple requires your password and 2FA) and put the backend on your host.

## Set it up by hand

1. **Backend.** Follow [`backend/php/README.md`](backend/php/README.md). Confirm the `curl` test returns `"available":true`.
2. **Config.** `cp config.env.example config.env` and fill in your team ID, a bundle ID prefix, the backend URL, and the token.
3. **Build and install.** `./install.sh`
4. **Add the widget.** Right-click the desktop → Edit Widgets → search "Glucose". Pick small or medium.

Re-run `./install.sh` whenever you change `config.env` or the code.

## Colors

| Color | Default rule (mg/dL) |
|---|---|
| Red | below 55 or above 250 |
| Yellow | 55–69 or 181–250 |
| Green | 70–180 |
| Gray | no reading, or older than 20 minutes |

Change the thresholds in [`Widget/GlucoseRange.swift`](Widget/GlucoseRange.swift) and the tests in `Tests/` to match your care plan.

## Refresh rate

macOS decides when widgets refresh. The widget asks for a new reading about every 2 minutes, and Dexcom posts one about every 5. Expect the display to lag a few minutes at times. The "X min ago" line always tells you how fresh it is.

## Troubleshooting

See [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

## License

MIT. See [`LICENSE`](LICENSE).
