# PHP reference backend

One PHP file that logs in to Dexcom Share and returns the JSON in [`docs/API.md`](../../docs/API.md).

## What you need
- A web host with PHP 8.0+ and the cURL extension (most cPanel hosts have both).
- HTTPS on the domain. Your token and glucose data travel over it.
- The Dexcom username and password of the person who wears the CGM.
  Dexcom Share must be on in their Dexcom app, with at least one follower.

## Install
1. Upload `glucose.php`, `.htaccess`, and `config.example.php` to a folder, for example `public_html/glucose/`.
2. Copy `config.example.php` to `config.php` on the server. Fill it in.
3. Make a token: `openssl rand -hex 24`. Put it in `config.php` as `api_token`.
4. Test it from your Mac:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" https://example.com/glucose/glucose.php
   ```
   You should see `"available":true` and a `value`.
5. Put the URL and token in `config.env` on your Mac, then run `./install.sh`.

## Notes
- The script writes a `cache/` folder next to itself. It holds the Dexcom session ID and the last reading. The folder must be writable by PHP.
- On Nginx hosts, `.htaccess` does nothing. Block `/config.php` and `/cache/` in your server config instead.
- Test locally with `php -S localhost:8080` in this folder, then open `http://localhost:8080/glucose.php`.
