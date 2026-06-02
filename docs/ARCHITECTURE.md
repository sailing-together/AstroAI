# AstroAI Architecture Source of Truth

> Status: Canonical technical architecture for redevelopment.
> Last updated: 2026-06-02

## System Shape

```text
Next.js Web
Existing Flutter Mobile
        |
        v
FastAPI /api/v1
        |
        +--> Supabase Auth
        +--> Supabase PostgreSQL
        +--> Redis / Upstash
        +--> pyswisseph chart engine
        +--> Gemini API
        +--> Stripe
        +--> Firebase Cloud Messaging
```

The web MVP is the primary redevelopment target. The existing Flutter mobile app remains temporarily, but mobile rewrite work is outside MVP.

## Stack

| Layer | Decision |
|---|---|
| Web frontend | Next.js 14 App Router, TypeScript, Tailwind CSS |
| Mobile | Existing Flutter app temporarily |
| Backend | FastAPI, Python 3.11+ |
| Database | Supabase PostgreSQL |
| Auth | Supabase Auth |
| Cache and rate limit | Redis or Upstash Redis |
| Background jobs | Simple scheduled jobs first; Celery + Redis when reliability requires it |
| AI provider | Gemini only |
| Primary AI model | Gemini 2.5 Flash |
| Low-cost AI model | Gemini 2.5 Flash-Lite |
| Ephemeris | pyswisseph |
| Payments | Stripe |
| Notifications | Firebase Cloud Messaging |

## Architectural Principles

1. Calculate astrology deterministically; use AI only for interpretation and synthesis.
2. Generate static public content ahead of time; do not spend live AI calls on anonymous page views.
3. Persist user-specific context before using it in AI prompts.
4. Keep Gemini access behind the backend.
5. Use one canonical API contract between frontend and backend.
6. Use `free` and `premium` as the only tier names.

## AI Routing

| Workload | Model | Execution |
|---|---|---|
| AI Astrologer chat | Gemini 2.5 Flash | Live, user-triggered |
| Natal chart interpretation | Gemini 2.5 Flash | Generated once per chart hash |
| Personalized daily guidance | Gemini 2.5 Flash | On demand or scheduled per user |
| Compatibility synthesis | Gemini 2.5 Flash | Generated once per sign pair or synastry request |
| Tarot fusion | Gemini 2.5 Flash | On demand |
| Mood/transit insight | Gemini 2.5 Flash | Weekly batch |
| Daily horoscope copy | Gemini 2.5 Flash-Lite | Scheduled static generation |
| Sign profile copy | Gemini 2.5 Flash-Lite | Scheduled static generation |
| Notification copy | Gemini 2.5 Flash-Lite | Scheduled or event-triggered |
| Memory extraction | Gemini 2.5 Flash-Lite | Background task |

Do not use Gemini 2.0 Flash. Do not implement Claude/Sonnet in MVP.

## Static First, AI Last

| Content | Source of truth | Cache |
|---|---|---|
| Daily horoscopes | `static_horoscopes` | Redis |
| Weekly horoscopes | `static_horoscopes` | Redis |
| Monthly horoscopes | `static_horoscopes` | Redis |
| Sign profiles | `static_sign_profiles` | Redis |
| Sign-pair compatibility | `static_compatibility` | Redis |
| Cosmic events | `static_cosmic_events` | Redis |
| Tarot card meanings | `static_tarot_cards` | Redis |
| Natal charts | `natal_charts` | Optional Redis by `chart_hash` |
| AI memories | `ai_memories` | PostgreSQL/pgvector |

Redis is never the durable source of truth.

## Backend Modules

Expected backend module boundaries:

| Module | Responsibility |
|---|---|
| `core.config` | Environment configuration |
| `core.auth` | Supabase JWT verification |
| `core.rate_limit` | Redis quota enforcement |
| `database` | SQLAlchemy models, session, migrations |
| `api.v1` | Route handlers |
| `schemas` | Pydantic request/response DTOs |
| `services.chart_engine` | pyswisseph natal chart calculation |
| `services.gemini_client` | Gemini API wrapper |
| `services.context_builder` | AI Astrologer context assembly |
| `services.memory` | Memory extraction and retrieval |
| `tasks` | Scheduled static content and background jobs |

## Runtime Configuration

Backend environment variables:

```env
ENVIRONMENT=development
BACKEND_CORS_ORIGINS=http://localhost:3000

SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
SUPABASE_JWT_SECRET=

DATABASE_URL=
REDIS_URL=

GEMINI_API_KEY=
GEMINI_PRIMARY_MODEL=gemini-2.5-flash
GEMINI_LIGHT_MODEL=gemini-2.5-flash-lite
GEMINI_TIMEOUT_SECONDS=30
GEMINI_MAX_RETRIES=3

AI_CHAT_FREE_DAILY_LIMIT=3
AI_CHAT_PREMIUM_DAILY_LIMIT=50

STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PREMIUM_PRICE_ID=

GOOGLE_PLACES_API_KEY=
FCM_SERVER_KEY=
```

Frontend environment variables:

```env
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api/v1
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

Never expose Gemini, Stripe secret, Supabase service role, Google Places server key, or FCM server key to browser code.

## Rate Limits

| Feature | Free | Premium |
|---|---:|---:|
| AI Astrologer messages | 3/day | 50/day |
| Tarot fusion readings | 1/day | 10/day |
| Natal chart regeneration | 3/month | 10/month |
| Static page views | Unlimited | Unlimited |

Premium is not unlimited for AI calls in MVP.

## Security Requirements

- Rotate any exposed Gemini key before production use.
- Keep `.env` and `.env.local` out of source control.
- Enable Supabase Row Level Security on user-owned data.
- Verify Supabase JWTs in FastAPI for protected endpoints.
- Use Stripe webhook signature verification.
- Enforce Redis rate limits before live Gemini calls.
- Store birth data and memories only behind authenticated access.
- Avoid logging birth details, user messages, payment secrets, or API keys.

