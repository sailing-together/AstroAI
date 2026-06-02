# 🌌 AstroAI – Product & Design Document

> **Last updated:** June 2026 — revised based on expert strategy review

---

## 🎯 Vision & Positioning

**AstroAI is an AI companion who happens to speak astrology — not an astrology app that happens to have AI.**

The core insight: every competitor gives generic horoscopes based on your sun sign. AstroAI's moat is the **natal chart as a persistent identity layer** — an AI that knows *your* chart, remembers your life events, and connects them to cosmic timing in a way that feels like a therapist who also happens to be an astrologer.

> *"Your Mars return is next week — that's why you've felt this restlessness since Tuesday."*

That specificity creates switching costs no generalist app can match. The data flywheel is the moat: more self-reported mood/life events correlated with transits → better predictions → harder to leave.

### Who We're Building For

**Primary persona:** Women 22–35 who already pay for therapy or journaling apps (Jour, Day One), follow astrologers on TikTok, and use therapy language. They don't want a horoscope — they want permission to make the decision they're already leaning toward, framed cosmically.

**The daily hook:** A morning push notification — *"Your Moon is conjunct Jupiter today — this is your window."* She opens the app, asks the AI one question about her situation, and feels seen. That loop — open, ask, feel understood, close — is the entire product.

---

## 🏆 Competitive Positioning

| App | Positioning | Gap |
|---|---|---|
| Co-Star | Minimalist, social, Gen Z | Generic, no real personalization |
| The Pattern | Personality/behavioral psychology | No astrology depth, acquired by Snap |
| Sanctuary | Human astrologers + AI | Expensive, not scalable |
| Nebula | Broad features, aggressive upsells | Churn-heavy, feels exploitative |
| **AstroAI** | **AI companion grounded in your natal chart + memory** | **Our lane** |

---

## 🌟 Feature Set

### Priority Tier 1 — Core (Build First)

#### 🔑 Natal Chart Identity Layer
The foundation everything else builds on. Every personalized feature requires this.
- Onboarding: collect date/time/place of birth, support "unknown time" option
- Full natal chart calculation (Sun, Moon, Ascendant, all planets + houses)
- Persisted to user account — this is the user's identity in the app
- Chart wheel visualization

#### 🤖 AI Astrologer Assistant
The primary differentiator. This is the paywall anchor.
- Natural language Q&A grounded in *your* natal chart + current transits
- Context-aware: knows your placements, asks follow-up questions
- Guardrails for accuracy, positivity, and emotional safety
- Unlimited in premium tier; 3 questions/day in free tier

#### 🧠 Memory Layer *(the asymmetric bet)*
No astrology app has done longitudinal personalization. This is the moat.
- Remembers what you told it (job interviews, relationship events, big decisions)
- Connects past events to cosmic timing retrospectively
- *"You mentioned feeling stuck when Saturn squared your Sun — it stations direct next week."*
- Drives daily active usage and emotional attachment

#### 📅 Smart Notifications & Planetary Events
- Real-time planetary transit alerts relevant to *your* chart
- Mercury retrograde, lunar phases, eclipse alerts
- Critical timing nudges (*"Avoid signing contracts — Mercury retrograde starts Thursday"*)
- Daily cosmic weather relevant to your natal placements
- Quiet hours / do-not-disturb support

#### 🗓️ Personal Cosmic Insights
- Daily, weekly, monthly horoscopes — grounded in natal chart, not just sun sign
- Focus areas: Love, Career, Wealth, Wellness, Guidance, Motivation
- Today's Cosmic Events with personalized interpretations

---

### Priority Tier 2 — Growth (Phase 2)

#### 🃏 Tarot Hub
Tarot extends the AI's daily engagement surface — the "ask a question, draw a card" mechanic is a natural AI prompt interface.
- Daily Tarot Draw (one-card guidance)
- Three-card Spreads (past–present–future, love/career focus)
- **Tarot + Astrology Fusion** *(differentiator)* — AI blends drawn cards with natal chart + current transits
- Tarot Journal: save draws, track recurring themes, reflection insights
- Tarot Oracle Mode: ask a question → AI interprets cards in context of your chart
- Advanced Spreads (Celtic Cross, Relationship, Career) — premium only

#### 📊 Mood Tracking & Planetary Correlation *(differentiator)*
No competitor executes this well.
- Log daily mood/energy (quick 10-second entry)
- AI surfaces patterns: *"3 out of 4 times you felt anxious, Mars was squaring your Moon"*
- Emotional data feeds back into AI Astrologer context
- Weekly mood + transit digest

#### 💞 Compatibility & Relationships
- Compatibility Matching: Love, Family, Friends, Business, General
- Results: Compatibility score + 2 Strengths + 2 Watch-outs
- Synastry chart overlay (premium)
- Business Partnership Synergy

#### 🎭 Engagement & Fun Tools
- Personality Quizzes (zodiac archetypes, self-discovery)
- Zodiac Sign Insights (archetype overview, current year, 12-month breakdown)
- Daily Lucky Numbers & Energy Colors *(free tier, drives DAU)*

---

### Priority Tier 3 — Expansion (Future)

#### ✨ ASMR & Meditation Suite
*Deprioritized: ASMR is a separate retention loop from astrology. Ship only after core is proven.*
- Zodiac ASMR Channels (12 zodiac-themed sound experiences)
- Guided Cosmic Meditations
- Sleep & Background Mode
- Custom Sound Mixing (premium)

#### 🌐 Community & Connection
*Deprioritized: community moderation is a full product in itself.*
- Star-matched Chat System
- Anonymous Zodiac-based Matching
- Community Discussions
- Moderation & Safety infrastructure

#### 🔮 Advanced Features
- Celebrity Matching
- Daily Sound Oracle Readings
- Voice-activated Features
- Wearable / Device Integration (watch, earbuds, AR glasses)
- Agentic AI Workflows (*"Plan my week"*, proactive wellbeing nudges)
- Partnership Ecosystem (counsellors, wellbeing content, travel recs)

---

## 📤 Viral Growth Loop

The growth loop is **shareable AI readings**, not compatibility tests (Co-Star's saturated mechanic).

1. AI produces an uncannily specific, personal reading about a user's week
2. User screenshots it — build reading cards to be **screenshot-native** from day one
3. She posts to TikTok / Instagram Stories
4. Followers download to get their own reading
5. Deep onboarding (natal data collection) turns installs into invested users

**Acquisition channels:**
- Organic: share cards + TikTok/Reels virality
- Paid: TikTok/Meta targeting spirituality + wellness audiences at ~$1–2 CPI
- SEO: Next.js server-rendered pages for "Aries compatibility with Scorpio", "natal chart calculator", "Mercury retrograde 2026" — high intent, high volume

---

## 💰 Monetization

### Model: Subscription-First

| Tier | Price | What's Included |
|---|---|---|
| Free | $0 | Daily sun-sign horoscope, one-card Tarot draw, basic compatibility score, zodiac overview, lucky numbers |
| Premium | $9.99/mo or $59.99/yr | Everything — AI Astrologer (unlimited), natal chart personalization, full Tarot spreads, mood tracking, smart notifications, memory layer, advanced compatibility |

**Paywall anchor:** The AI Astrologer. Everything personalized to your natal chart is premium. Generic = free; "just for me" = paid.

**Conversion target:** 4–6% free-to-paid. Below 3% means the free tier is too generous.

**Annual push:** Annual subscriptions have 3x lower churn than monthly. Make annual the primary CTA with a free trial.

### Path to $1M ARR

~10,000 paying users at ~$8.50 blended monthly ARPU.

Funnel: 200,000 installs → 40% activation (complete onboarding with natal data) → 5% paid conversion = ~4,000 subscribers. Scale from there with virality + paid acquisition.

**Churn target:** Keep monthly churn below 8%. The memory layer is the primary retention mechanic — the longer a user is in the app, the more the AI knows about them, the harder it is to leave.

### Content Bundles (Phase 2)
- Love Bundle, Career Bundle, Wellness Bundle
- One-time purchases as upsell / acquisition wedge

### B2B Angle (Explore Post-$500K ARR)
Team astrology / personality insights for HR/people ops. "Myers-Briggs meets cosmic compatibility for team dynamics." ~$15/user/month, 50-seat minimum = $750/account. Low engineering lift once core product is built.

### Deprioritized Revenue Lines
- **Celebrity voice collaborations** — expensive rights ($50–100K), short shelf life, undermines AI positioning. Use post-Series A as a growth stunt only.
- **Daily Sound Oracle as standalone paid feature** — bundle into premium instead; standalone WTP is thin.

---

## 🚀 Roadmap

### ✅ MVP (Done)
- Zodiac Sign Insights (overview, year, 12-month)
- Personal Cosmic Insights (daily Love, Career, Wealth, Wellness, Guidance, Motivation)
- Compatibility Matching (score + strengths + watch-outs)
- Celebrity Matching
- Today's Cosmic Events
- Natal Chart Analysis (basic wheel + Sun/Moon/Ascendant summary)

---

### 🔜 Phase 1 — Core AI Companion (0–3 months)
**Goal:** Make the AI Astrologer world-class. Everything else is secondary.

- [ ] **User Identity & Auth** — Supabase auth (magic link + Google OAuth), persistent user record
- [ ] **Natal Chart Data Model** — persisted chart storage, full planet/house positions
- [ ] **Onboarding v2** — birth data collection, ToS/Privacy flow, "unknown time" support
- [ ] **AI Astrologer v1** — natal chart context loaded into every prompt, natural language Q&A
- [ ] **Memory Layer v1** — store user-reported events, surface connections to transits
- [ ] **Smart Notifications** — real transit alerts, personalized to natal chart, quiet hours
- [ ] **Planetary Transits** — live ephemeris data, retrograde + lunar alerts
- [ ] **Share Cards** — screenshot-native reading visuals, social-ready export
- [ ] **Analytics** — activation funnel, feature engagement, retention cohorts

---

### 🌱 Phase 2 — Growth & Monetization (3–6 months)
- [ ] **Stripe Subscriptions** — free trial + premium tier, annual CTA
- [ ] **Tarot Hub** — daily draw, three-card spreads, Tarot + Astrology Fusion, Tarot Journal
- [ ] **Mood Tracking** — daily log, planetary correlation engine, weekly digest
- [ ] **Compatibility Depth** — synastry overlay, business synergy
- [ ] **Memory Layer v2** — retrospective pattern surfacing, longitudinal AI context
- [ ] **Content Bundles** — Love, Career, Wellness one-time purchases

---

### 🌠 Phase 3 — Expansion (6–12 months)
- [ ] Advanced Tarot Spreads (Celtic Cross, Relationship, Career)
- [ ] ASMR & Meditation Starter (3–6 tracks, guided meditations, background mode)
- [ ] Internationalization (multilingual support)
- [ ] B2B pilot (team insights, HR/people ops)
- [ ] Voice-activated Features

---

### 🔭 Future
- Full ASMR library + Custom Sound Mixing
- Community & Connection (chat, zodiac matching, discussions)
- Agentic AI Workflows (*"Plan my week"*, proactive rituals)
- Wearable / Device Integration
- Partnership Ecosystem
- Celebrity Voice Collaborations (post-Series A)

---

## 🔧 Technical Implementation

> See **[ARCHITECTURE.md](./ARCHITECTURE.md)** for full technical detail.

### Stack Summary

| Layer | Technology |
|---|---|
| Web Frontend | Next.js (App Router) + Tailwind CSS |
| Mobile | React Native (Expo) |
| Backend API | FastAPI (Python) |
| Database | PostgreSQL via Supabase |
| Auth | Supabase Auth (magic link + Google OAuth) |
| Cache | Redis (Upstash) |
| Job Queue | Celery + Redis |
| AI — Content | Gemini Flash (horoscopes, daily content) |
| AI — Assistant | Claude Sonnet (natal chart analysis, AI Astrologer) |
| Ephemeris | pyswisseph (Swiss Ephemeris) |
| Payments | Stripe Billing |
| Notifications | Firebase Cloud Messaging |
| File Storage | Cloudflare R2 (ASMR audio, future media) |

### Key Design Principles

0. **Static first, AI last** — anything that doesn't require individual user context is pre-generated nightly and stored in the database. AI API calls are reserved exclusively for personalized, interactive, real-time scenarios (AI Astrologer chat, natal chart interpretation, memory synthesis). This minimizes cost, reduces latency, and eliminates exposure of raw API keys to the request path. See ARCHITECTURE.md for the full data classification.
1. **Natal chart as the context layer** — every AI call is pre-loaded with the user's chart data and relevant transits. Generic responses are a product failure.
2. **Prompt architecture over prompt strings** — all prompts versioned in a `prompts/` registry with Pydantic response schemas. Enables A/B testing and quality measurement.
3. **Cache aggressively** — daily horoscopes are deterministic by sign + date. Cache at Redis with 24h TTL. One structured JSON call per prompt, not N+1 calls.
4. **SEO as primary growth channel** — Next.js SSR for all sign/compatibility/event pages. Server-rendered structured data for high-intent search queries.
5. **User identity first** — auth and natal chart persistence unblock every other feature. Build this before anything else in Phase 1.

### Security
- All API keys via environment variables (never in source code)
- GDPR/CCPA compliance: minimal data collection, transparent privacy flow in onboarding
- Encryption at rest for natal chart + personal event data
- Rate limiting on AI endpoints via Redis
