<?php
/**
 * Reference backend for the Mac glucose widget.
 *
 * Logs in to Dexcom Share as a follower-enabled account and returns the latest
 * reading in the JSON shape described in docs/API.md. Runs on any web host
 * with PHP 8+ and the cURL extension. No database needed.
 *
 * Setup: copy config.example.php to config.php and fill it in.
 */

declare(strict_types=1);

header('Content-Type: application/json');
header('Cache-Control: no-store');

$configFile = __DIR__ . '/config.php';
if (!is_file($configFile)) {
    respond(500, unavailable('Server not configured: config.php is missing.'));
}
$config = require $configFile;

// --- Auth -------------------------------------------------------------------

$token = (string)($config['api_token'] ?? '');
if ($token !== '' && !hash_equals('Bearer ' . $token, requestAuthorization())) {
    respond(401, unavailable('Unauthorized.'));
}

// --- Short cache so many widget refreshes don't hammer Dexcom ---------------

$cacheDir = __DIR__ . '/cache';
if (!is_dir($cacheDir)) {
    @mkdir($cacheDir, 0700, true);
}
$readingCache = $cacheDir . '/reading.json';
$cacheSeconds = (int)($config['cache_seconds'] ?? 60);
if (is_file($readingCache) && time() - filemtime($readingCache) < $cacheSeconds) {
    $cached = json_decode((string)file_get_contents($readingCache), true);
    if (is_array($cached) && isset($cached['epoch'])) {
        respond(200, buildPayload($cached, (int)($config['stale_minutes'] ?? 20)));
    }
}

// --- Dexcom Share -------------------------------------------------------------

$regions = [
    'us'  => ['https://share2.dexcom.com/ShareWebServices/Services',    'd89443d2-327c-4a6f-89e5-496bbb0317db'],
    'ous' => ['https://shareous1.dexcom.com/ShareWebServices/Services', 'd89443d2-327c-4a6f-89e5-496bbb0317db'],
    'jp'  => ['https://share.dexcom.jp/ShareWebServices/Services',      'd8665ade-9673-4e27-9ff6-92db4ce13d13'],
];
$region = strtolower((string)($config['region'] ?? 'us'));
if (!isset($regions[$region])) {
    respond(500, unavailable('Bad region in config.php. Use us, ous, or jp.'));
}
[$base, $appId] = $regions[$region];

$sessionFile = $cacheDir . '/session.txt';
$sessionId = is_file($sessionFile) ? trim((string)file_get_contents($sessionFile)) : '';

try {
    if ($sessionId === '') {
        $sessionId = login($base, $appId, $config);
        @file_put_contents($sessionFile, $sessionId, LOCK_EX);
    }
    [$status, $body] = latestReading($base, $sessionId);
    if ($status !== 200) {
        // Sessions expire. Log in again once and retry.
        $sessionId = login($base, $appId, $config);
        @file_put_contents($sessionFile, $sessionId, LOCK_EX);
        [$status, $body] = latestReading($base, $sessionId);
    }
    if ($status !== 200) {
        throw new RuntimeException("Dexcom returned HTTP $status.");
    }
} catch (Throwable $e) {
    respond(502, unavailable('Could not reach Dexcom Share: ' . $e->getMessage()));
}

$rows = json_decode($body, true);
if (!is_array($rows) || count($rows) === 0) {
    respond(200, unavailable('No readings in the last 24 hours.'));
}
$row = $rows[0];
if (!preg_match('/Date\((\d+)/', (string)($row['WT'] ?? ''), $m)) {
    respond(502, unavailable('Unexpected reading format from Dexcom.'));
}
$reading = [
    'epoch' => intdiv((int)$m[1], 1000),
    'value' => (int)$row['Value'],
    'trend' => trendNumber($row['Trend'] ?? 0),
];
@file_put_contents($readingCache, json_encode($reading), LOCK_EX);
respond(200, buildPayload($reading, (int)($config['stale_minutes'] ?? 20)));

// --- Helpers ------------------------------------------------------------------

function respond(int $status, array $payload): never
{
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function unavailable(string $message): array
{
    return ['available' => false, 'message' => $message];
}

/** Some hosts (CGI/FastCGI) strip the Authorization header. Check every place it can land. */
function requestAuthorization(): string
{
    foreach (['HTTP_AUTHORIZATION', 'REDIRECT_HTTP_AUTHORIZATION'] as $key) {
        if (!empty($_SERVER[$key])) {
            return (string)$_SERVER[$key];
        }
    }
    if (function_exists('getallheaders')) {
        foreach (getallheaders() as $name => $value) {
            if (strcasecmp($name, 'Authorization') === 0) {
                return (string)$value;
            }
        }
    }
    return '';
}

/** @return array{0:int,1:string} HTTP status and body */
function post(string $url, ?array $json = null): array
{
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST           => true,
        CURLOPT_POSTFIELDS     => $json === null ? '' : json_encode($json),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT        => 10,
        CURLOPT_HTTPHEADER     => [
            'Content-Type: application/json',
            'Accept: application/json',
            'User-Agent: Dexcom Share/3.0.2.11',
        ],
    ]);
    $body = curl_exec($ch);
    if ($body === false) {
        $err = curl_error($ch);
        throw new RuntimeException($err);
    }
    $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
    return [$status, (string)$body];
}

function login(string $base, string $appId, array $config): string
{
    $password = (string)($config['dexcom_password'] ?? '');
    [$status, $body] = post("$base/General/AuthenticatePublisherAccount", [
        'accountName'   => (string)($config['dexcom_username'] ?? ''),
        'password'      => $password,
        'applicationId' => $appId,
    ]);
    $accountId = json_decode($body, true);
    if ($status !== 200 || !is_string($accountId)) {
        throw new RuntimeException('login failed. Check username, password, and region.');
    }
    [$status, $body] = post("$base/General/LoginPublisherAccountById", [
        'accountId'     => $accountId,
        'password'      => $password,
        'applicationId' => $appId,
    ]);
    $sessionId = json_decode($body, true);
    if ($status !== 200 || !is_string($sessionId) || $sessionId === '00000000-0000-0000-0000-000000000000') {
        throw new RuntimeException('login failed. Check username, password, and region.');
    }
    return $sessionId;
}

/** @return array{0:int,1:string} */
function latestReading(string $base, string $sessionId): array
{
    $q = http_build_query(['sessionId' => $sessionId, 'minutes' => 1440, 'maxCount' => 1]);
    return post("$base/Publisher/ReadPublisherLatestGlucoseValues?$q");
}

/** Dexcom returns the trend as a name (newer) or a number (older). Normalize to 0–9. */
function trendNumber(mixed $trend): int
{
    if (is_numeric($trend)) {
        return (int)$trend;
    }
    $names = ['None', 'DoubleUp', 'SingleUp', 'FortyFiveUp', 'Flat',
              'FortyFiveDown', 'SingleDown', 'DoubleDown', 'NotComputable', 'RateOutOfRange'];
    $i = array_search((string)$trend, $names, true);
    return $i === false ? 0 : $i;
}

function buildPayload(array $reading, int $staleMinutes): array
{
    $directions   = ['None', 'DoubleUp', 'SingleUp', 'FortyFiveUp', 'Flat',
                     'FortyFiveDown', 'SingleDown', 'DoubleDown', 'NotComputable', 'RateOutOfRange'];
    $descriptions = ['', 'rising quickly', 'rising', 'rising slightly', 'steady',
                     'falling slightly', 'falling', 'falling quickly', 'unable to determine trend', 'trend unavailable'];
    $arrows       = ['', '↑↑', '↑', '↗', '→', '↘', '↓', '↓↓', '?', '-'];

    $t = max(0, min(9, $reading['trend']));
    $minutesAgo = max(0, intdiv(time() - $reading['epoch'], 60));

    return [
        'available'         => true,
        'value'             => $reading['value'],
        'mmol_l'            => round($reading['value'] / 18.0, 1),
        'trend'             => $t,
        'trend_direction'   => $directions[$t],
        'trend_description' => $descriptions[$t],
        'trend_arrow'       => $arrows[$t],
        'minutes_ago'       => $minutesAgo,
        'stale'             => $minutesAgo > $staleMinutes,
        'reading_time'      => gmdate('c', $reading['epoch']),
    ];
}
