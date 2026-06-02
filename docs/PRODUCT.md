# AstroAI Product Source of Truth

> Status: Canonical product direction for the AstroAI redevelopment.
> Last updated: 2026-06-02

## Product Thesis

AstroAI is a chart-grounded astrology companion. The product should feel personal because it remembers the user's natal chart, relevant life context, moods, and relationship questions, not because it generates generic horoscope copy on demand.

The MVP proves one loop:

1. A user signs up.
2. The user enters birth details.
3. AstroAI calculates and stores the natal chart.
4. The user receives a chart-specific reading.
5. The user returns to ask the AI Astrologer another question.

Anything outside that loop is secondary until activation, retention, and willingness to pay are measurable.

## Audience

AstroAI is for astrology-curious users who want practical personal interpretation without learning chart technique. The core user values emotional relevance, privacy, aesthetic quality, and continuity over technical astrology jargon.

## Positioning

AstroAI should compete less as a horoscope feed and more as a personal cosmic companion.

Differentiators:

- Natal chart as identity layer.
- AI Astrologer as the daily interaction.
- Memory layer as the retention moat.
- Static SEO pages as the acquisition engine.
- Shareable readings as the viral loop.

## MVP Scope

Build first:

- Supabase authentication.
- Birth data onboarding.
- Natal chart calculation and persistence.
- Natal chart summary.
- AI Astrologer chat.
- Daily AI message limits.
- Public daily horoscope pages.
- Public sign profile pages.
- Public sign-pair compatibility pages.
- Basic static content generation jobs.

Build after the core loop works:

- AI memory extraction and retrieval.
- Mood logging.
- Weekly mood/transit insights.
- Tarot + astrology fusion.
- Stripe subscription.
- Share cards.
- Smart notifications.

Out of scope for MVP:

- Claude/Sonnet integration.
- Unlimited premium AI usage.
- React Native/Expo rewrite.
- ASMR or meditation suite.
- Community matching.
- B2B astrology.
- Wearables.
- Voice features.

## AI Policy

MVP uses Gemini only.

| Use case | Model |
|---|---|
| AI Astrologer chat | Gemini 2.5 Flash |
| Natal chart interpretation | Gemini 2.5 Flash |
| Personalized daily guidance | Gemini 2.5 Flash |
| Tarot + astrology fusion | Gemini 2.5 Flash |
| Compatibility synthesis | Gemini 2.5 Flash |
| Memory synthesis | Gemini 2.5 Flash |
| Static horoscope generation | Gemini 2.5 Flash-Lite |
| Sign profile summaries | Gemini 2.5 Flash-Lite |
| Lucky numbers and colors | Gemini 2.5 Flash-Lite |
| Notification copy | Gemini 2.5 Flash-Lite |
| Extraction and classification | Gemini 2.5 Flash-Lite |

Do not use Gemini 2.0 Flash. It was shut down on 2026-06-01.

Do not use Claude/Sonnet in MVP backend code. Claude can be reconsidered after production analytics show a clear quality gap worth the cost.

Gemini free tier is acceptable for prototypes and demos. Production should use paid Gemini API access because user data includes birth details, mood logs, relationships, and memories.

## Tier Policy

Use only these tier names:

- `free`
- `premium`

Avoid `pro` in code, API responses, UI copy, Stripe metadata, and docs.

MVP AI Astrologer limits:

| Tier | Limit |
|---|---:|
| `free` | 3 messages/day |
| `premium` | 50 messages/day |

Premium is intentionally not unlimited in MVP.

## Roadmap

### Phase 0: Security and Documentation

Goal: make the project safe and unambiguous.

Deliverables:

- Rotate any exposed Gemini keys.
- Add backend and frontend `.env.example` files.
- Confirm `.env`, `.env.local`, and secret files are ignored.
- Freeze canonical API route names and DTOs.
- Freeze tier names as `free` and `premium`.

### Phase 1: Backend Foundation

Goal: build the API, database, auth, chart calculation, and Gemini foundations.

Deliverables:

- FastAPI configuration via Pydantic Settings.
- Supabase PostgreSQL connection.
- Supabase JWT verification.
- User profile CRUD.
- Natal chart CRUD.
- pyswisseph-based chart calculation.
- Gemini client wrapper.
- Redis-backed AI rate limiting.
- AI Astrologer endpoint using stored chart context.

### Phase 2: Next.js Web MVP

Goal: ship the web onboarding-to-reading loop.

Deliverables:

- Next.js 14 App Router frontend.
- Tailwind design tokens.
- Supabase auth screens.
- Birth data onboarding.
- Chart reveal.
- Dashboard.
- AI Astrologer chat.
- Typed API client.
- Protected routes.

### Phase 3: Static Content and SEO

Goal: make acquisition pages indexable and cheap.

Deliverables:

- Daily horoscope pages.
- Sign profile pages.
- 144 sign-pair compatibility pages.
- Metadata, JSON-LD, sitemap, and canonical URLs.
- Scheduled static content generation.
- PostgreSQL persistence and Redis caching.

### Phase 4: Memory and Retention

Goal: make the AI Astrologer feel continuous.

Deliverables:

- Conversations and messages.
- Memory extraction.
- Embeddings and memory retrieval.
- Mood logs.
- Weekly mood/transit insights.

### Phase 5: Monetization

Goal: add payment after users have a reason to pay.

Deliverables:

- Stripe checkout.
- Stripe customer portal.
- Stripe webhooks.
- Subscription state mirrored to Supabase/PostgreSQL.
- Premium limits and premium-only gates.

### Phase 6: Growth

Goal: expand after activation, retention, and monetization are measurable.

Candidate features:

- Share cards.
- Tarot hub.
- Deeper synastry.
- Smart notifications.
- Mobile rewrite.
- Internationalization.

## MVP Success Criteria

MVP is successful when:

- A user can sign up, enter birth data, and save a natal chart.
- The backend stores Sun, Moon, Ascendant when birth time is known, planets, houses, and aspects.
- The AI Astrologer answers with chart-specific context using Gemini 2.5 Flash.
- Free users are limited to 3 AI messages/day.
- Premium users are limited to 50 AI messages/day.
- Public SEO pages exist for daily horoscopes, sign profiles, and sign-pair compatibility.
- No secrets are committed to source control.
- API and frontend types match the documented contracts.

