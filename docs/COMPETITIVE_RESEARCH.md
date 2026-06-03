# AstroAI Competitive Research

> Status: Working competitive positioning notes.
> Last updated: 2026-06-03

## Purpose

This document records product strategy lessons from current astrology and spiritual guidance competitors. It should guide AstroAI's roadmap, not duplicate implementation details from `PRODUCT.md`, `FRONTEND_SPEC.md`, or `API_SPEC.md`.

## Competitor Map

| Competitor | Apparent strength | Monetization pattern | Strategic lesson for AstroAI |
|---|---|---|---|
| Co-Star | Minimal daily habit, strong cultural brand, chart-based social comparison | Subscription and paid deep-dive features | A daily astrology product needs a memorable habit loop, but cryptic copy alone is not enough differentiation. |
| The Pattern | Relationship dynamics, pattern language, compatibility/bonds, AI conversation feature | Premium relationship and deeper insight subscriptions | Relationship interpretation is a strong retention surface; users value language that helps them understand patterns, not only predictions. |
| CHANI | Trusted editorial voice, daily horoscopes, birth chart, mindfulness, rituals, transit education | Free app plus premium content | A calm, high-trust voice and practical rituals can differentiate more than feature volume. |
| Sanctuary | Human astrologer/psychic/tarot live readings layered on horoscope content | Paid live readings and subscription unlocks | Human expert access is premium, but it is costly and operationally heavy; AstroAI should not copy this in MVP. |
| Nebula | Broad spiritual marketplace: astrology, psychic chat, compatibility, daily rituals | Subscription, upsells, paid readings | Too many paid spiritual services can create confusion and trust risk; AstroAI should stay clearer and more chart-grounded. |
| TimePassages | Serious chart, transit, synastry, and progression tools with astrologer-written interpretations | Free basics plus paid pro/deeper tools | Technical credibility matters; deterministic chart/transit calculation can be a trust moat when explained well. |

## Market Patterns

- Free daily horoscope content is table stakes.
- Birth chart and basic daily guidance are commonly free or low-friction.
- Premium value usually comes from deeper personalization, relationship insights, forecasting, human readings, or unlimited advanced reports.
- Users are sensitive to generic content, hidden subscriptions, unsafe payment patterns, and vague AI claims.
- The strongest products have a distinct voice: Co-Star is blunt/minimal, CHANI is nurturing/ritual-oriented, The Pattern is psychological/relational, TimePassages is technical/astrologer-led.

## AstroAI Differentiation

AstroAI should position around **chart-grounded AI guidance with transparent static content economics**.

Core differences:

- Public users get free yearly, monthly, weekly, and daily sign-based content without registration and without live AI cost per read.
- Registered users unlock natal-chart-based interpretation and AI chat, not just longer generic horoscopes.
- The system should clearly separate deterministic calculations, pre-generated static content, and paid/on-demand AI personalization.
- The product voice should be practical, warm, and reflective rather than cryptic, alarmist, or overly mystical.
- AstroAI should avoid looking like a psychic marketplace in MVP; that market is crowded and has trust concerns.

## Strategic Positioning

Short positioning:

> AstroAI is a practical astrology companion that gives everyone free static horoscope guidance, then upgrades registered users into chart-grounded AI interpretation when personalization truly matters.

Positioning pillars:

1. **Free public utility:** No-login sign and date-based horoscope browsing.
2. **Transparent personalization:** Explain when content is static, chart-calculated, or AI-generated.
3. **Chart-first credibility:** Natal chart calculation and transits should be deterministic foundations.
4. **Memory with consent:** Personalized AI should improve through saved context only after registration and consent.
5. **Calm premium path:** Premium should unlock depth, continuity, and saved insights, not pressure users with manipulative upsells.

## Product Implications

- The final public UI should not look like a backend tester or a generic horoscope blog.
- The free layer should feel generous enough to build trust, but clearly sign-based rather than deeply personal.
- The AI layer should be framed as an upgrade for personal context: birth chart, life question, mood, relationship, or timing.
- Compatibility and relationship insights are likely a high-value post-MVP path because competitors show strong demand there.
- CHANI and TimePassages suggest credibility comes from explaining astrology, not just predicting outcomes.
- Nebula and live-reading marketplaces suggest AstroAI should be cautious with psychic/tarot expansion until trust, billing, and core astrology loops are stable.

## Roadmap Influence

Near-term:

- Keep building public static horoscope APIs and a developer preview.
- Design the real public horoscope page around today's guidance, selected date, matching week, month, and year.
- Add clear labels in production UI for static vs personalized content.

MVP:

- Build auth, natal chart, saved profile, and AI Astrologer as the first paid/personalized loop.
- Use deterministic chart output as the AI context source.
- Avoid adding psychic marketplace, community matching, ASMR, or large spiritual-tool bundles before core retention is proven.

Post-MVP:

- Add relationship/compatibility depth after the chart and AI chat loop works.
- Explore mood/transit journaling as a memory and retention layer.
- Consider paid annual reports or month-by-month personalized forecasts after users trust the daily experience.

## Sources Reviewed

- Co-Star official site: https://www.costarastrology.com/
- The Pattern official site: https://www.thepattern.com/
- CHANI official app page and help center: https://www.chani.com/app
- Sanctuary Google Play/App Store listings and FAQ: https://play.google.com/store/apps/details?id=com.sanctuaryworld.sanctuaryandroid
- Nebula / AskNebula pages and app listings: https://www.asknebula.com/about-us
- TimePassages App Store listing: https://apps.apple.com/us/app/timepassages-astrology/id488946918
