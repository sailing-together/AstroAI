# AstroAI Product Source of Truth

> Status: Canonical product direction for the AstroAI redevelopment.
> Last updated: 2026-06-03

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

See `COMPETITIVE_RESEARCH.md` for the working competitor map. Current positioning should emphasize AstroAI as a practical, chart-grounded AI companion with a generous static free layer and transparent separation between static content, deterministic chart calculation, and paid/on-demand AI personalization.

## Product Access Layers

### 1. Free Public Layer

No registration required.

Users can choose a zodiac sign manually, or enter a birth date to calculate their Sun sign. They can then view the selected sign's yearly, monthly, weekly, and daily horoscope bundle for the current year, plus public sign profiles and public sign-pair compatibility pages.

Rules:

- Public horoscope reads do not call Gemini.
- Public horoscope reads use pre-generated PostgreSQL/Redis content.
- Birth-date-to-Sun-sign calculation does not call Gemini.
- The frontend should load a sign's current-year horoscope bundle with one backend API request.

### 2. Registered Foundation Layer

Registration required.

Users can save their profile, enter birth date/time/place, generate and save a natal chart, and view a basic natal chart summary.

Rules:

- Natal chart calculation is deterministic and does not call Gemini.
- Use `pyswisseph` for chart calculation.
- AI-generated chart interpretation is separate from chart calculation.

### 3. AI Personalized Layer

Registration required. Pricing is not finalized.

Features include AI Astrologer chat, AI natal chart interpretation, personalized predictions using natal chart/current transits/stored context, deeper compatibility analysis, tarot + astrology fusion, and memory/mood insights.

Rules:

- These features may call Gemini.
- These features must be rate-limited.
- Free registered users may receive limited AI usage.
- Premium users may receive higher AI limits.

## MVP Scope

Build first:

- Supabase authentication.
- Birth data onboarding.
- Natal chart calculation and persistence.
- Natal chart summary.
- AI Astrologer chat.
- Daily AI message limits.
- Public horoscope bundle API for no-login users.
- Birth-date-to-Sun-sign utility for no-login users.
- Public yearly, monthly, weekly, and daily horoscope pages.
- Public sign profile pages.
- Public sign-pair compatibility pages.
- Static horoscope generation jobs that store public content before users request it.

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

### Phase 1.5: Public Static Horoscope Engine

Goal: provide useful no-login astrology content without spending live AI calls on page views.

Deliverables:

- Static yearly horoscope generation for each sign, updated once per year.
- Static monthly horoscope generation for each sign, updated once per month.
- Static weekly horoscope generation for each sign, updated once per week.
- Static daily horoscope generation for each sign, updated every day at 00:00.
- Annual bulk generation that can preload the year's yearly, 12 monthly, all weekly, and all daily horoscope content for every sign.
- Manual annual regeneration trigger for refreshing a year's public horoscope library when needed.
- One generation call per sign and period that returns all horoscope dimensions together.
- PostgreSQL persistence and Redis caching for generated horoscope content.
- Public API reads that return stored content only.

Supported public horoscope dimensions:

- General
- Love and relationships
- Career and work
- Wealth and money
- Health and wellness
- Social life
- Family and home
- Study and personal growth
- Mood and energy

### Phase 2: Next.js Public Web Entry

Goal: ship the no-login public acquisition experience.

Deliverables:

- Next.js 14 App Router frontend.
- Tailwind design tokens.
- Public sign selection.
- Birth-date-to-Sun-sign form.
- One-request current-year horoscope bundle loading.
- Public yearly, monthly, weekly, and daily horoscope views.
- Public sign profile pages.
- Public sign-pair compatibility pages.
- SEO metadata, JSON-LD, sitemap, and canonical URLs.

### Phase 3: Registered Natal Chart Experience

Goal: ship the registered user's deterministic chart foundation.

Deliverables:

- Supabase auth screens.
- Birth data onboarding.
- Chart reveal.
- Dashboard.
- Natal chart summary.
- Typed API client.
- Protected routes.

### Phase 4: AI Personalized Experience

Goal: add registered AI features after the public and deterministic foundations work.

Deliverables:

- AI Astrologer chat.
- AI natal chart interpretation.
- Personalized predictions using natal chart and current transits.
- AI usage limits.
- Upgrade prompts when pricing is decided.

### Phase 5: Memory and Retention

Goal: make the AI Astrologer feel continuous.

Deliverables:

- Conversations and messages.
- Memory extraction.
- Embeddings and memory retrieval.
- Mood logs.
- Weekly mood/transit insights.

### Phase 6: Monetization

Goal: add payment after users have a reason to pay.

Deliverables:

- Stripe checkout.
- Stripe customer portal.
- Stripe webhooks.
- Subscription state mirrored to Supabase/PostgreSQL.
- Premium limits and premium-only gates.

### Phase 7: Growth

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
- Public SEO pages exist for yearly, monthly, weekly, and daily horoscopes, sign profiles, and sign-pair compatibility.
- Public horoscope page views read stored static content and do not trigger live Gemini calls.
- No secrets are committed to source control.
- API and frontend types match the documented contracts.
