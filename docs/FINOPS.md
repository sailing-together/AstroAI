# AstroAI FinOps and AI Spend Guardrails

> Status: Canonical cost-control policy for MVP development and launch.
> Last updated: 2026-06-27

AstroAI is currently an acquisition-first product. The public layer should bring users in, build trust, and prove demand before the product has meaningful revenue. Because of that, MVP infrastructure must assume that traffic can spike before monetization exists.

The total variable AI and cloud spend ceiling for the MVP is **100 AUD** unless the founders explicitly raise it.

## Operating Principles

1. Public acquisition traffic must be near-zero marginal cost.
2. Anonymous page views must never trigger live AI calls.
3. Live AI must require authentication, quota checks, rate limits, and usage logging.
4. Batch AI generation must be bounded, reviewable, and stoppable.
5. Production should fail closed on AI spending and fail open on static deterministic reads.
6. Every paid provider call must be attributable to a feature, user or batch job, model, and estimated cost.

## Spend Limit

| Limit | Value |
|---|---:|
| MVP total variable AI/cloud spend cap | 100 AUD |
| Public anonymous live AI calls | 0 |
| Free registered live AI messages | 3/day |
| Premium registered live AI messages | 50/day |

When estimated total MVP spend reaches or exceeds 100 AUD:

- Disable live AI calls.
- Disable batch AI generation.
- Keep deterministic chart calculation online.
- Keep public static horoscope reads online.
- Keep authentication and profile access online if infrastructure allows.
- Show a graceful quota or maintenance message for AI features.

## Feature Cost Policy

| Feature | Auth | Live AI allowed | Cost rule |
|---|---|---|---|
| Public horoscope page view | No | No | PostgreSQL/Redis/static only |
| Public sign profile page view | No | No | PostgreSQL/Redis/static only |
| Public compatibility page view | No | No | PostgreSQL/Redis/static only |
| Birth-date-to-Sun-sign utility | No | No | Deterministic only |
| Natal chart calculation | Yes | No | Deterministic `pyswisseph` only |
| Natal chart interpretation | Yes | Yes | Quota, rate limit, cache by chart hash |
| AI Astrologer chat | Yes | Yes | Quota, rate limit, usage meter |
| Personalized guidance | Yes | Yes | Quota, rate limit, usage meter |
| Static content generation | Operator | Batch only | Explicit job, capped batch size, usage meter |

Public pages are for growth. They must read existing content and never create a provider-cost loop from anonymous traffic.

## Runtime Kill Switches

Backend configuration should include these switches before production AI usage:

```env
AI_CALLS_ENABLED=false
PUBLIC_AI_CALLS_ENABLED=false
STATIC_GENERATION_AI_ENABLED=false
AI_SPEND_LIMIT_AUD=100
AI_KILL_SWITCH_ON_LIMIT=true
```

Rules:

- `PUBLIC_AI_CALLS_ENABLED` must stay `false` for MVP.
- `AI_CALLS_ENABLED=false` blocks user-triggered live AI.
- `STATIC_GENERATION_AI_ENABLED=false` blocks scheduled and manual batch generation.
- When `AI_KILL_SWITCH_ON_LIMIT=true`, reaching `AI_SPEND_LIMIT_AUD` automatically disables both live AI and batch AI generation.
- Operators can keep static read APIs online while AI generation is disabled.

## Usage Meter

Every Gemini call should write a durable usage record before the response is considered complete.

Minimum fields:

| Field | Purpose |
|---|---|
| `user_id` | Nullable for operator batch jobs; required for live user AI |
| `feature` | Chat, chart interpretation, static generation, memory extraction, etc. |
| `tier` | `free`, `premium`, or `operator` |
| `model` | Exact Gemini model name |
| `input_tokens` | Provider-reported or estimated input tokens |
| `output_tokens` | Provider-reported or estimated output tokens |
| `estimated_cost_aud` | Cost converted to AUD for budget checks |
| `estimated_cost_usd` | Optional source-currency estimate |
| `request_status` | Success, blocked, failed, retried, cancelled |
| `created_at` | Timestamp used for daily and total spend windows |

Required dashboards or reports:

- Total AI spend in AUD.
- Daily AI spend.
- Free-user AI spend.
- Per-user AI spend.
- Per-feature AI spend.
- Failed and retry spend.
- Static generation batch spend.
- Remaining budget before the 100 AUD cap.

## Abuse Controls

Before production launch, AI endpoints must have:

- Auth requirement.
- Per-user quota.
- Per-IP rate limit.
- Per-endpoint rate limit.
- Request size limit.
- Retry cap.
- No user-controlled loop that can trigger repeated generation.
- No anonymous route that can call Gemini.

If the app receives 10,000 anonymous visits, the expected AI provider cost should remain 0 AUD.

## Bootstrap and Seed Data Policy

Development seed data can become production bootstrap content only after promotion. Raw `codex-dev` output is not automatically production content.

Promotion requirements:

1. Coverage validation passes for the target year, sign set, periods, and focus dimensions.
2. Visible copy is cleaned for user-facing language and contains no provider/debug wording.
3. A human spot review approves representative samples.
4. Records are marked with explicit provenance:
   - `source=bootstrap`
   - `content_version`
   - `review_status=approved`
5. The replacement plan is clear: bootstrap content can be regenerated, reviewed, and replaced by operator batch jobs later.

Production reads can use promoted bootstrap content. Production should not expose unreviewed development fixtures as if they were final editorial content.

## Local Model Policy

A local model running on a laptop can help with development, offline drafting, experimentation, or seed-copy review. It should not serve MVP production traffic.

Reasons:

- Laptop uptime is not production reliability.
- Abuse traffic still needs network, auth, quota, logging, and operator controls.
- User data privacy and observability are harder to guarantee on an ad hoc local runtime.
- The current cost risk is better reduced by static reads, quotas, and kill switches.

Local generation is acceptable for drafts that are later validated, reviewed, and promoted through the bootstrap policy.

## Implementation Priority

1. Add kill-switch configuration and default AI off in production-like environments.
2. Add usage-meter persistence for Gemini calls.
3. Enforce auth, quota, and rate limits before Gemini calls.
4. Block public anonymous AI calls at route and service boundaries.
5. Add spend-limit checks before live and batch AI.
6. Add an operator-visible daily spend report.
7. Promote reviewed static seed content only after validation.
