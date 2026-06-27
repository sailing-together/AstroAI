# P3.2 FinOps and AI Spend Guardrails Design

> Status: Approved direction for the next backend safety slice.
> Last updated: 2026-06-27

## Problem

AstroAI is currently traffic-first and not yet revenue-first. Public horoscope pages may receive large anonymous traffic or abuse before monetization exists. If public page views, retries, or bot traffic can trigger live Gemini calls, a launch or attack could create unacceptable cost.

The MVP needs a hard operating rule: total variable AI/cloud spend must stay below 100 AUD unless founders explicitly raise the cap.

## Design Goals

- Keep public acquisition traffic near-zero marginal cost.
- Require auth, quota, rate limits, spend checks, and usage logging before live AI.
- Keep static and deterministic features available when AI is disabled.
- Make development seed data promotable to production only after validation and review.
- Provide a clear backend implementation path for kill switches and spend monitoring.

## Product Rules

Public pages are acquisition surfaces, not live-AI surfaces. Anonymous horoscope, zodiac, compatibility, and Sun-sign utility traffic must read static or deterministic data only.

Registered AI features can call Gemini only after the backend verifies:

1. AI calls are enabled.
2. The user is authenticated.
3. The feature allows live AI.
4. The user has remaining quota.
5. Rate limits pass.
6. The usage meter can write a record.
7. Estimated spend is below the configured cap.

If spend reaches 100 AUD, live AI and batch AI generation stop. Static reads, deterministic chart calculation, and account access should continue where infrastructure allows.

## Backend Components

### Configuration

Add production-safe defaults:

- `AI_CALLS_ENABLED=false`
- `PUBLIC_AI_CALLS_ENABLED=false`
- `STATIC_GENERATION_AI_ENABLED=false`
- `AI_SPEND_LIMIT_AUD=100`
- `AI_KILL_SWITCH_ON_LIMIT=true`

### Usage Meter

Record every Gemini call with user, feature, tier, model, token counts, estimated AUD cost, status, and timestamp. The usage meter becomes the source for dashboards, cap enforcement, and abuse investigation.

### Spend Gate

Before Gemini calls, check whether the feature is allowed and whether estimated total spend is still below the configured cap. When the cap is reached, block AI calls gracefully.

### Public Route Boundary

Public anonymous routes must never call Gemini. They should read PostgreSQL, Redis, static fixtures, or deterministic utilities only.

### Seed Promotion

`codex-dev` or development seed data can become production bootstrap data only after coverage validation, copy cleanup, human spot review, and explicit provenance fields such as `source=bootstrap`, `content_version`, and `review_status=approved`.

## Validation

The next implementation slice should prove:

- Public route code has no Gemini call path.
- AI routes block when kill switches are disabled.
- Usage records are written for Gemini calls.
- Spend-cap checks can disable live AI and batch generation.
- Static reads continue after AI is disabled.
