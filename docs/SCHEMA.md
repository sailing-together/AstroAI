# AstroAI Schema Source of Truth

> Status: Canonical database schema for redevelopment.
> Last updated: 2026-06-02

## Database

Use PostgreSQL 16 via Supabase.

Required extensions:

```sql
create extension if not exists "uuid-ossp";
create extension if not exists "pg_trgm";
create extension if not exists "vector";
```

Supabase Auth owns `auth.users`. Application data lives in `public`.

## Enums

```sql
create type user_tier as enum ('free', 'premium');
create type subscription_status as enum ('inactive', 'trialing', 'active', 'past_due', 'canceled');
create type zodiac_sign as enum (
  'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
  'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
);
create type horoscope_period as enum ('daily', 'weekly', 'monthly');
create type horoscope_focus as enum ('general', 'love', 'career', 'wellness', 'money', 'social');
```

## Core Tables

### users

Application profile mirrored from Supabase Auth.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | App user id |
| `auth_id` | uuid unique not null | References `auth.users.id` |
| `email` | text | Account email |
| `display_name` | text | Optional |
| `tier` | user_tier | Defaults to `free` |
| `created_at` | timestamptz | Defaults now |
| `updated_at` | timestamptz | Defaults now |

### natal_charts

One active chart per user for MVP.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Chart id |
| `user_id` | uuid not null | References `users.id` |
| `birth_date` | date not null | Required |
| `birth_time` | time | Nullable when unknown |
| `unknown_time` | boolean not null | Defaults false |
| `birth_place_name` | text not null | Display place |
| `birth_lat` | numeric not null | Latitude |
| `birth_lng` | numeric not null | Longitude |
| `timezone` | text not null | IANA timezone |
| `sun_sign` | zodiac_sign not null | Deterministic |
| `moon_sign` | zodiac_sign | Nullable if uncertain |
| `ascendant_sign` | zodiac_sign | Nullable if unknown time |
| `planets` | jsonb not null | Planet placements |
| `houses` | jsonb | Nullable if unknown time |
| `aspects` | jsonb not null | Aspect list |
| `chart_hash` | text not null | Deterministic cache key |
| `interpretation` | jsonb | Gemini 2.5 Flash output |
| `created_at` | timestamptz | Defaults now |
| `updated_at` | timestamptz | Defaults now |

Unique index: `(user_id)`.

### ai_conversations

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Conversation id |
| `user_id` | uuid not null | References `users.id` |
| `title` | text | Optional generated title |
| `created_at` | timestamptz | Defaults now |
| `updated_at` | timestamptz | Defaults now |

### ai_messages

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Message id |
| `conversation_id` | uuid not null | References `ai_conversations.id` |
| `user_id` | uuid not null | References `users.id` |
| `role` | text not null | `user` or `assistant` |
| `content` | text not null | Message content |
| `model_used` | text | Defaults to `gemini-2.5-flash` for assistant messages |
| `prompt_version` | text | Optional |
| `token_count` | integer | Optional |
| `created_at` | timestamptz | Defaults now |

### ai_memories

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Memory id |
| `user_id` | uuid not null | References `users.id` |
| `source_message_id` | uuid | References `ai_messages.id` |
| `content` | text not null | Memory text |
| `category` | text not null | Relationship, career, health, family, identity, other |
| `embedding` | vector | Optional semantic retrieval |
| `importance` | integer | 1-5 |
| `created_at` | timestamptz | Defaults now |
| `last_used_at` | timestamptz | Optional |

### mood_logs

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Mood log id |
| `user_id` | uuid not null | References `users.id` |
| `mood_score` | integer not null | 1-10 |
| `energy_score` | integer not null | 1-10 |
| `notes` | text | Optional |
| `logged_at` | timestamptz not null | User-selected or now |
| `created_at` | timestamptz | Defaults now |

## Static Content Tables

### static_horoscopes

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Content id |
| `sign` | zodiac_sign not null | Zodiac sign |
| `period` | horoscope_period not null | Daily, weekly, monthly |
| `focus` | horoscope_focus not null | Focus area |
| `content_date` | date not null | Date or period start |
| `title` | text not null | SEO/display title |
| `summary` | text not null | Short summary |
| `body` | text not null | Full copy |
| `lucky_numbers` | integer[] | Optional |
| `lucky_color` | text | Optional |
| `generation_model` | text | `gemini-2.5-flash-lite` |
| `generated_at` | timestamptz | Defaults now |

Unique index: `(sign, period, focus, content_date)`.

### static_sign_profiles

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Content id |
| `sign` | zodiac_sign unique not null | Zodiac sign |
| `profile` | jsonb not null | Traits, strengths, growth edges |
| `generation_model` | text | `gemini-2.5-flash-lite` |
| `updated_at` | timestamptz | Defaults now |

### static_compatibility

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Content id |
| `sign_a` | zodiac_sign not null | First sign |
| `sign_b` | zodiac_sign not null | Second sign |
| `score` | integer not null | 0-100 |
| `summary` | text not null | Short summary |
| `strengths` | jsonb not null | List |
| `frictions` | jsonb not null | List |
| `advice` | jsonb not null | List |
| `generation_model` | text | `gemini-2.5-flash` |
| `updated_at` | timestamptz | Defaults now |

Unique index: `(sign_a, sign_b)`.

### static_cosmic_events

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Content id |
| `event_date` | date unique not null | Date |
| `events` | jsonb not null | Lunar phases, retrogrades, ingresses, aspects |
| `summary` | text | Human-readable summary |
| `created_at` | timestamptz | Defaults now |

### static_tarot_cards

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Card id |
| `slug` | text unique not null | Stable slug |
| `name` | text not null | Card name |
| `arcana` | text not null | Major/minor |
| `suit` | text | Optional |
| `upright_meaning` | text not null | Static copy |
| `reversed_meaning` | text not null | Static copy |
| `astrology_links` | jsonb | Optional correspondences |

## Monetization Tables

### subscriptions

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Subscription id |
| `user_id` | uuid unique not null | References `users.id` |
| `stripe_customer_id` | text unique | Stripe customer |
| `stripe_subscription_id` | text unique | Stripe subscription |
| `status` | subscription_status not null | Current state |
| `tier` | user_tier not null | `free` or `premium` |
| `current_period_end` | timestamptz | Optional |
| `created_at` | timestamptz | Defaults now |
| `updated_at` | timestamptz | Defaults now |

## Feature Tables

### tarot_draws

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Draw id |
| `user_id` | uuid not null | References `users.id` |
| `card_id` | uuid not null | References `static_tarot_cards.id` |
| `question` | text | Optional |
| `interpretation` | jsonb | Gemini 2.5 Flash output |
| `created_at` | timestamptz | Defaults now |

### notification_preferences

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Preference id |
| `user_id` | uuid unique not null | References `users.id` |
| `daily_horoscope_enabled` | boolean | Defaults true |
| `cosmic_event_enabled` | boolean | Defaults true |
| `mood_checkin_enabled` | boolean | Defaults false |
| `timezone` | text | IANA timezone |
| `updated_at` | timestamptz | Defaults now |

### content_generation_log

| Column | Type | Notes |
|---|---|---|
| `id` | uuid primary key | Log id |
| `content_type` | text not null | Horoscope, compatibility, etc. |
| `content_key` | text not null | Stable generation key |
| `model_used` | text not null | Gemini model |
| `status` | text not null | `success`, `failed`, `skipped` |
| `error_message` | text | Optional |
| `created_at` | timestamptz | Defaults now |

## Row Level Security

Enable RLS for all user-owned tables:

- `users`
- `natal_charts`
- `ai_conversations`
- `ai_messages`
- `ai_memories`
- `mood_logs`
- `tarot_draws`
- `notification_preferences`
- `subscriptions`

Static content tables may be publicly readable. Writes to static content, subscription state, and logs must go through the backend service role.

## Migration Notes

Existing SQLite ephemeris tables should migrate into `static_cosmic_events.events` as structured JSON. SQLite is not part of the redeveloped production stack.

Migration order:

1. Provision Supabase project.
2. Enable extensions.
3. Create enums.
4. Create `users`.
5. Create `natal_charts`.
6. Create static content tables.
7. Create AI conversation, message, and memory tables.
8. Create feature and monetization tables.
9. Enable RLS.
10. Backfill static cosmic events from SQLite.

