# AstroAI API Specification Source of Truth

> Status: Canonical API contract for redevelopment.
> Last updated: 2026-06-02

## Base URL

All custom backend routes are under:

```text
/api/v1
```

The frontend must use these routes exactly. Legacy paths such as `/natal_chart`, `/natal-chart/calculate`, `/natal-chart/me`, `/natal-chart/save`, and query-style `/compatibility?signA=...` are not canonical.

## Authentication

Supabase handles sign-up, sign-in, OAuth, and password reset on the client.

Protected FastAPI endpoints require:

```http
Authorization: Bearer <supabase_jwt>
```

The backend verifies the Supabase JWT and maps it to the application `users` row.

## Shared Conventions

Dates use ISO 8601. Timestamps are UTC ISO 8601 strings. IDs are UUID strings. Zodiac signs are lowercase path parameters and title-case response values.

Canonical tier values:

```ts
type UserTier = "free" | "premium";
```

Standard error response:

```json
{
  "error": {
    "code": "rate_limit_exceeded",
    "message": "Daily AI message limit reached.",
    "details": {}
  }
}
```

## Routes

### Health

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/health` | No | Service health check |

### User

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/users/me` | Yes | Get current profile |
| `PATCH` | `/users/me` | Yes | Update current profile |

`GET /users/me` response:

```json
{
  "id": "uuid",
  "email": "user@example.com",
  "display_name": "Ava",
  "tier": "free",
  "created_at": "2026-06-02T00:00:00Z",
  "updated_at": "2026-06-02T00:00:00Z"
}
```

### Natal Chart

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/users/me/natal-chart` | Yes | Get saved natal chart, or `null` |
| `POST` | `/users/me/natal-chart` | Yes | Calculate and persist natal chart |
| `DELETE` | `/users/me/natal-chart` | Yes | Delete saved natal chart |

`POST /users/me/natal-chart` request:

```json
{
  "birth_date": "1994-06-14",
  "birth_time": "08:30",
  "unknown_time": false,
  "birth_place_name": "Sydney, Australia",
  "birth_lat": -33.8688,
  "birth_lng": 151.2093,
  "timezone": "Australia/Sydney"
}
```

Natal chart response:

```json
{
  "id": "uuid",
  "sun_sign": "Gemini",
  "moon_sign": "Pisces",
  "ascendant_sign": "Leo",
  "unknown_time": false,
  "planets": [],
  "houses": [],
  "aspects": [],
  "interpretation": {
    "summary": "A concise chart interpretation.",
    "strengths": [],
    "growth_edges": []
  },
  "created_at": "2026-06-02T00:00:00Z",
  "updated_at": "2026-06-02T00:00:00Z"
}
```

When `unknown_time` is `true`, `moon_sign`, `ascendant_sign`, and houses may be `null` or omitted where calculation confidence is insufficient.

### Horoscope

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/horoscope/daily/{sign}` | No | Daily horoscope |
| `GET` | `/horoscope/weekly/{sign}` | No | Weekly horoscope |
| `GET` | `/horoscope/monthly/{sign}` | No | Monthly horoscope |

Supported query parameters:

| Parameter | Applies to | Notes |
|---|---|---|
| `date` | daily | ISO date, defaults to today |
| `focus` | daily/weekly/monthly | `general`, `love`, `career`, `wellness`, `money`, `social` |

Horoscope response:

```json
{
  "sign": "Gemini",
  "period": "daily",
  "date": "2026-06-02",
  "focus": "general",
  "title": "A focused title",
  "summary": "Short scannable summary.",
  "body": "Full horoscope copy.",
  "lucky_numbers": [3, 14, 22],
  "lucky_color": "Yellow",
  "generated_at": "2026-06-02T00:00:00Z"
}
```

### AI Astrologer

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/chat` | Yes | Send an AI Astrologer message |
| `GET` | `/chat/conversations` | Yes | List user's conversations |
| `GET` | `/chat/conversations/{conversation_id}` | Yes | Get conversation messages |

`POST /chat` request:

```json
{
  "message": "What should I focus on this week?",
  "conversation_id": "uuid-or-null"
}
```

`POST /chat` response:

```json
{
  "conversation_id": "uuid",
  "message_id": "uuid",
  "reply": "Chart-aware AI Astrologer response.",
  "model": "gemini-2.5-flash",
  "usage": {
    "tier": "free",
    "used_today": 1,
    "daily_limit": 3
  },
  "created_at": "2026-06-02T00:00:00Z"
}
```

Rate limit failures must happen before the Gemini call.

### Compatibility

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/compatibility/{sign_a}/{sign_b}` | No | Static sign-pair compatibility |

Compatibility response:

```json
{
  "sign_a": "Gemini",
  "sign_b": "Sagittarius",
  "score": 82,
  "summary": "High-level compatibility summary.",
  "strengths": [],
  "frictions": [],
  "advice": []
}
```

### Tarot

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/tarot/draw` | Yes | Draw a tarot card and generate an astrology fusion reading |

`POST /tarot/draw` request:

```json
{
  "spread": "single_card",
  "question": "What energy should I pay attention to?"
}
```

### Mood

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/moods` | Yes | List mood logs |
| `POST` | `/moods` | Yes | Create mood log |

`POST /moods` request:

```json
{
  "mood_score": 7,
  "energy_score": 5,
  "notes": "Restless but optimistic.",
  "logged_at": "2026-06-02T08:00:00Z"
}
```

### Subscription

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/subscription` | Yes | Get subscription status |
| `POST` | `/subscription/checkout` | Yes | Create Stripe checkout session |
| `POST` | `/subscription/portal` | Yes | Create Stripe customer portal session |
| `POST` | `/webhooks/stripe` | No | Stripe webhook endpoint |

Subscription response:

```json
{
  "tier": "premium",
  "status": "active",
  "current_period_end": "2026-07-02T00:00:00Z"
}
```

## Live AI Rules

Only `/chat`, `/tarot/draw`, natal interpretation generation, and explicit personalized insight jobs may make live Gemini calls.

Public horoscope, sign profile, compatibility, cosmic event, and tarot card pages must use persisted static content.

## API Implementation Order

1. Health.
2. User profile.
3. Natal chart.
4. AI Astrologer.
5. Static horoscope.
6. Compatibility.
7. Mood.
8. Tarot.
9. Subscription.

