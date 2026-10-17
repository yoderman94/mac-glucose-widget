<?php
// Copy this file to config.php and fill it in. Never commit config.php.
return [
    // The Dexcom account that SHARES the data (the one on the CGM user's phone),
    // not a follower account. Dexcom Share must be on, with at least one follower.
    'dexcom_username' => 'your-dexcom-username',
    'dexcom_password' => 'your-dexcom-password',

    // 'us' for the United States, 'ous' for outside the US, 'jp' for Japan.
    'region' => 'us',

    // Shared secret. Put the same value in GLUCOSE_API_TOKEN in config.env.
    // Make one with: openssl rand -hex 24
    'api_token' => 'change-me',

    // Seconds to reuse the last reading before asking Dexcom again.
    'cache_seconds' => 60,

    // Minutes after which a reading counts as stale (widget turns gray).
    'stale_minutes' => 20,
];
