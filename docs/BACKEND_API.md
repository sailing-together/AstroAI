# AstroAI Backend API Specification

**Version:** 2.0  
**Framework:** FastAPI (Python 3.11)  
**Queue:** Celery 5 + Redis (Upstash)  
**Cache:** Redis (Upstash)  
**Auth:** Supabase Auth (JWT)  
**DB:** PostgreSQL (Supabase) + SQLite (legacy, to be migrated)  
**AI Provider:** Google Gemini 1.5 Flash  

---

## Table of Contents

1. [Project Structure](#1-project-structure)
2. [Environment Configuration](#2-environment-configuration)
3. [Authentication](#3-authentication)
4. [API Route Reference](#4-api-route-reference)
   - [Auth](#41-auth-endpoints)
   - [User Profile & Natal Chart](#42-user-profile--natal-chart)
   - [Horoscope](#43-horoscope-endpoints)
   - [Cosmic Events](#44-cosmic-events)
   - [AI Astrologer Chat](#45-ai-astrologer-chat)
   - [Tarot](#46-tarot-endpoints)
   - [Compatibility](#47-compatibility-endpoints)
   - [Mood Logging](#48-mood-logging)
   - [Notifications](#49-notification-preferences)
   - [Subscription & Stripe](#410-subscription--stripe)
   - [Admin / Internal](#411-admin--internal-endpoints)
5. [Celery Beat Schedule](#5-celery-beat-schedule)
6. [Batch Horoscope Generation](#6-batch-horoscope-generation-job)
7. [Cache Strategy](#7-cache-strategy)
8. [AI Call Management](#8-ai-call-management)
9. [Error Handling](#9-error-handling)
10. [Migration Notes (APScheduler → Celery)](#10-migration-notes)

---

## 1. Project Structure

```
backend/
├── main.py                        # FastAPI app factory, lifespan, middleware
├── celery_app.py                  # Celery application instance + Beat schedule
├── requirements.txt
│
├── core/
│   ├── config.py                  # Pydantic Settings — all env vars
│   ├── auth.py                    # Supabase JWT dependency (get_current_user)
│   ├── rate_limit.py              # Per-user AI call rate limiter (Redis)
│   ├── cache.py                   # Redis client + cache-aside helpers
│   └── exceptions.py              # Custom HTTP exceptions
│
├── api/
│   └── v1/
│       ├── __init__.py            # Aggregates all v1 routers
│       ├── auth.py                # Custom auth endpoints (refresh, verify)
│       ├── users.py               # Profile CRUD, natal chart save/fetch
│       ├── horoscope.py           # Daily / weekly / monthly / personalized
│       ├── cosmic_events.py       # Events today, upcoming, by type
│       ├── chat.py                # AI Astrologer — POST /chat
│       ├── tarot.py               # Draw, spreads, journal
│       ├── compatibility.py       # Sign-based + user compatibility
│       ├── mood.py                # Mood logging
│       ├── notifications.py       # Notification prefs
│       ├── subscriptions.py       # Subscription status, Stripe webhook
│       └── admin.py               # Internal / admin endpoints
│
├── services/
│   ├── gemini_client.py           # Centralised Gemini API wrapper
│   ├── horoscope_prompt_builder.py
│   ├── compatibility_prompt_builder.py
│   ├── review_event_prompt_builder.py
│   ├── with_celebrity_prompt_builder.py
│   ├── chat_prompt_builder.py     # NEW: AI Astrologer conversation builder
│   ├── tarot_prompt_builder.py    # NEW
│   ├── date_to_sign.py
│   ├── city_to_timezone.py
│   └── simplified_natal_chart_calculation.py
│
├── tasks/                         # Celery tasks (one file per domain)
│   ├── horoscope_tasks.py         # Nightly batch horoscope generation
│   ├── cosmic_event_tasks.py      # DB update + cache warm
│   ├── tarot_tasks.py             # Nightly card-of-the-day generation
│   └── maintenance_tasks.py       # Clear past events, prune logs
│
├── models/                        # Pydantic request/response schemas
│   ├── user.py
│   ├── horoscope.py
│   ├── chat.py
│   ├── tarot.py
│   ├── compatibility.py
│   ├── cosmic_event.py
│   ├── mood.py
│   └── subscription.py
│
└── database/
    ├── config.py                  # SQLAlchemy engine + SessionLocal (Postgres)
    ├── models.py                  # ORM models
    └── crud.py                    # DB helper functions
```

---

## 2. Environment Configuration

### `core/config.py`

```python
from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    # ── App ─────────────────────────────────────────────────────────────────
    APP_ENV: str = "development"          # development | staging | production
    APP_SECRET_KEY: str
    ALLOWED_ORIGINS: list[str] = ["*"]

    # ── Supabase ─────────────────────────────────────────────────────────────
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_SERVICE_ROLE_KEY: str        # server-side admin operations only
    SUPABASE_JWT_SECRET: str              # used to verify JWT locally

    # ── Database (PostgreSQL via Supabase) ───────────────────────────────────
    DATABASE_URL: str                     # postgresql+asyncpg://...

    # ── Redis / Upstash ──────────────────────────────────────────────────────
    REDIS_URL: str                        # rediss://:<token>@<host>:6380
    REDIS_TTL_DEFAULT: int = 3600         # 1 hour fallback TTL

    # ── Celery ───────────────────────────────────────────────────────────────
    CELERY_BROKER_URL: str                # same REDIS_URL
    CELERY_RESULT_BACKEND: str            # same REDIS_URL

    # ── Google Gemini ────────────────────────────────────────────────────────
    GEMINI_API_KEY: str
    GEMINI_MODEL: str = "gemini-1.5-flash"
    GEMINI_MAX_RETRIES: int = 3
    GEMINI_RETRY_DELAY_SECONDS: float = 1.5

    # ── Rate limiting ────────────────────────────────────────────────────────
    AI_CHAT_FREE_DAILY_LIMIT: int = 3     # free tier: 3 AI messages per day
    AI_CHAT_PRO_DAILY_LIMIT: int = 50     # pro tier

    # ── Stripe ───────────────────────────────────────────────────────────────
    STRIPE_SECRET_KEY: str
    STRIPE_WEBHOOK_SECRET: str
    STRIPE_PRO_PRICE_ID: str

    # ── Nightly batch schedule (UTC) ─────────────────────────────────────────
    BATCH_HOROSCOPE_HOUR: int = 1         # 01:00 UTC = before most users wake
    BATCH_HOROSCOPE_MINUTE: int = 0
    BATCH_EVENTS_HOUR: int = 0            # midnight UTC
    BATCH_EVENTS_MINUTE: int = 30


@lru_cache()
def get_settings() -> Settings:
    return Settings()
```

### Required `.env` keys

```
APP_ENV=production
APP_SECRET_KEY=<random-64-char-hex>

SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
SUPABASE_JWT_SECRET=<jwt-secret>

DATABASE_URL=postgresql+asyncpg://<user>:<pass>@<host>:5432/<db>

REDIS_URL=rediss://:<upstash-token>@<upstash-host>:6380

CELERY_BROKER_URL=${REDIS_URL}
CELERY_RESULT_BACKEND=${REDIS_URL}

GEMINI_API_KEY=<your-gemini-key>

STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRO_PRICE_ID=price_...
```

---

## 3. Authentication

All protected endpoints require `Authorization: Bearer <supabase_jwt>` in the request header. The dependency `get_current_user` decodes and validates the JWT locally using `SUPABASE_JWT_SECRET` — no round trip to Supabase on every request.

### `core/auth.py`

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
import jwt
from core.config import get_settings

settings = get_settings()
bearer_scheme = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> dict:
    token = credentials.credentials
    try:
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            options={"verify_aud": False},
        )
        return payload          # contains sub (user_id), email, role, etc.
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


async def require_pro(user: dict = Depends(get_current_user)) -> dict:
    """Dependency that additionally checks for an active pro subscription."""
    if user.get("app_metadata", {}).get("subscription_tier") != "pro":
        raise HTTPException(status_code=403, detail="Pro subscription required")
    return user
```

---

## 4. API Route Reference

All routes are mounted under `/api/v1`. The `main.py` includes the aggregate router:

```python
# main.py (excerpt)
from api.v1 import router as v1_router
app.include_router(v1_router, prefix="/api/v1")
```

Route table legend:
- **Auth**: `public` | `user` (JWT required) | `admin` (service-role + internal IP)
- **Data source**: `cache` → Redis first, DB fallback | `db` → DB only | `ai` → triggers live Gemini call

---

### 4.1 Auth Endpoints

> Supabase handles sign-up, sign-in, OAuth, and password reset directly from the client. These custom endpoints handle server-side concerns only.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/auth/verify` | public | Verify a JWT is still valid; returns decoded claims |
| `POST` | `/auth/refresh` | public | Proxy Supabase token refresh (server keeps `refresh_token` out of client storage) |
| `DELETE` | `/auth/account` | user | Delete account — purges user data from Supabase + PostgreSQL |

---

### 4.2 User Profile & Natal Chart

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/users/me` | user | Fetch own profile |
| `PUT` | `/users/me` | user | Update display name, avatar, timezone |
| `GET` | `/users/me/natal-chart` | user | Fetch saved natal chart; `null` if not yet calculated |
| `POST` | `/users/me/natal-chart` | user | Calculate + persist natal chart (replaces legacy `POST /natal_chart`) |
| `DELETE` | `/users/me/natal-chart` | user | Clear saved natal chart |

#### `POST /users/me/natal-chart`

```
Request body:
{
  "birth_date": "1995-06-15",       // YYYY-MM-DD
  "birth_time": "14:30",             // HH:MM, 24h; null = unknown
  "birth_location": "Sydney, Australia"
}

Response 201:
{
  "sun_sign": "Gemini",
  "moon_sign": "Scorpio",
  "rising_sign": "Sagittarius",
  "ascendant_degree": 243.72,
  "planets": [
    { "name": "Sun", "sign": "Gemini", "degree": 24.1, "house": 7 },
    ...
  ],
  "houses": [
    { "house_number": 1, "start_degree": 243.72, "sign": "Sagittarius" },
    ...
  ],
  "birth_timezone": "+10:00",
  "birth_latitude": "-33.8688",
  "birth_longitude": "151.2093",
  "calculated_at": "2026-06-01T01:00:00Z"
}
```

**Implementation note:** Calculation is CPU-bound (flatlib + swisseph). Run it synchronously in a thread pool via `asyncio.run_in_executor` to avoid blocking the event loop. Store result in `user_natal_charts` table and cache under `natal:{user_id}` (TTL: forever / until updated).

---

### 4.3 Horoscope Endpoints

Static horoscopes are pre-generated nightly. Personalized horoscopes are served from cache keyed on `{sign}:{focus}:{date}`. If a user has a natal chart, a richer personalized version is served from their own cache key.

| Method | Path | Auth | Data Source | Description |
|--------|------|------|-------------|-------------|
| `GET` | `/horoscope/daily` | user | cache → db | Today's horoscope for user's sun sign across all 6 focus areas |
| `GET` | `/horoscope/daily/{sign}` | public | cache → db | Today's horoscope for a given sign (unauthenticated preview) |
| `GET` | `/horoscope/weekly` | user | cache → db | This week's horoscope (generated Sunday night) |
| `GET` | `/horoscope/weekly/{sign}` | public | cache → db | Weekly for a given sign |
| `GET` | `/horoscope/monthly` | user | cache → db | This month's horoscope |
| `GET` | `/horoscope/monthly/{sign}` | public | cache → db | Monthly for a given sign |
| `GET` | `/horoscope/personalized` | user | cache → ai (fallback) | Enhanced horoscope using full natal chart; served from cache if batch pre-generated |

#### Response schema (all horoscope endpoints)

```python
# models/horoscope.py
from pydantic import BaseModel
from datetime import date

class HoroscopeResponse(BaseModel):
    sign: str
    period: str                          # "daily" | "weekly" | "monthly"
    date: date
    overall: str
    love: str
    career: str
    wealth: str
    daily_suggestion: str
    encouragement: str
    lucky_number: int | None = None
    lucky_color: str | None = None
    cached: bool                         # True if served from Redis
    generated_at: str                    # ISO-8601 UTC timestamp
```

#### Route implementation example

```python
# api/v1/horoscope.py
from fastapi import APIRouter, Depends, Query
from core.auth import get_current_user
from core.cache import get_cache, set_cache
from database.crud import get_horoscope_from_db
from models.horoscope import HoroscopeResponse
from services.date_to_sign import date_to_zodiac
from datetime import date

router = APIRouter(prefix="/horoscope", tags=["horoscope"])


@router.get("/daily", response_model=HoroscopeResponse)
async def get_daily_horoscope(user: dict = Depends(get_current_user)):
    sign = user.get("app_metadata", {}).get("sun_sign")
    if not sign:
        raise HTTPException(status_code=400, detail="Sun sign not set. Save natal chart first.")
    return await _fetch_horoscope(sign, "daily", date.today())


@router.get("/daily/{sign}", response_model=HoroscopeResponse)
async def get_daily_horoscope_by_sign(sign: str):
    sign = sign.capitalize()
    _validate_sign(sign)
    return await _fetch_horoscope(sign, "daily", date.today())


async def _fetch_horoscope(sign: str, period: str, for_date: date) -> HoroscopeResponse:
    cache_key = f"horoscope:{period}:{sign}:{for_date.isoformat()}"
    cached = await get_cache(cache_key)
    if cached:
        return HoroscopeResponse(**cached, cached=True)

    # Cache miss: pull from DB (batch job should have populated this)
    row = await get_horoscope_from_db(sign=sign, period=period, for_date=for_date)
    if row:
        data = row.to_dict()
        await set_cache(cache_key, data, ttl=_ttl_for_period(period))
        return HoroscopeResponse(**data, cached=False)

    # DB miss: should not happen in production if batch ran successfully.
    # Raise 503 rather than making a live AI call in this path — keep costs
    # deterministic. On-demand AI is reserved for /chat.
    raise HTTPException(
        status_code=503,
        detail="Horoscope not yet available. The nightly generation job may still be running."
    )


def _ttl_for_period(period: str) -> int:
    return {"daily": 86400, "weekly": 604800, "monthly": 2592000}[period]


VALID_SIGNS = {
    "Aries","Taurus","Gemini","Cancer","Leo","Virgo",
    "Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"
}

def _validate_sign(sign: str):
    if sign not in VALID_SIGNS:
        raise HTTPException(status_code=422, detail=f"Unknown zodiac sign: {sign}")
```

---

### 4.4 Cosmic Events

| Method | Path | Auth | Data Source | Description |
|--------|------|------|-------------|-------------|
| `GET` | `/events/today` | public | cache → db | Today's lunar events, retrogrades, ingresses |
| `GET` | `/events/upcoming` | public | cache → db | Next 30 days of events |
| `GET` | `/events/retrogrades` | public | cache → db | Active and upcoming planetary retrogrades |
| `GET` | `/events/lunar` | public | cache → db | Upcoming lunar events (new/full moons, eclipses) |

#### Response schema

```python
# models/cosmic_event.py
from pydantic import BaseModel
from typing import Literal

class LunarEventOut(BaseModel):
    id: int
    event: str
    start: str
    end: str | None
    duration_days: float | None

class RetrogradeOut(BaseModel):
    id: int
    planet: str
    start: str
    end: str | None
    duration_days: float | None
    is_active: bool

class IngressOut(BaseModel):
    id: int
    planet: str
    time: str
    sign: str
    sign_number: int

class EventsTodayResponse(BaseModel):
    date: str
    lunar_events: list[LunarEventOut]
    retrogrades: list[RetrogradeOut]
    ingresses: list[IngressOut]
    cached: bool
```

---

### 4.5 AI Astrologer Chat

This is the **only endpoint that makes a live Gemini API call at request time**. All other AI content is pre-generated by Celery Beat jobs.

| Method | Path | Auth | Data Source | Description |
|--------|------|------|-------------|-------------|
| `POST` | `/chat` | user | ai (live) | Send a message to the AI Astrologer; returns AI response |
| `GET` | `/chat/history` | user | db | Paginated chat history for current user |
| `DELETE` | `/chat/history` | user | db | Clear chat history |
| `GET` | `/chat/usage` | user | cache | Current day's AI call count vs. limit |

#### `POST /chat` — Request / Response

```python
# models/chat.py
from pydantic import BaseModel, Field
from typing import Literal

class ChatMessage(BaseModel):
    role: Literal["user", "assistant"]
    content: str

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=1000)
    # Last N turns for context (client sends recent history; server validates length)
    context_messages: list[ChatMessage] = Field(default=[], max_length=10)

class ChatResponse(BaseModel):
    reply: str
    messages_used_today: int
    messages_remaining_today: int
    limit_per_day: int
    conversation_id: str
```

#### Route implementation

```python
# api/v1/chat.py
from fastapi import APIRouter, Depends, HTTPException
from core.auth import get_current_user
from core.rate_limit import check_and_increment_ai_usage
from services.gemini_client import generate_chat_response
from services.chat_prompt_builder import build_chat_system_prompt
from database.crud import save_chat_message, get_user_natal_chart
from models.chat import ChatRequest, ChatResponse
import uuid

router = APIRouter(prefix="/chat", tags=["chat"])


@router.post("", response_model=ChatResponse)
async def ai_astrologer_chat(
    body: ChatRequest,
    user: dict = Depends(get_current_user),
):
    user_id = user["sub"]
    tier = user.get("app_metadata", {}).get("subscription_tier", "free")

    # 1. Rate limit check (raises 429 if exceeded)
    usage = await check_and_increment_ai_usage(user_id, tier)

    # 2. Fetch natal chart for richer context (optional — silently skip if absent)
    natal_chart = await get_user_natal_chart(user_id)

    # 3. Build system prompt
    system_prompt = build_chat_system_prompt(natal_chart)

    # 4. Call Gemini (with retry + timeout)
    reply = await generate_chat_response(
        system_prompt=system_prompt,
        history=body.context_messages,
        user_message=body.message,
    )

    # 5. Persist to conversation history
    conversation_id = str(uuid.uuid4())
    await save_chat_message(user_id, body.message, reply, conversation_id)

    return ChatResponse(
        reply=reply,
        messages_used_today=usage.used,
        messages_remaining_today=usage.remaining,
        limit_per_day=usage.limit,
        conversation_id=conversation_id,
    )
```

---

### 4.6 Tarot Endpoints

| Method | Path | Auth | Data Source | Description |
|--------|------|------|-------------|-------------|
| `GET` | `/tarot/card-of-the-day` | user | cache → db | Pre-generated daily tarot card + interpretation for user's sign |
| `POST` | `/tarot/draw` | user | ai (live) | Draw N cards; AI interprets the spread in context of user's question |
| `GET` | `/tarot/spreads` | public | static | Available spread layouts (3-card, Celtic Cross, etc.) |
| `POST` | `/tarot/journal` | user | db | Save a personal tarot journal entry |
| `GET` | `/tarot/journal` | user | db | Paginated journal entries |
| `DELETE` | `/tarot/journal/{entry_id}` | user | db | Delete a journal entry |

#### `POST /tarot/draw` — Request / Response

```python
# models/tarot.py
from pydantic import BaseModel, Field
from typing import Literal

class TarotDrawRequest(BaseModel):
    question: str = Field(..., max_length=500)
    spread: Literal["single", "three_card", "celtic_cross"] = "three_card"

class DrawnCard(BaseModel):
    position: str          # e.g., "Past", "Present", "Future"
    card_name: str         # e.g., "The High Priestess"
    card_number: int       # 0–77
    is_reversed: bool
    meaning: str           # position-specific interpretation

class TarotDrawResponse(BaseModel):
    question: str
    spread: str
    cards: list[DrawnCard]
    overall_message: str
    messages_used_today: int
    messages_remaining_today: int
```

**Note:** `POST /tarot/draw` counts against the same daily AI usage quota as `/chat`. Both endpoints share the rate limiter.

---

### 4.7 Compatibility Endpoints

| Method | Path | Auth | Data Source | Description |
|--------|------|------|-------------|-------------|
| `GET` | `/compatibility/{sign1}/{sign2}` | public | cache → db | Pre-generated compatibility report for two signs |
| `POST` | `/compatibility/personal` | user | cache → ai (fallback) | Personalized compatibility using full natal charts |

#### Response schema

```python
# models/compatibility.py
from pydantic import BaseModel

class CompatibilityResponse(BaseModel):
    sign_1: str
    sign_2: str
    romantic_score: int          # 1–10
    friendship_score: int
    work_score: int
    overall_score: int
    summary: str
    romantic_detail: str
    friendship_detail: str
    work_detail: str
    challenges: str
    cached: bool
```

**Cache key:** `compatibility:{sign1_lower}:{sign2_lower}` — sign order is normalized (alphabetical) so `aries:taurus` and `taurus:aries` resolve to the same key.

The 144 unique sign-pair combinations (12×12, minus duplicate reverses = 78) are pre-generated by the nightly batch job.

---

### 4.8 Mood Logging

| Method | Path | Auth | Data Source | Description |
|--------|------|------|-------------|-------------|
| `POST` | `/mood` | user | db | Log today's mood entry |
| `GET` | `/mood` | user | db | Paginated mood history |
| `GET` | `/mood/insights` | user | cache → db | Monthly mood patterns correlated with cosmic events |

```python
# models/mood.py
from pydantic import BaseModel, Field
from typing import Literal
from datetime import date

class MoodLogRequest(BaseModel):
    mood: Literal["great", "good", "neutral", "low", "bad"]
    energy_level: int = Field(..., ge=1, le=5)
    notes: str | None = Field(None, max_length=500)
    logged_date: date | None = None     # defaults to today server-side

class MoodLogResponse(BaseModel):
    id: str
    mood: str
    energy_level: int
    notes: str | None
    logged_date: str
    cosmic_context: str | None         # e.g., "Mercury retrograde active"
```

---

### 4.9 Notification Preferences

| Method | Path | Auth | Data Source | Description |
|--------|------|------|-------------|-------------|
| `GET` | `/notifications/preferences` | user | db | Fetch current notification prefs |
| `PUT` | `/notifications/preferences` | user | db | Update prefs |
| `POST` | `/notifications/device-token` | user | db | Register push notification device token |
| `DELETE` | `/notifications/device-token/{token}` | user | db | Unregister device |

```python
# models/notification.py
from pydantic import BaseModel

class NotificationPreferences(BaseModel):
    daily_horoscope: bool = True
    cosmic_events: bool = True
    full_moon_alert: bool = True
    retrograde_alert: bool = True
    push_enabled: bool = True
    email_enabled: bool = False
    preferred_hour_utc: int = 8          # 0–23, hour to deliver daily horoscope push
```

---

### 4.10 Subscription & Stripe

| Method | Path | Auth | Data Source | Description |
|--------|------|------|-------------|-------------|
| `GET` | `/subscriptions/status` | user | db | Current subscription tier + expiry |
| `POST` | `/subscriptions/checkout` | user | stripe | Create Stripe Checkout Session; returns `checkout_url` |
| `POST` | `/subscriptions/portal` | user | stripe | Create Stripe Customer Portal session; returns `portal_url` |
| `POST` | `/subscriptions/webhook` | public* | stripe | Stripe webhook handler (signature-verified) |

*The webhook endpoint is public but must pass Stripe signature verification.

#### Webhook handler (critical path)

```python
# api/v1/subscriptions.py (webhook excerpt)
import stripe
from fastapi import Request, HTTPException
from core.config import get_settings

settings = get_settings()

@router.post("/webhook", include_in_schema=False)
async def stripe_webhook(request: Request):
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except stripe.error.SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid Stripe signature")

    if event["type"] == "checkout.session.completed":
        await _handle_checkout_completed(event["data"]["object"])
    elif event["type"] == "customer.subscription.deleted":
        await _handle_subscription_cancelled(event["data"]["object"])
    elif event["type"] == "invoice.payment_failed":
        await _handle_payment_failed(event["data"]["object"])

    return {"status": "ok"}
```

---

### 4.11 Admin / Internal Endpoints

All admin endpoints require `Authorization: Bearer <SUPABASE_SERVICE_ROLE_KEY>` **plus** validation that the request originates from an internal IP or CI runner. Add a `require_admin` dependency that checks both.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/admin/events/refresh` | admin | Trigger full cosmic event DB refresh (replaces `POST /update-database/`) |
| `POST` | `/admin/events/purge-past` | admin | Delete past events from DB (replaces `POST /admin/clear-past-events/`) |
| `POST` | `/admin/horoscope/generate` | admin | Manually trigger nightly horoscope batch (useful for backfilling) |
| `POST` | `/admin/cache/flush` | admin | Flush a specific Redis key pattern |
| `GET` | `/admin/tasks/status` | admin | List recent Celery task results + statuses |
| `GET` | `/admin/stats` | admin | App metrics: active users, AI calls today, cache hit rate |

---

## 5. Celery Beat Schedule

### `celery_app.py`

```python
from celery import Celery
from celery.schedules import crontab
from core.config import get_settings

settings = get_settings()

celery_app = Celery(
    "astroai",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=[
        "tasks.horoscope_tasks",
        "tasks.cosmic_event_tasks",
        "tasks.tarot_tasks",
        "tasks.maintenance_tasks",
    ],
)

celery_app.conf.update(
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_acks_late=True,                   # only ack after task completes
    worker_prefetch_multiplier=1,          # one task at a time per worker
    task_default_retry_delay=60,           # 60s before retry
    task_max_retries=3,
    result_expires=86400,                  # keep results for 1 day
)

celery_app.conf.beat_schedule = {

    # ── Nightly batch: generate all daily horoscopes ───────────────────────
    # 01:00 UTC — runs before most global timezones start their day
    "nightly-daily-horoscopes": {
        "task": "tasks.horoscope_tasks.generate_daily_horoscopes",
        "schedule": crontab(hour=1, minute=0),
        "options": {"queue": "batch"},
    },

    # ── Sunday 01:30 UTC — weekly horoscopes ──────────────────────────────
    "weekly-horoscopes": {
        "task": "tasks.horoscope_tasks.generate_weekly_horoscopes",
        "schedule": crontab(hour=1, minute=30, day_of_week="sunday"),
        "options": {"queue": "batch"},
    },

    # ── 1st of month, 02:00 UTC — monthly horoscopes ──────────────────────
    "monthly-horoscopes": {
        "task": "tasks.horoscope_tasks.generate_monthly_horoscopes",
        "schedule": crontab(hour=2, minute=0, day_of_month="1"),
        "options": {"queue": "batch"},
    },

    # ── Nightly compatibility cache warm ──────────────────────────────────
    # 02:30 UTC — after daily horoscopes finish
    "nightly-compatibility-cache": {
        "task": "tasks.horoscope_tasks.warm_compatibility_cache",
        "schedule": crontab(hour=2, minute=30),
        "options": {"queue": "batch"},
    },

    # ── Nightly: card of the day for all signs ────────────────────────────
    "nightly-tarot-card-of-day": {
        "task": "tasks.tarot_tasks.generate_card_of_the_day",
        "schedule": crontab(hour=1, minute=15),
        "options": {"queue": "batch"},
    },

    # ── Midnight: refresh cosmic events DB ────────────────────────────────
    "nightly-cosmic-events-refresh": {
        "task": "tasks.cosmic_event_tasks.refresh_cosmic_events",
        "schedule": crontab(hour=0, minute=30),
        "options": {"queue": "maintenance"},
    },

    # ── Daily: purge past events from DB ──────────────────────────────────
    "daily-purge-past-events": {
        "task": "tasks.maintenance_tasks.purge_past_events",
        "schedule": crontab(hour=0, minute=45),
        "options": {"queue": "maintenance"},
    },

    # ── Hourly: warm today's events cache ─────────────────────────────────
    "hourly-events-cache-warm": {
        "task": "tasks.cosmic_event_tasks.warm_events_today_cache",
        "schedule": crontab(minute=0),          # every hour at :00
        "options": {"queue": "maintenance"},
    },
}
```

### Schedule Summary Table

| Job name | Cron (UTC) | AI calls/run | Redis keys written |
|---|---|---|---|
| `generate_daily_horoscopes` | `0 1 * * *` | 72 (12 signs × 6 focuses) | `horoscope:daily:{sign}:{date}` × 12 |
| `generate_weekly_horoscopes` | `30 1 * * 0` | 72 | `horoscope:weekly:{sign}:{week}` × 12 |
| `generate_monthly_horoscopes` | `0 2 1 * *` | 72 | `horoscope:monthly:{sign}:{month}` × 12 |
| `warm_compatibility_cache` | `30 2 * * *` | 78 (unique pairs) | `compatibility:{s1}:{s2}` × 78 |
| `generate_card_of_the_day` | `15 1 * * *` | 12 | `tarot:card_of_day:{sign}:{date}` × 12 |
| `refresh_cosmic_events` | `30 0 * * *` | 0 (scraper only) | `events:today:{date}`, `events:upcoming:{date}` |
| `purge_past_events` | `45 0 * * *` | 0 | none |
| `warm_events_today_cache` | `0 * * * *` | 0 | `events:today:{date}` |

**Total daily AI calls from batch jobs:** ~234 (worst case, all jobs run on the same day as a monthly rollover on a Sunday)  
**Typical daily AI calls from batch:** 84 (daily horoscopes 72 + card of day 12)

---

## 6. Batch Horoscope Generation Job

### `tasks/horoscope_tasks.py`

```python
import asyncio
import logging
from datetime import date, datetime
from celery import shared_task
from celery.utils.log import get_task_logger

from celery_app import celery_app
from core.config import get_settings
from core.cache import set_cache_sync
from database.config import get_db_session
from database import crud
from services.gemini_client import generate_horoscope_batch
from services.horoscope_prompt_builder import build_batch_prompt

logger = get_task_logger(__name__)
settings = get_settings()

ZODIAC_SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces",
]

FOCUS_AREAS = [
    "overall",
    "love",
    "career",
    "wealth",
    "daily_suggestion",
    "encouragement",
]


@celery_app.task(
    name="tasks.horoscope_tasks.generate_daily_horoscopes",
    bind=True,
    max_retries=3,
    default_retry_delay=300,     # 5 minutes between retries
    queue="batch",
)
def generate_daily_horoscopes(self, target_date: str | None = None):
    """
    Nightly batch job: generate one horoscope per zodiac sign (6 focus areas each).
    Total AI calls: 72 (12 signs × 6 focuses).

    Each sign's 6 focus areas are batched into ONE Gemini request using a structured
    multi-part prompt, then parsed. This reduces round trips to 12 API calls total.

    Writes:
      - PostgreSQL: upsert into `daily_horoscopes` table
      - Redis: set `horoscope:daily:{sign}:{date}` with 26h TTL
    """
    for_date = date.fromisoformat(target_date) if target_date else date.today()
    date_str = for_date.isoformat()
    logger.info("Starting daily horoscope batch for %s", date_str)

    success_count = 0
    failure_count = 0

    with get_db_session() as db:
        for sign in ZODIAC_SIGNS:
            try:
                horoscope_data = _generate_horoscope_for_sign(sign, for_date)

                # Persist to PostgreSQL
                crud.upsert_daily_horoscope(
                    db=db,
                    sign=sign,
                    for_date=for_date,
                    data=horoscope_data,
                )

                # Write to Redis cache (TTL: 26h — covers the full day + 2h overlap)
                cache_key = f"horoscope:daily:{sign.lower()}:{date_str}"
                set_cache_sync(cache_key, horoscope_data, ttl=93600)

                logger.info("Horoscope generated and cached for %s on %s", sign, date_str)
                success_count += 1

            except Exception as exc:
                logger.error(
                    "Failed to generate horoscope for %s on %s: %s",
                    sign, date_str, exc, exc_info=True
                )
                failure_count += 1
                # Continue to next sign — partial success is better than total failure

    logger.info(
        "Daily horoscope batch complete for %s: %d succeeded, %d failed",
        date_str, success_count, failure_count
    )

    if failure_count > 0 and success_count == 0:
        # All signs failed — retry the whole task
        raise self.retry(exc=Exception("All signs failed"), countdown=300)

    return {
        "date": date_str,
        "success": success_count,
        "failed": failure_count,
    }


def _generate_horoscope_for_sign(sign: str, for_date: date) -> dict:
    """
    Makes ONE Gemini API call per sign, returning all 6 focus areas in a single
    structured response. Reduces API round trips from 72 to 12 per batch run.
    """
    import google.generativeai as genai
    import json
    import random

    genai.configure(api_key=settings.GEMINI_API_KEY)
    model = genai.GenerativeModel(settings.GEMINI_MODEL)

    prompt = f"""You are a professional astrologer writing daily horoscopes.
Today's date: {for_date.isoformat()}
Zodiac sign: {sign}

Write today's horoscope for {sign} covering exactly these 6 focus areas.
Return ONLY a valid JSON object with these exact keys, no markdown, no extra text:

{{
  "overall": "<2–3 sentence overall daily reading, max 80 words>",
  "love": "<2 sentence love and relationship reading, max 60 words>",
  "career": "<2 sentence career and ambition reading, max 60 words>",
  "wealth": "<2 sentence financial reading, max 60 words>",
  "daily_suggestion": "<1 actionable suggestion for the day, max 40 words>",
  "encouragement": "<1 motivational sentence, max 30 words>"
}}

Requirements:
- Each section must be self-contained (no cross-references like "as mentioned above")
- Avoid the word "embrace" and other overused astrology clichés
- Vary sentence structure across sections
- Keep the tone warm, grounded, and specific to {sign}'s traits
"""

    response = model.generate_content(
        contents=prompt,
        generation_config={
            "max_output_tokens": 500,
            "temperature": random.uniform(0.6, 0.85),
            "top_k": 40,
            "top_p": 0.92,
            "response_mime_type": "application/json",
        },
    )

    raw = response.text.strip()

    # Strip markdown code fences if model ignores response_mime_type
    if raw.startswith("```"):
        raw = raw.split("```")[1]
        if raw.startswith("json"):
            raw = raw[4:]

    data = json.loads(raw)

    # Validate all required keys are present
    for key in FOCUS_AREAS:
        if key not in data or not data[key]:
            raise ValueError(f"Missing or empty key '{key}' in Gemini response for {sign}")

    data["sign"] = sign
    data["period"] = "daily"
    data["date"] = for_date.isoformat()
    data["generated_at"] = datetime.utcnow().isoformat() + "Z"
    data["lucky_number"] = random.randint(1, 99)
    data["lucky_color"] = _lucky_color_for_sign(sign)

    return data


@celery_app.task(
    name="tasks.horoscope_tasks.generate_weekly_horoscopes",
    bind=True,
    max_retries=3,
    default_retry_delay=300,
    queue="batch",
)
def generate_weekly_horoscopes(self):
    """
    Sunday 01:30 UTC. Generates weekly horoscopes for all 12 signs.
    Cache key: horoscope:weekly:{sign}:{iso_week}  e.g. horoscope:weekly:aries:2026-W23
    TTL: 7 days + 2h overlap = 612,000 seconds
    """
    from datetime import timedelta
    today = date.today()
    week_key = today.strftime("%G-W%V")     # ISO 8601 week, e.g. "2026-W23"

    logger.info("Starting weekly horoscope batch for week %s", week_key)

    with get_db_session() as db:
        for sign in ZODIAC_SIGNS:
            try:
                data = _generate_period_horoscope(sign, "weekly", today, week_key)
                crud.upsert_period_horoscope(db, sign, "weekly", week_key, data)
                cache_key = f"horoscope:weekly:{sign.lower()}:{week_key}"
                set_cache_sync(cache_key, data, ttl=612000)
            except Exception as exc:
                logger.error("Weekly horoscope failed for %s: %s", sign, exc, exc_info=True)


@celery_app.task(
    name="tasks.horoscope_tasks.generate_monthly_horoscopes",
    bind=True,
    max_retries=3,
    default_retry_delay=300,
    queue="batch",
)
def generate_monthly_horoscopes(self):
    """
    1st of month, 02:00 UTC. Generates monthly horoscopes for all 12 signs.
    Cache key: horoscope:monthly:{sign}:{year}-{month}  e.g. horoscope:monthly:aries:2026-06
    TTL: 32 days = 2,764,800 seconds
    """
    today = date.today()
    month_key = today.strftime("%Y-%m")

    logger.info("Starting monthly horoscope batch for %s", month_key)

    with get_db_session() as db:
        for sign in ZODIAC_SIGNS:
            try:
                data = _generate_period_horoscope(sign, "monthly", today, month_key)
                crud.upsert_period_horoscope(db, sign, "monthly", month_key, data)
                cache_key = f"horoscope:monthly:{sign.lower()}:{month_key}"
                set_cache_sync(cache_key, data, ttl=2764800)
            except Exception as exc:
                logger.error("Monthly horoscope failed for %s: %s", sign, exc, exc_info=True)


@celery_app.task(
    name="tasks.horoscope_tasks.warm_compatibility_cache",
    queue="batch",
)
def warm_compatibility_cache():
    """
    Generates all 78 unique zodiac sign pair compatibility reports nightly.
    Cached under: compatibility:{sign1_alpha}:{sign2_alpha}
    TTL: 30 days (content is not date-dependent)
    """
    import itertools
    import json
    import google.generativeai as genai
    from services.compatibility_prompt_builder import build_batch_compatibility_prompt

    genai.configure(api_key=settings.GEMINI_API_KEY)
    model = genai.GenerativeModel(settings.GEMINI_MODEL)

    pairs = list(itertools.combinations(ZODIAC_SIGNS, 2))
    logger.info("Warming compatibility cache: %d pairs", len(pairs))

    for sign1, sign2 in pairs:
        key1, key2 = sorted([sign1.lower(), sign2.lower()])
        cache_key = f"compatibility:{key1}:{key2}"

        # Skip if already cached (avoid re-generating unnecessarily)
        # In production use get_cache_sync() here
        try:
            prompt = build_batch_compatibility_prompt(sign1, sign2)
            response = model.generate_content(
                contents=prompt,
                generation_config={
                    "max_output_tokens": 400,
                    "temperature": 0.65,
                    "response_mime_type": "application/json",
                },
            )
            data = json.loads(response.text.strip())
            data["sign_1"] = sign1
            data["sign_2"] = sign2
            set_cache_sync(cache_key, data, ttl=2592000)   # 30 days
        except Exception as exc:
            logger.error("Compatibility cache failed for %s/%s: %s", sign1, sign2, exc)


def _lucky_color_for_sign(sign: str) -> str:
    colors = {
        "Aries": "Red", "Taurus": "Green", "Gemini": "Yellow",
        "Cancer": "Silver", "Leo": "Gold", "Virgo": "Navy",
        "Libra": "Pink", "Scorpio": "Crimson", "Sagittarius": "Purple",
        "Capricorn": "Brown", "Aquarius": "Electric Blue", "Pisces": "Sea Green",
    }
    return colors.get(sign, "White")


def _generate_period_horoscope(sign: str, period: str, ref_date: date, period_key: str) -> dict:
    """Shared helper for weekly and monthly generation."""
    import google.generativeai as genai
    import json
    import random

    genai.configure(api_key=settings.GEMINI_API_KEY)
    model = genai.GenerativeModel(settings.GEMINI_MODEL)

    period_label = "this week" if period == "weekly" else "this month"
    word_limit = 100 if period == "weekly" else 150

    prompt = f"""You are a professional astrologer writing {period} horoscopes.
Reference date: {ref_date.isoformat()} | Period key: {period_key}
Zodiac sign: {sign}

Write the {period} horoscope for {sign} covering these 6 areas for {period_label}.
Return ONLY valid JSON (no markdown):

{{
  "overall": "<overall {period} reading, max {word_limit} words>",
  "love": "<love and relationships for {period_label}, max 80 words>",
  "career": "<career and ambition for {period_label}, max 80 words>",
  "wealth": "<financial outlook for {period_label}, max 80 words>",
  "daily_suggestion": "<key focus or theme for {period_label}, max 50 words>",
  "encouragement": "<motivational message for {period_label}, max 40 words>"
}}

Be specific to {sign}'s elemental nature and ruling planet. No clichés.
"""

    response = model.generate_content(
        contents=prompt,
        generation_config={
            "max_output_tokens": 800,
            "temperature": random.uniform(0.6, 0.8),
            "response_mime_type": "application/json",
        },
    )
    data = json.loads(response.text.strip())
    data.update({
        "sign": sign,
        "period": period,
        "period_key": period_key,
        "generated_at": datetime.utcnow().isoformat() + "Z",
    })
    return data
```

---

## 7. Cache Strategy

### Redis Key Schema

```
# Horoscopes
horoscope:daily:{sign_lower}:{YYYY-MM-DD}           TTL: 93,600s  (26h)
horoscope:weekly:{sign_lower}:{YYYY-W##}            TTL: 612,000s (7d + 2h)
horoscope:monthly:{sign_lower}:{YYYY-MM}            TTL: 2,764,800s (32d)
horoscope:personalized:{user_id}:{YYYY-MM-DD}       TTL: 86,400s  (24h)

# Compatibility
compatibility:{sign1_alpha}:{sign2_alpha}            TTL: 2,592,000s (30d)
                                                     signs are sorted alphabetically

# Cosmic events
events:today:{YYYY-MM-DD}                           TTL: 3,600s   (1h, refreshed hourly)
events:upcoming:{YYYY-MM-DD}                        TTL: 3,600s   (1h)
events:retrogrades:active                           TTL: 3,600s   (1h)

# Tarot
tarot:card_of_day:{sign_lower}:{YYYY-MM-DD}         TTL: 93,600s  (26h)

# Natal chart
natal:{user_id}                                     TTL: -1       (no expiry, invalidate on update)

# AI rate limiting (see Section 8)
ai_usage:{user_id}:{YYYY-MM-DD}                     TTL: 86,400s  (24h, auto-expires at midnight)

# Subscription status (short-lived, avoid stale tier checks)
subscription:{user_id}                              TTL: 300s     (5 min)
```

### `core/cache.py`

```python
import redis.asyncio as aioredis
import redis as syncredis
import json
import logging
from core.config import get_settings

settings = get_settings()
logger = logging.getLogger(__name__)

# Async client (for FastAPI request handlers)
_async_redis: aioredis.Redis | None = None

# Sync client (for Celery tasks which run in worker threads)
_sync_redis: syncredis.Redis | None = None


def get_async_redis() -> aioredis.Redis:
    global _async_redis
    if _async_redis is None:
        _async_redis = aioredis.from_url(
            settings.REDIS_URL,
            encoding="utf-8",
            decode_responses=True,
            socket_connect_timeout=5,
            socket_timeout=5,
        )
    return _async_redis


def get_sync_redis() -> syncredis.Redis:
    global _sync_redis
    if _sync_redis is None:
        _sync_redis = syncredis.from_url(
            settings.REDIS_URL,
            encoding="utf-8",
            decode_responses=True,
            socket_connect_timeout=5,
            socket_timeout=5,
        )
    return _sync_redis


async def get_cache(key: str) -> dict | None:
    """Cache-aside read. Returns None on miss or Redis error (fail open)."""
    try:
        r = get_async_redis()
        value = await r.get(key)
        if value:
            return json.loads(value)
    except Exception as exc:
        logger.warning("Redis GET failed for key %s: %s", key, exc)
    return None


async def set_cache(key: str, value: dict, ttl: int = None) -> None:
    """Cache-aside write. Silent failure — DB is source of truth."""
    try:
        r = get_async_redis()
        ttl = ttl or settings.REDIS_TTL_DEFAULT
        await r.set(key, json.dumps(value), ex=ttl)
    except Exception as exc:
        logger.warning("Redis SET failed for key %s: %s", key, exc)


async def delete_cache(key: str) -> None:
    try:
        r = get_async_redis()
        await r.delete(key)
    except Exception as exc:
        logger.warning("Redis DELETE failed for key %s: %s", key, exc)


async def delete_pattern(pattern: str) -> int:
    """Delete all keys matching a pattern. Use sparingly — SCAN-based."""
    try:
        r = get_async_redis()
        keys = []
        async for key in r.scan_iter(pattern):
            keys.append(key)
        if keys:
            await r.delete(*keys)
        return len(keys)
    except Exception as exc:
        logger.warning("Redis pattern DELETE failed for %s: %s", pattern, exc)
        return 0


# Synchronous variants for use inside Celery tasks
def get_cache_sync(key: str) -> dict | None:
    try:
        r = get_sync_redis()
        value = r.get(key)
        if value:
            return json.loads(value)
    except Exception as exc:
        logger.warning("Redis sync GET failed for key %s: %s", key, exc)
    return None


def set_cache_sync(key: str, value: dict, ttl: int = None) -> None:
    try:
        r = get_sync_redis()
        ttl = ttl or settings.REDIS_TTL_DEFAULT
        r.set(key, json.dumps(value), ex=ttl)
    except Exception as exc:
        logger.warning("Redis sync SET failed for key %s: %s", key, exc)
```

### Cache Invalidation Rules

| Event | Keys to invalidate |
|---|---|
| User updates natal chart | `natal:{user_id}`, `horoscope:personalized:{user_id}:*` |
| Admin triggers horoscope regeneration for a date | `horoscope:daily:*:{date}` |
| Cosmic event DB refresh | `events:today:*`, `events:upcoming:*`, `events:retrogrades:*` |
| User subscription changes | `subscription:{user_id}` |

---

## 8. AI Call Management

### Rate Limiting

```python
# core/rate_limit.py
from dataclasses import dataclass
from datetime import date
from fastapi import HTTPException
import redis.asyncio as aioredis
from core.cache import get_async_redis
from core.config import get_settings

settings = get_settings()


@dataclass
class UsageStatus:
    used: int
    remaining: int
    limit: int


async def check_and_increment_ai_usage(user_id: str, tier: str) -> UsageStatus:
    """
    Atomically checks and increments the daily AI call counter for a user.
    Uses Redis INCR + EXPIRE. The key expires at the start of the next UTC day
    (TTL set to seconds remaining in current UTC day + a small buffer).

    Raises HTTP 429 if limit exceeded.
    """
    limit = (
        settings.AI_CHAT_PRO_DAILY_LIMIT
        if tier == "pro"
        else settings.AI_CHAT_FREE_DAILY_LIMIT
    )

    today = date.today().isoformat()
    key = f"ai_usage:{user_id}:{today}"
    r = get_async_redis()

    # Atomic increment
    current = await r.incr(key)

    # Set TTL on first write (key did not exist before)
    if current == 1:
        # Expire at end of day UTC + 5 minute buffer
        import datetime
        now = datetime.datetime.utcnow()
        end_of_day = datetime.datetime(now.year, now.month, now.day, 23, 59, 59)
        ttl = int((end_of_day - now).total_seconds()) + 300
        await r.expire(key, ttl)

    if current > limit:
        # Decrement to avoid overcounting rejected calls
        await r.decr(key)
        raise HTTPException(
            status_code=429,
            detail={
                "error": "daily_ai_limit_reached",
                "message": f"You have used all {limit} AI messages for today. "
                           f"{'Upgrade to Pro for more.' if tier == 'free' else 'Limit resets at midnight UTC.'}",
                "limit": limit,
                "resets_at": f"{today}T23:59:59Z",
            },
        )

    return UsageStatus(
        used=current,
        remaining=limit - current,
        limit=limit,
    )


async def get_ai_usage(user_id: str, tier: str) -> UsageStatus:
    """Read-only usage check (for GET /chat/usage)."""
    limit = (
        settings.AI_CHAT_PRO_DAILY_LIMIT if tier == "pro"
        else settings.AI_CHAT_FREE_DAILY_LIMIT
    )
    today = date.today().isoformat()
    key = f"ai_usage:{user_id}:{today}"
    r = get_async_redis()
    raw = await r.get(key)
    used = int(raw) if raw else 0
    return UsageStatus(used=used, remaining=max(0, limit - used), limit=limit)
```

### Centralised Gemini Client with Retry

```python
# services/gemini_client.py
import asyncio
import logging
import google.generativeai as genai
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type,
)
from core.config import get_settings
from models.chat import ChatMessage

settings = get_settings()
logger = logging.getLogger(__name__)

genai.configure(api_key=settings.GEMINI_API_KEY)
_model = genai.GenerativeModel(settings.GEMINI_MODEL)

# Exceptions that are transient and worth retrying
_RETRYABLE = (Exception,)    # narrow this to specific google.api_core exceptions in production


@retry(
    stop=stop_after_attempt(settings.GEMINI_MAX_RETRIES),
    wait=wait_exponential(multiplier=settings.GEMINI_RETRY_DELAY_SECONDS, min=1, max=30),
    retry=retry_if_exception_type(_RETRYABLE),
    reraise=True,
)
async def generate_chat_response(
    system_prompt: str,
    history: list[ChatMessage],
    user_message: str,
) -> str:
    """
    Async wrapper around Gemini's generate_content for chat.
    Runs the blocking SDK call in a thread pool executor.
    """
    def _call():
        contents = [{"role": "user", "parts": [system_prompt]}]
        for msg in history[-10:]:           # cap context at last 10 turns
            contents.append({"role": msg.role, "parts": [msg.content]})
        contents.append({"role": "user", "parts": [user_message]})

        response = _model.generate_content(
            contents=contents,
            generation_config={
                "max_output_tokens": 400,
                "temperature": 0.75,
                "top_k": 40,
                "top_p": 0.92,
            },
        )
        return response.text.strip()

    try:
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, _call)
    except Exception as exc:
        error_msg = str(exc)
        logger.error("Gemini API error: %s", error_msg, exc_info=True)

        # Translate to user-friendly messages
        if "429" in error_msg or "quota" in error_msg.lower():
            raise HTTPException(
                status_code=503,
                detail="The AI Astrologer is temporarily at capacity. Please try again in a few minutes."
            )
        elif "SAFETY" in error_msg:
            raise HTTPException(
                status_code=422,
                detail="Your message could not be processed. Please rephrase and try again."
            )
        raise HTTPException(status_code=503, detail="AI service temporarily unavailable.")
```

### Cost Tracking

Track AI spend by logging each call to a `ai_call_logs` table:

```python
# database/models.py (addition)
class AiCallLog(Base):
    __tablename__ = "ai_call_logs"

    id = Column(Integer, primary_key=True)
    user_id = Column(String, nullable=True)         # null for batch jobs
    call_type = Column(String, nullable=False)       # "chat" | "batch_horoscope" | "tarot" | etc.
    sign = Column(String, nullable=True)
    tokens_input = Column(Integer, nullable=True)
    tokens_output = Column(Integer, nullable=True)
    model = Column(String, nullable=False)
    duration_ms = Column(Integer, nullable=True)
    success = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
```

---

## 9. Error Handling

### Standard error envelope

All errors return a consistent JSON envelope:

```json
{
  "error": "snake_case_error_code",
  "message": "Human-readable description for the client",
  "detail": {}          // optional structured metadata (e.g., limit values for 429)
}
```

### `core/exceptions.py`

```python
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={
            "error": "validation_error",
            "message": "Request body or query parameters are invalid.",
            "detail": exc.errors(),
        },
    )

async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "error": "internal_server_error",
            "message": "An unexpected error occurred. Please try again.",
        },
    )
```

Register in `main.py`:

```python
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)
```

### AI Fallback Behaviour

| Scenario | Behaviour |
|---|---|
| Gemini quota exceeded (429) | Return 503 with retry hint; do **not** consume user's daily quota |
| Gemini returns safety block | Return 422 asking user to rephrase |
| Batch job fails for a sign | Log error, continue to next sign; partial result committed |
| Redis unavailable | Fail open — serve from DB; log warning; do not surface Redis errors to client |
| DB unavailable | Return 503; Celery task retries after 5 minutes |

---

## 10. Migration Notes

### APScheduler → Celery Beat

The current `backend/services/scheduler_service.py` uses APScheduler with in-process background threads, which has several problems: it runs inside the web server process (no horizontal scaling), doesn't persist job state across restarts, and makes HTTP calls back to the same server (`localhost:8000`) to trigger work.

**Migration steps:**

1. Remove `start_scheduler` / `shutdown_scheduler` calls from `main.py` lifespan.
2. Remove the APScheduler dependency from `requirements.txt`.
3. Add `celery>=5.3`, `redis>=5.0`, `tenacity>=8.2` to `requirements.txt`.
4. Move the logic from `scheduler_service.py` into Celery task functions in `tasks/`.
5. Run Beat as a separate process: `celery -A celery_app beat --loglevel=info`
6. Run workers as separate processes: `celery -A celery_app worker -Q batch,maintenance --concurrency=2`

### Endpoint renames (`/api/v1/` prefix + REST conventions)

| Old path | New path | Notes |
|---|---|---|
| `POST /horoscope` | `GET /api/v1/horoscope/daily` | No longer triggers AI per-request; sign from JWT |
| `POST /compatibility` | `GET /api/v1/compatibility/{sign1}/{sign2}` | Served from cache |
| `POST /natal_chart` | `POST /api/v1/users/me/natal-chart` | User-scoped, persisted |
| `POST /review_event` | `POST /api/v1/chat` (with context) | Folded into AI Astrologer chat |
| `POST /with_celebrity` | `POST /api/v1/compatibility/personal` | Extended compatibility |
| `GET /events-today` | `GET /api/v1/events/today` | Cache-first |
| `POST /update-database/` | `POST /api/v1/admin/events/refresh` | Admin-only |
| `POST /admin/clear-past-events/` | `POST /api/v1/admin/events/purge-past` | Admin-only |

### SQLite → PostgreSQL

The current `planetary_notification_data.sqlite3` must be migrated to Supabase PostgreSQL. Run once:

```bash
# Export from SQLite
sqlite3 backend/database/planetary_notification_data.sqlite3 .dump > legacy_dump.sql

# Import into PostgreSQL (after schema migration via Alembic)
psql $DATABASE_URL < legacy_dump.sql
```

Use **Alembic** for all future schema migrations:

```bash
alembic init alembic
alembic revision --autogenerate -m "initial schema"
alembic upgrade head
```

---

*End of BACKEND_API.md — AstroAI v2.0 Backend Specification*
