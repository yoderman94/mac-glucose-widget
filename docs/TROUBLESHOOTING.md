# Troubleshooting

### The widget doesn't show up in Edit Widgets
- macOS silently ignores third-party widgets that aren't sandboxed. Both `App/GlucoseWidget.entitlements` and `Widget/GlucoseWidgetExtension.entitlements` must keep `com.apple.security.app-sandbox`. Don't remove it.
- The app must be signed with a real team. Unsigned or ad-hoc builds never register.
- Check registration: `pluginkit -m -i <BUNDLE_ID_PREFIX>.GlucoseWidgetExtension`. No output means not registered.
- Open `/Applications/GlucoseWidget.app` once, wait a few seconds, then try Edit Widgets again. A log out and log in also helps.

### Signing errors during `./install.sh`
- "No Account for Team" or "No signing certificate": sign in to Xcode → Settings → Accounts with your Apple ID, then re-run.
- An expired certificate renews itself because the script passes `-allowProvisioningUpdates`.
- "Bundle identifier is not available": pick a more unique `BUNDLE_ID_PREFIX` in `config.env`.
- To see the full error, re-run the `xcodebuild` line from `install.sh` without `>/dev/null`.

### The widget says "unreachable"
- Run the `curl` test from `backend/php/README.md` on the same Mac.
- 401 means the token in `config.env` doesn't match `api_token` on the server.
- Some hosts strip the `Authorization` header. The included `.htaccess` fixes this on Apache. On other servers, pass the header through to PHP.
- The extension needs `com.apple.security.network.client` in its entitlements to make any network call.

### The reading is gray or "STALE"
- The wearer's phone hasn't uploaded in over 20 minutes. Check that the Dexcom app is running, has internet, and that Share is on.
- Dexcom Share only uploads while at least one follower is active.

### The backend says login failed
- Use the wearer's Dexcom account (the sharer), not the follower's account.
- Set `region` to `ous` outside the United States, or `jp` in Japan.
- Some accounts log in with an email or phone number. Try the form the Dexcom app accepts.
