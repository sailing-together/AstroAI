# AstroAI — Expert Team Decisions: Old vs New

> Produced by expert panel review (June 2026).  
> Each section states the **OLD solution** (what exists today), the **NEW solution** (what we're building), the **verdict**, and the **priority**.

---

## 🚨 P0 — Do Before Anything Else

| Issue | Old (Current State) | New (Fix) |
|---|---|---|
| **API key exposed** | Gemini key hardcoded as plain string in `backend/services/horoscope_gemini.py`, `compatibility_gemini.py`, `with_celebrity_gemini.py` — may already be in git history | Move to `.env`, use Pydantic Settings, add `.env` to `.gitignore`, rotate the key immediately |

**This must be done before any other code change. If the repo is or was ever public, rotate the key now.**

---

## 1. Frontend

| Dimension | 🔴 OLD — Flutter Web | 🟢 NEW — Next.js 14 | Verdict |
|---|---|---|---|
| SEO & organic discovery | ❌ None. Canvas rendering — no DOM, no indexable text | ✅ SSR/SSG — sign pages, compatibility pages fully indexed | **NEW wins** |
| Share cards / viral mechanic | ❌ Not possible from canvas | ✅ `@vercel/og` — portrait (1080×1920 TikTok) + landscape (1200×630 link) | **NEW wins** |
| Development speed | Flutter/Dart — smaller talent pool | Next.js/React — largest web ecosystem | **NEW wins** |
| Mobile (iOS + Android) | ✅ Flutter iOS app exists and works | React Native (Expo) — share types with web | Keep Flutter iOS until Expo ships |
| Performance & UX | Slow initial load, poor Lighthouse scores | Fast SSR, excellent Core Web Vitals | **NEW wins** |
| Cost to run | Free (static files) | Vercel free tier covers early stage | Equal |

**Decision: Migrate web to Next.js. Keep Flutter iOS in App Store until Expo version is shipped and stable. Flutter macOS = abandon.**

---

## 2. Database

| Dimension | 🔴 OLD — SQLite | 🟢 NEW — PostgreSQL (Supabase) | Verdict |
|---|---|---|---|
| Concurrent writes | ❌ Single writer — will corrupt under load | ✅ Full ACID, concurrent safe | **NEW wins** |
| User identity & auth | ❌ No user table, no sessions | ✅ Supabase Auth (magic link + Google OAuth) + users table | **NEW wins** |
| Personalization capability | ❌ Impossible — no persistent user data | ✅ Natal chart, memory, mood logs all persisted per user | **NEW wins** |
| Row-level security | ❌ None | ✅ Supabase RLS — users can only see their own data | **NEW wins** |
| Vector search (memory) | ❌ Not possible | ✅ pgvector extension — semantic memory retrieval | **NEW wins** |
| Migration difficulty | — | Low — current data volume is tiny | Easy |

**Decision: Migrate to Supabase PostgreSQL. This is Sprint 2 (after API key fix and caching).**

---

## 3. Background Jobs

| Dimension | 🔴 OLD — APScheduler | 🟢 NEW — Celery + Redis | Verdict |
|---|---|---|---|
| Reliability | ❌ Runs inside FastAPI process — jobs die if server restarts | ✅ Separate worker process, survives server restarts | **NEW wins** |
| Job pattern | ❌ Scheduler makes HTTP calls back to its own API to trigger work (fragile, circular) | ✅ Tasks called directly as Python functions | **NEW wins** |
| Failure handling | ❌ Silent failures — no retry, no logging | ✅ Automatic retries, dead-letter queue, Flower dashboard | **NEW wins** |
| Ops complexity | Simple — no extra services | Requires Redis + worker process | OLD simpler |

**Decision: Migrate to Celery + Redis. This is Sprint 4 — not breaking anything today, but required before nightly batch generation.**

---

## 4. AI Strategy

| Dimension | 🔴 OLD — Gemini only, on-demand | 🟢 NEW — Pre-generated + routed | Verdict |
|---|---|---|---|
| Horoscope generation | 6 sequential Gemini calls per user per page load | 1 batch call/sign/night → served from DB/cache | **NEW wins** |
| Personalization | ❌ Generic "you are an Aries" — no natal chart in prompt | ✅ Full natal chart + transits + memory loaded into every AI Astrologer call | **NEW wins** |
| Output format | ❌ Free-form text — fragile parsing | ✅ Structured JSON via Pydantic schemas | **NEW wins** |
| Memory / continuity | ❌ None — AI starts fresh every session | ✅ `ai_memories` table + pgvector semantic retrieval | **NEW wins** |
| Model routing | Single model (Gemini Flash) for everything | Gemini Flash for bulk content, Claude Sonnet for AI Astrologer | **NEW wins** |
| Safety guardrails | ❌ None | ✅ Built into AI Astrologer system prompt | **NEW wins** |
| Prompt versioning | ❌ Inline strings in service files | ✅ Versioned registry in `backend/prompts/`, A/B testable | **NEW wins** |

### Cost comparison at 1,000 DAU

| | Old | New |
|---|---|---|
| Horoscope calls | ~2,000 Gemini calls/day (6 calls × ~330 users loading horoscope) | 12 calls/night (batch, regardless of user count) |
| AI Astrologer | ~0 (feature doesn't exist yet) | ~300 calls/day (free tier: 3/day cap) |
| **Estimated daily cost** | **~$2.30/day (~$69/month)** | **~$0.68/day (~$20/month)** |
| **At 100K DAU** | ~$230/day (scales linearly) | ~$6/day horoscopes + pay-per-use AI Astrologer |

**70% cost reduction at 1K DAU. ~38× cheaper at 100K DAU.**

**Decision: New AI strategy wins completely. Highest ROI change is collapsing 6 calls → 1 + Redis cache (can be done this week, zero infrastructure change needed).**

---

## 5. Ephemeris (Astrological Calculations)

| | 🔴 OLD — `flatlib` | 🟢 NEW — `pyswisseph` |
|---|---|---|
| Maintenance status | ❌ Unmaintained (last commit 2019) | ✅ Actively maintained |
| Accuracy | Basic | Swiss Ephemeris standard — industry gold standard |
| Python 3.11+ compatibility | ❌ Breaks on newer Python | ✅ Full compatibility |
| Cost | Free | Free |

**Decision: Replace flatlib with pyswisseph. Low risk, do it in Sprint 2 alongside database migration.**

---

## Implementation Priority Order

### 🚨 This Week — P0 (Security)
- [ ] Rotate the hardcoded Gemini API key
- [ ] Move all secrets to `.env` + Pydantic Settings
- [ ] Add `.env` to `.gitignore`, add `.env.example`

### Sprint 1 — Highest ROI, No Infrastructure Change
- [ ] Collapse 6 sequential Gemini calls → 1 structured JSON call per sign
- [ ] Add Redis caching (Upstash free tier) for horoscope responses (key: `horoscope:{sign}:{focus}:{date}`, TTL 24h)
- [ ] Scaffold Next.js frontend in `frontend/nextjs/`
- [ ] Set up Supabase project (free tier)

### Sprint 2 — Foundation
- [ ] Migrate SQLite → Supabase PostgreSQL
- [ ] Add Supabase Auth (magic link + Google OAuth)
- [ ] Build `users` + `natal_charts` tables + API
- [ ] Replace flatlib → pyswisseph
- [ ] Migrate Flutter web pages → Next.js (public pages first for SEO)

### Sprint 3 — AI Core
- [ ] Build AI Astrologer endpoint with natal chart context loading
- [ ] Set up `ai_memories` table + vector embeddings (pgvector)
- [ ] Add prompt registry (`backend/prompts/`)
- [ ] Add Claude Sonnet routing for AI Astrologer
- [ ] Implement rate limiting (free: 3 calls/day, premium: 50/day)

### Sprint 4 — Infrastructure
- [ ] Migrate APScheduler → Celery + Redis Beat
- [ ] Build nightly batch generation jobs (72 horoscopes, cosmic events)
- [ ] Ship Expo mobile app (replaces Flutter iOS long-term)

### Sprint 5 — Monetization
- [ ] Stripe subscriptions (free trial + premium)
- [ ] Tarot Hub (daily draw, three-card, Tarot + Astrology Fusion)
- [ ] Mood tracking + planetary correlation
- [ ] Share card generation (`/api/og`)

---

## What We're Keeping From the Old Stack

| Component | Keep? | Reason |
|---|---|---|
| FastAPI framework | ✅ Yes | Solid choice, no reason to change |
| Existing backend logic (horoscope, compatibility, natal chart) | ✅ Refactor, don't rewrite | Port the prompt logic into the new prompt registry |
| Flutter iOS app | ✅ Temporarily | Keep in App Store until Expo version ships |
| Gemini API | ✅ Yes (Flash model) | Bulk content generation, cost-efficient |

## What We're Replacing

| Component | Replace With | When |
|---|---|---|
| Flutter Web | Next.js 14 | Sprint 1 |
| SQLite | PostgreSQL (Supabase) | Sprint 2 |
| APScheduler | Celery + Redis | Sprint 4 |
| flatlib | pyswisseph | Sprint 2 |
| Hardcoded API keys | `.env` + Pydantic Settings | **This week** |
| 6 sequential Gemini calls | 1 structured JSON call + Redis cache | Sprint 1 |
| Generic prompts | Natal chart–grounded prompts + prompt registry | Sprint 3 |
