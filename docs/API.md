# Backend API contract

The widget makes one request:

```
GET <GLUCOSE_ENDPOINT>
Authorization: Bearer <GLUCOSE_API_TOKEN>     (only sent if a token is set)
```

It expects HTTP 2xx and a JSON body. Any other status, a timeout (10 s), or bad JSON shows "unreachable" on the widget.

## Reading available

```json
{
  "available": true,
  "value": 128,
  "mmol_l": 7.1,
  "trend": 4,
  "trend_direction": "Flat",
  "trend_description": "steady",
  "trend_arrow": "→",
  "minutes_ago": 3,
  "stale": false,
  "reading_time": "2026-01-01T12:00:00+00:00"
}
```

## No reading

```json
{ "available": false, "message": "No readings in the last 24 hours." }
```

## Fields

| Field | Type | Used by the widget | Notes |
|---|---|---|---|
| `available` | bool | yes | `false` shows "—" |
| `value` | int | yes | mg/dL |
| `mmol_l` | number | no | `value / 18`, one decimal |
| `trend` | int 0–9 | yes | see table below |
| `trend_direction` | string | no | Dexcom name |
| `trend_description` | string | yes (medium) | shown capitalized |
| `trend_arrow` | string | fallback | shown when `trend` has no arrow |
| `minutes_ago` | int | yes | age of the reading |
| `stale` | bool | yes | `true` turns the widget gray and dim |
| `reading_time` | ISO 8601 string | no | |
| `message` | string | no | for humans |

Every field except `available` may be missing or `null`.

## Trend values

| `trend` | Dexcom name | Arrow |
|---|---|---|
| 0 | None | |
| 1 | DoubleUp | ↑↑ |
| 2 | SingleUp | ↑ |
| 3 | FortyFiveUp | ↗ |
| 4 | Flat | → |
| 5 | FortyFiveDown | ↘ |
| 6 | SingleDown | ↓ |
| 7 | DoubleDown | ↓↓ |
| 8 | NotComputable | ? |
| 9 | RateOutOfRange | - |

These match the Python library [pydexcom](https://github.com/gagebenne/pydexcom), so a pydexcom-based server (Flask, FastAPI) can return `reading.trend` directly.
