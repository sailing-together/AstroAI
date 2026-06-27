# AstroAI Architecture Source of Truth

> Status: Canonical technical architecture for redevelopment.
> Last updated: 2026-06-27

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
7. Treat the registered product as conversation-first: modules provide context, while the AI Astrologer is the primary interaction.
8. Treat AI spend as a production safety boundary: public acquisition traffic must remain near-zero marginal cost, and total MVP variable AI/cloud spend must stay below 100 AUD unless founders explicitly raise the cap.

## Access and AI Boundaries

| Capability | Auth | Gemini at request time | Notes |
|---|---|---|---|
| Choose sign and read horoscope bundle | No | No | Reads PostgreSQL/Redis static content |
| Enter birth date and calculate Sun sign | No | No | Deterministic date-range calculation |
| Calculate natal chart | Yes | No | Deterministic `pyswisseph` calculation |
| Save natal chart | Yes | No | Stores chart in PostgreSQL |
| AI natal chart interpretation | Yes | Yes | Separate from chart calculation |
| Personalized predictions | Yes | Yes | Uses chart, transits, and user context |
| AI Astrologer chat | Yes | Yes | Rate-limited |

Live Gemini calls must also pass the FinOps gates in `FINOPS.md`: AI enabled, authenticated user, quota available, rate limit passed, usage meter writable, and spend below the configured cap.

## Conversation-First Context Pipeline

The registered AI Astrologer should not rely on frontend-built prompts or force users to choose an astrology module before asking a question. The backend should assemble the relevant context and compose the Gemini prompt server-side.

Request-time pipeline:

1. Verify Supabase JWT and load the application user.
2. Enforce AI quota before live Gemini calls.
3. Load saved natal chart and profile context.
4. Load current static horoscope or timing context when relevant.
5. Load recent conversation history and approved memory summaries when available.
6. Compose a server-side prompt with clear boundaries for unavailable context.
7. Persist the exchange and safe context signals for future continuity.

The first implementation can use simple deterministic context assembly. Memory extraction, retrieval ranking, and multi-agent synthesis can be added after the registered chart and AI Astrologer loop is stable.

## AI Routing

| Workload | Model | Execution |
|---|---|---|
| AI Astrologer chat | Gemini 2.5 Flash | Live, user-triggered |
| Natal chart interpretation | Gemini 2.5 Flash | Generated once per chart hash |
| Personalized daily guidance | Gemini 2.5 Flash | On demand or scheduled per user |
| Compatibility synthesis | Gemini 2.5 Flash | Generated once per sign pair or synastry request |
| Tarot fusion | Gemini 2.5 Flash | On demand |
| Mood/transit insight | Gemini 2.5 Flash | Weekly batch |
| Yearly horoscope copy | Gemini 2.5 Flash-Lite | Scheduled static generation once per year |
| Monthly horoscope copy | Gemini 2.5 Flash-Lite | Scheduled static generation once per month |
| Weekly horoscope copy | Gemini 2.5 Flash-Lite | Scheduled static generation once per week |
| Daily horoscope copy | Gemini 2.5 Flash-Lite | Scheduled static generation daily at 00:00 |
| Sign profile copy | Gemini 2.5 Flash-Lite | Scheduled static generation |
| Notification copy | Gemini 2.5 Flash-Lite | Scheduled or event-triggered |
| Memory extraction | Gemini 2.5 Flash-Lite | Background task |

Do not use Gemini 2.0 Flash. Do not implement Claude/Sonnet in MVP.

## Static First, AI Last

| Content | Source of truth | Cache |
|---|---|---|
| Yearly horoscopes | `static_horoscopes` | Redis |
| Monthly horoscopes | `static_horoscopes` | Redis |
| Weekly horoscopes | `static_horoscopes` | Redis |
| Daily horoscopes | `static_horoscopes` | Redis |
| Sign profiles | `static_sign_profiles` | Redis |
| Sign-pair compatibility | `static_compatibility` | Redis |
| Cosmic events | `static_cosmic_events` | Redis |
| Tarot card meanings | `static_tarot_cards` | Redis |
| Natal charts | `natal_charts` | Optional Redis by `chart_hash` |
| AI memories | `ai_memories` | PostgreSQL/pgvector |

Redis is never the durable source of truth.

Public horoscope pages must never call Gemini during user requests. Scheduled or manual generation jobs generate horoscope content ahead of time, store it in PostgreSQL, and refresh Redis. Each job should make one Gemini 2.5 Flash-Lite call per sign and period, returning all supported dimensions in a single structured response.

The public web app should support a one-request bundle read for a sign and year. That bundle returns yearly, 12 monthly, all weekly, and all daily horoscope records for the selected sign. It is a read-only static-content API and must not call Gemini.

Public horoscope dimensions:

- `general`
- `love`
- `career`
- `money`
- `wellness`
- `social`
- `family`
- `study`
- `mood_energy`

Static horoscope refresh cadence:

| Period | Cadence |
|---|---|
| Yearly | Once per year, or during manual annual regeneration |
| Monthly | Once per month, or preloaded for all 12 months during annual generation |
| Weekly | Once per week, or preloaded for all weeks during annual generation |
| Daily | Every day at 00:00, or preloaded for all dates during annual generation |

Annual bulk generation mode:

1. Operator starts generation for a target year.
2. Backend generates horoscope content for all 12 signs.
3. For each sign, backend creates yearly, 12 monthly, all weekly, and all daily records for the target year.
4. Generated content is upserted into PostgreSQL and optionally warmed into Redis.
5. Periodic daily/weekly/monthly jobs still run as補缺/refresh jobs if a row is missing, stale, or intentionally regenerated.

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

AI_CALLS_ENABLED=false
PUBLIC_AI_CALLS_ENABLED=false
STATIC_GENERATION_AI_ENABLED=false
AI_SPEND_LIMIT_AUD=100
AI_KILL_SWITCH_ON_LIMIT=true

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

## AI Usage Meter and Spend Guardrails

The backend must record every Gemini call with enough detail to attribute cost by user, tier, feature, model, status, and date. This includes live AI calls and operator-triggered static generation jobs.

Minimum usage-meter fields:

- `user_id`
- `feature`
- `tier`
- `model`
- `input_tokens`
- `output_tokens`
- `estimated_cost_aud`
- `estimated_cost_usd`
- `request_status`
- `created_at`

If estimated total MVP AI/cloud spend reaches `AI_SPEND_LIMIT_AUD`, the backend should disable live AI and batch AI generation while keeping deterministic chart calculation and static content reads online.

Anonymous/public routes must not call Gemini even if `AI_CALLS_ENABLED=true`. `PUBLIC_AI_CALLS_ENABLED` exists as a hard guardrail and should remain `false` for MVP.

## Security Requirements

- Rotate any exposed Gemini key before production use.
- Keep `.env` and `.env.local` out of source control.
- Enable Supabase Row Level Security on user-owned data.
- Verify Supabase JWTs in FastAPI for protected endpoints.
- Use Stripe webhook signature verification.
- Enforce Redis rate limits before live Gemini calls.
- Store birth data and memories only behind authenticated access.
- Avoid logging birth details, user messages, payment secrets, or API keys.
