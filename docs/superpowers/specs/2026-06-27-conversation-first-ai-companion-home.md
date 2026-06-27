# Conversation-First AI Companion Home

> Date: 2026-06-27
> Status: Directional design spec for review
> Target product area: Registered AstroAI MVP

## Meeting Purpose

This document turns the latest product discussion into implementation guidance for AstroAI's registered experience.

The key shift is that AI changes how users consume astrology content. Users should not have to open separate modules, browse static content, and assemble meaning by themselves. AstroAI should let users ask directly, then retrieve the right chart, horoscope, transit, relationship, mood, memory, and static-content context to answer.

## Expert Meeting Conclusion

AstroAI should become a conversation-first, chart-grounded companion.

The public layer still matters for acquisition and utility. Public horoscope, sign profile, and compatibility pages help users discover AstroAI and get immediate value without registration. But the registered product should not become a directory of horoscope, chart, compatibility, mood, tarot, and course modules.

The registered product should make the AI Astrologer the primary surface. Modules become context sources, supporting tools, and deep dives.

## Product Principle

Users should not browse astrology modules to assemble meaning. AstroAI should let them ask directly, then retrieve the right chart, horoscope, transit, memory, and relationship context to answer.

This means:

- The logged-in home starts with a question box, not a feature grid.
- Suggested prompts should be personalized from the user's chart, current date, and recent context.
- Horoscope, natal chart, compatibility, mood, and learning surfaces should support the AI answer instead of competing with it.
- The product earns trust by being useful before it asks for payment.
- Paid value should deepen the relationship, not exploit anxiety.

## User Journey

### Public Entry

1. User lands on public horoscope, sign, compatibility, or SEO content.
2. User gets a useful free static reading without Gemini calls.
3. User sees a clear invitation to create a natal chart when they want personalization.

### Registered Foundation

1. User signs up.
2. User enters birth date, time, and place.
3. AstroAI calculates and saves the natal chart deterministically.
4. User lands on the companion home.

### Companion Loop

1. User asks AstroAI a natural question.
2. Backend assembles relevant context from chart, static horoscope, date, profile, memory, and recent interactions.
3. AI Astrologer answers and can recommend a reflection, exercise, reading, or saved follow-up.
4. User responds, saves, ignores, or completes the recommendation.
5. The system updates context signals for future answers.

## Companion Home Layout

### First View

The first authenticated view should answer: "What can I ask AstroAI right now?"

Required elements:

- AstroAI header with account and settings access.
- Personal greeting using safe profile data.
- Primary question box with a calm placeholder, such as "Ask about your chart, timing, mood, or relationships."
- Suggested prompts derived from current product state.
- Today's context strip:
  - Sun sign or primary chart summary.
  - Today's date and selected horoscope focus.
  - Remaining AI message quota.
- One compact chart identity module.

Avoid:

- A large marketing hero after login.
- A grid of equally weighted product modules.
- Tarot, mood, compatibility, or course cards competing with the AI question box in the first view.
- Claims that AstroAI remembers context that has not been saved or consented to.

### Suggested Prompts

Suggested prompts should be concrete, contextual, and emotionally useful.

Examples:

- "What should I pay attention to today?"
- "How does today's reading connect to my natal chart?"
- "Why do I keep returning to the same relationship question?"
- "What is a practical next step for my career this week?"
- "What pattern should I reflect on before I react?"

Prompt rules:

- Do not imply crisis diagnosis, medical care, or therapy.
- Do not use fear-based hooks.
- Do not make users feel a private memory exists unless it actually does.
- Prefer reflective, action-oriented wording.

### Secondary Surfaces

Below the first view, secondary surfaces can include:

- Natal chart summary.
- Daily guidance card.
- Recent AI Astrologer thread.
- Saved insights.
- Mood check-in.
- Compatibility or relationship prompt.
- Public horoscope deep link.

These surfaces should support the question loop. They should not be the primary navigation model.

## Context Layers

The AI Astrologer should treat product modules as context layers:

| Layer | Source | Role |
|---|---|---|
| Identity | Saved user profile and natal chart | Stable personalization base |
| Timing | Static horoscope, current date, future transits | Temporal guidance |
| Conversation | Recent AI Astrologer history | Continuity |
| Memory | User-approved summaries and recurring themes | Retention moat |
| Mood | Optional mood logs or check-ins | Emotional context |
| Relationships | User-provided relationship topics or compatibility data | Social context |
| Learning | Static explainers, exercises, and content library | Recommended next steps |

The frontend should not manually build prompts from these layers. The backend should own context assembly.

## Trust And Monetization

AstroAI should not monetize fear.

Do not use:

- "Something bad is around you; pay to unlock protection."
- "This relationship is dangerous; pay to reveal why."
- "Your chart shows a hidden threat; unlock now."
- Repeated paywalls before the user has received useful value.

Allowed paid value:

- Higher AI Astrologer daily limits.
- Deeper natal chart interpretation.
- Personalized yearly or monthly reports.
- Relationship reports.
- Voice reading or guided session.
- Saved history and long-term memory insights.
- Premium exercises or growth plans.

Free registered users should receive enough AI guidance to trust the companion. The current MVP limit remains `3` AI Astrologer messages per day for `free` and `50` for `premium`.

## Privacy And Safety Rules

Conversation-first does not mean unlimited memory collection.

Required:

- Explain what user context is saved.
- Allow users to delete or disable memory when memory features ship.
- Do not expose birth data, relationship details, mood logs, or memories in browser-visible secrets or logs.
- Do not present AstroAI as medical, psychological, legal, or financial care.
- Escalate serious self-harm or crisis language to appropriate support guidance when safety policies are defined.

## Backend Implications

The registered AI Astrologer needs a context pipeline:

1. Authenticate user.
2. Load profile and chart.
3. Load current static horoscope and date context.
4. Load recent conversation context.
5. Load approved memory summaries when available.
6. Enforce quota before live Gemini calls.
7. Compose prompt server-side.
8. Store response and safe context signals.

Expected backend boundaries:

- `services.context_builder` owns context assembly.
- `services.memory` owns extraction and retrieval.
- `core.rate_limit` gates live AI calls.
- `api.v1.chat` should accept the user message, not frontend-built prompts.

## Frontend MVP Acceptance

The first companion-home implementation is acceptable when:

- The first authenticated screen has a dominant Ask AstroAI input.
- Suggested prompts are visible without scrolling on desktop and early on mobile.
- The dashboard does not look like a module directory.
- The quota state is clear.
- Users without a natal chart are guided into onboarding before asking chart-specific questions.
- Module links exist as secondary routes only.
- Empty states explain what context is missing without implying hidden memory.

## Non-Goals For The First Companion PR

- Full memory extraction.
- Tarot, dream, or oracle-card agents.
- Voice sessions.
- Stripe paywall implementation.
- Clinical therapy positioning.
- Replacing public SEO pages.

## Next Recommended Implementation Slice

After this spec is accepted:

1. Create a protected `/dashboard` shell that follows this companion-home layout.
2. Add static suggested prompts based on chart/onboarding state.
3. Show quota placeholder from a typed API contract.
4. Link incomplete users into `/onboarding`.
5. Keep actual memory extraction and advanced personalization for later backend slices.
