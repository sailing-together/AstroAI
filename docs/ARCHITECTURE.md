# 🏗️ AstroAI – Technical Architecture

> **Last updated:** June 2026

---

## Stack Overview

| Layer | Technology | Rationale |
|---|---|---|
| Web Frontend | Next.js 14 (App Router) + Tailwind CSS | SSR for SEO, React ecosystem, share-card generation |
| Mobile | React Native (Expo) | Share logic with web via shared API layer |
| Backend API | FastAPI (Python) | Async, fast, great DX, keep from current impl |
| Database | PostgreSQL via Supabase | Replaces SQLite; gives auth + realtime in one |
| Auth | Supabase Auth | Magic link + Google OAuth; unblocks all personalization |
| Cache | Redis (Upstash serverless) | Pre-generated content + session cache |
| Job Queue | Celery + Redis | Replaces fragile APScheduler self-call pattern |
| AI — Bulk Content | Gemini Flash (batched, pre-generated) | Cost-optimized daily content generation |
| AI — Assistant | Claude Sonnet (on-demand, user-triggered) | Deep natal chart analysis, AI Astrologer Q&A |
| Ephemeris | `pyswisseph` — local, no API call | Swiss Ephemeris, zero cost, replaces flatlib |
| Payments | Stripe Billing | Subscriptions + one-time bundles |
| Notifications | Firebase Cloud Messaging | Free tier covers early scale |
| File Storage | Cloudflare R2 | ASMR audio, share-card images, media assets |

---

## Core Cost Principle — Static First, AI Last

> **凡是能静态生成的数据，全部后台预生成并持久化存储。只有静态数据无法满足的高度个性化、需要实时互动的场景，才调用 AI API。**
>
> Pre-generate and persist everything that doesn't require individual user context. Reserve AI API calls exclusively for interactions that are personalized, real-time, and cannot be served from stored data.

### Data Classification

| Data Type | Varies By | Strategy | Storage | AI Call? |
|---|---|---|---|---|
| Daily horoscope | Sign + Date | Batch nightly | PostgreSQL + Redis | Once/day per sign |
| Cosmic events | Date only | Batch nightly | PostgreSQL + Redis | Once/day |
| Yearly horoscope | Sign + Year | Batch annually | PostgreSQL | Once/year per sign |
| Zodiac sign profiles | Sign only | Generate once | PostgreSQL | Once ever, refresh quarterly |
| Tarot card meanings | Card (78 cards) | Generate once | PostgreSQL | Once ever |
| Compatibility overview | Sign pair (144 combos) | Generate once | PostgreSQL | Once ever, refresh quarterly |
| Planetary event descriptions | Event type | Generate once | PostgreSQL | Once per event type |
| Lucky numbers / energy colors | Sign + Date | Batch nightly | PostgreSQL + Redis | Once/day per sign |
| Share card text | Sign + Date | Re-use horoscope text | — | No extra call |
| **Natal chart interpretation** | **User's birth data** | **Generate once per user, store** | **PostgreSQL** | **Once per user (on signup)** |
| **Compatibility (synastry)** | **Two natal charts** | **Generate once per pair, store** | **PostgreSQL** | **Once per pair** |
| **AI Astrologer Q&A** | **User + natal + memory + now** | **On-demand only** | **Store conversation** | **Yes — user-triggered** |
| **Memory synthesis** | **User's personal history** | **Weekly batch per user** | **PostgreSQL** | **Weekly per active user** |
| **Mood correlation insight** | **User's mood logs + transits** | **Weekly batch per user** | **PostgreSQL** | **Weekly per active user** |
| **Tarot + Astrology Fusion** | **User + drawn card + transits** | **On-demand** | **Store reading** | **Yes — user-triggered** |

**Bold rows = dynamic. Everything else = static, pre-generated, zero real-time AI cost.**

---

## Cost Architecture — Minimize Real-Time API Calls

### 1. Batch Pre-Generation (Daily Cron Jobs)

The majority of content in AstroAI is *predictable* — it's the same for all users of the same sign on the same day. Generate it once, cache it, serve from cache.

```
Daily batch job (runs at 00:00 UTC via Celery Beat):

  horoscopes:
    - 12 signs × 6 focus areas (Love, Career, Wealth, Wellness, Guidance, Motivation)
    - = 72 Gemini calls/day total, regardless of user count
    - Cached in Redis: key = horoscope:{sign}:{focus}:{date}, TTL = 24h

  cosmic_events:
    - 1 call/day for "today's planetary highlights"
    - Cached: cosmic_events:{date}, TTL = 24h

  zodiac_sign_content:
    - 12 calls/week (sign archetypes, year overview) — rarely changes
    - Cached: sign_content:{sign}:{week}, TTL = 7d

  tarot_daily:
    - Pre-generate 78-card interpretations once, store in DB
    - No daily API call needed — draw is random, interpretation is static text
```

### 2. On-Demand AI Calls (User-Triggered Only)

These are the only calls made in real-time, because they require individual user context:

| Feature | Model | Trigger |
|---|---|---|
| AI Astrologer Q&A | Claude Sonnet | User sends a message |
| Natal Chart Deep Analysis | Claude Sonnet | User requests full chart reading (once/chart) |
| Tarot + Astrology Fusion | Gemini Flash | User draws a card (fused reading) |
| Compatibility Report | Gemini Flash | User requests a compatibility check |
| Mood Insight (weekly) | Gemini Flash | Weekly digest generation, not per-log |

**Rate limiting:** Free tier users are capped at 3 AI Astrologer messages/day. This limits per-user AI cost and creates upgrade motivation.

### 3. Ephemeris — Zero Cost, Local

Replace any external planetary API with `pyswisseph` (Python bindings to Swiss Ephemeris). It runs locally, has no call limit, no cost, and is the industry standard for astrological calculations.

```python
import swisseph as swe

# Get planetary positions — pure local computation, no network call
swe.set_ephe_path('/path/to/ephe')
jd = swe.julday(2026, 6, 1, 12.0)
sun_pos = swe.calc_ut(jd, swe.SUN)
```

Replaces: flatlib (unmaintained), any third-party ephemeris API.

### 4. AI Model Routing Strategy

Not every AI call needs an expensive model. Route by complexity:

```
Gemini 2.0 Flash (fast, cheap):
  - Daily horoscope batch generation
  - Compatibility score + summary
  - Tarot card fusion reading
  - Lucky numbers, energy colors
  - Short notification copy

Claude Sonnet (deep reasoning):
  - AI Astrologer conversation (full natal chart context)
  - Natal chart deep-dive interpretation
  - Memory-layer insight synthesis
  - Mood correlation analysis
```

### 5. Caching Strategy

```
Redis key schema:
  horoscope:{sign}:{focus}:{YYYY-MM-DD}          TTL: 24h
  cosmic_events:{YYYY-MM-DD}                      TTL: 24h
  natal_chart_reading:{user_id}:{chart_hash}      TTL: 30d (re-generate if chart changes)
  compatibility:{sign_a}:{sign_b}:{type}          TTL: 7d
  sign_content:{sign}                             TTL: 7d

Never cache:
  AI Astrologer responses (personalized, context-sensitive)
  Mood correlation insights (depend on user's personal data)
```

### 6. Estimated AI Cost at Scale

| User Count | Daily AI Calls | Estimated Daily Cost |
|---|---|---|
| 1,000 DAU | ~72 batch + ~300 on-demand | ~$0.50–$1.00/day |
| 10,000 DAU | ~72 batch + ~3,000 on-demand | ~$3–$6/day |
| 100,000 DAU | ~72 batch + ~30,000 on-demand | ~$25–$50/day |

Batch pre-generation keeps costs nearly flat regardless of user count. On-demand costs scale linearly but are gated by free-tier limits.

---

## System Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│                   CLIENTS                        │
│   Next.js Web (SSR)    React Native (Expo)       │
└─────────────────┬───────────────────────────────┘
                  │ HTTPS
┌─────────────────▼───────────────────────────────┐
│              FastAPI Backend                     │
│                                                  │
│  /api/horoscope    → Redis cache hit             │
│  /api/natal        → Supabase DB                 │
│  /api/chat         → Claude Sonnet (on-demand)   │
│  /api/compatibility→ Redis cache / Gemini Flash  │
│  /api/events       → Redis cache hit             │
│  /api/tarot        → DB draw + optional Gemini   │
└──┬───────────────────────────┬───────────────────┘
   │                           │
┌──▼──────────┐    ┌───────────▼──────────────────┐
│  Supabase   │    │       Redis (Upstash)         │
│  PostgreSQL │    │  - Pre-generated content      │
│  + Auth     │    │  - Session data               │
│  + Realtime │    │  - Rate limiting              │
└─────────────┘    └───────────────────────────────┘
   │
┌──▼──────────────────────────────────────────────┐
│            Celery + Redis (Job Queue)            │
│                                                  │
│  celery_beat schedule:                           │
│    - 00:00 UTC: generate_daily_horoscopes()      │
│    - 00:05 UTC: generate_cosmic_events()         │
│    - 06:00 UTC: dispatch_morning_notifications() │
│    - Weekly: refresh_sign_content()              │
└──┬──────────────────────────────────────────────┘
   │
┌──▼──────────────────────────────────────────────┐
│               AI Layer                          │
│                                                  │
│  Gemini Flash  ←── bulk/batch content           │
│  Claude Sonnet ←── user-triggered deep AI       │
│  pyswisseph    ←── ephemeris (local, free)      │
└─────────────────────────────────────────────────┘
```

---

## Data Models

### User
```python
class User:
    id: UUID
    email: str
    created_at: datetime
    subscription_tier: Literal["free", "premium"]
    subscription_expires_at: Optional[datetime]
    stripe_customer_id: Optional[str]
```

### NatalChart
```python
class NatalChart:
    id: UUID
    user_id: UUID  # FK → User
    birth_date: date
    birth_time: Optional[time]   # None if unknown
    birth_place: str
    latitude: float
    longitude: float
    timezone: str
    # Computed & stored (not re-calculated every request)
    sun_sign: str
    moon_sign: str
    ascendant: Optional[str]
    planets: dict   # {planet: {sign, degree, house}}
    chart_hash: str  # hash of inputs, used for cache invalidation
    created_at: datetime
```

### AIMemory
```python
class AIMemory:
    id: UUID
    user_id: UUID
    entry_type: Literal["event", "feeling", "decision", "outcome"]
    content: str           # what the user told the AI
    date: date             # when this happened (user-reported)
    planetary_context: dict  # transits active at that time
    created_at: datetime
    embedding: Optional[vector]  # for semantic search (pgvector)
```

### MoodLog
```python
class MoodLog:
    id: UUID
    user_id: UUID
    logged_at: datetime
    mood_score: int        # 1–5
    energy_score: int      # 1–5
    note: Optional[str]
    planetary_snapshot: dict  # current transit positions at log time
```

### TarotDraw
```python
class TarotDraw:
    id: UUID
    user_id: UUID
    drawn_at: datetime
    spread_type: Literal["daily", "three_card", "celtic_cross", "oracle"]
    cards: list[dict]      # [{card_name, position, reversed}]
    question: Optional[str]
    ai_interpretation: str
    natal_context_used: bool
    transit_context_used: bool
```

---

## Prompt Architecture

All prompts are versioned in `backend/prompts/` with Pydantic response schemas. No free-form string prompts.

```
backend/
  prompts/
    horoscope_v1.py       # daily horoscope by sign + focus area
    horoscope_v2.py       # personalized variant (natal chart context)
    natal_chart_v1.py     # full chart interpretation
    compatibility_v1.py   # compatibility report
    tarot_fusion_v1.py    # tarot + astrology fusion reading
    assistant_system.py   # AI Astrologer system prompt
    memory_synthesis_v1.py # surfacing patterns from AIMemory
```

Each prompt file defines:
- The prompt template
- The expected Pydantic response schema
- Model routing (Flash vs Sonnet)
- Cache TTL

All Gemini and Claude calls use **structured JSON output mode** — no free-form text parsing.

---

## Migration Plan from Current Stack

### Phase 0 — Critical Fixes (Do Now)
1. **Rotate Gemini API key** — currently hardcoded in source, must be rotated and moved to `.env`
2. **Fix N+1 calls** — horoscope endpoint makes 6 sequential calls; collapse to 1 structured JSON call
3. **Add `.env.example`** — document all required environment variables

### Phase 1 — Foundation
1. Add Supabase (PostgreSQL + Auth) — replace SQLite
2. Build User + NatalChart data models and CRUD
3. Add Redis (Upstash) — wire up horoscope cache
4. Migrate APScheduler → Celery + Redis Beat
5. Replace flatlib with pyswisseph

### Phase 2 — Frontend Migration
1. Scaffold Next.js app with App Router + Tailwind
2. Migrate Flutter web pages to Next.js components (one page at a time)
3. Add SSR for sign/compatibility/event pages (SEO)
4. Build share-card generation (OG image API route)
5. Keep Flutter for iOS — migrate to React Native in Phase 3

### Phase 3 — AI Layer
1. Implement prompt registry (version all prompts)
2. Wire Celery Beat daily batch jobs (pre-generate 72 horoscopes/day)
3. Add Claude Sonnet for AI Astrologer endpoint
4. Implement AIMemory model + retrieval
5. Add pgvector for semantic memory search

---

## Environment Variables

```env
# Supabase
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_KEY=

# AI APIs
GEMINI_API_KEY=
ANTHROPIC_API_KEY=

# Redis
REDIS_URL=

# Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=

# Firebase (notifications)
FIREBASE_SERVICE_ACCOUNT_JSON=

# Ephemeris
SWISSEPH_PATH=./ephe

# App
CORS_ORIGINS=http://localhost:3000,https://astroai.app
SECRET_KEY=
```

---

## Security Checklist
- [ ] All secrets via environment variables (never in source code)
- [ ] API key rotation on every developer change
- [ ] Rate limiting on all AI endpoints (Redis token bucket)
- [ ] Supabase Row Level Security (RLS) on user data tables
- [ ] GDPR/CCPA: minimal data collection, deletion endpoint, privacy flow in onboarding
- [ ] Encryption at rest for natal chart + AIMemory data
- [ ] Input validation on all AI prompts (prevent prompt injection)
