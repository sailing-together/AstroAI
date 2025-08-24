# AstroAI — Dev Tickets (Pitch + MVP Demo)

## Epic A — Pitch Assets (video-ready)
- **A1 — Teleprompter Script (EN)**
  - Output: `teleprompter_en.md` (the script approved in chat).
  - DoD: ≤ 450 words; two speakers labeled; timestamps at section heads.

- **A2 — SRT Captions (EN)**
  - Input: A1. Output: `astroai_3min_en.srt` (18–22 cues, ≤ 2 lines/cue).
  - DoD: timestamps align to storyboard beats (±0.5s).

- **A3 — Storyboard Slides**
  - Output: `AstroAI_Storyboard_v2.pptx` (1 shot/slide: timecode, VO, cue, asset, notes).
  - DoD: 15 slides + cover; asset refs point to AstroAI.pdf pages.

- **A4 — Backup Screen Captures**
  - Record: Today (10s), Compatibility (20s), Chart (10s).
  - DoD: 1080p, no PII, smooth cursor; exported to `/assets/broll/`.

## Epic B — MVP Demo-Mode Hardening
- **B1 — Demo API Stubs (FastAPI)**
  - Endpoints: `/v1/guidance/daily`, `/v1/compat/quick`, `/v1/chart/{id}` return canned JSON.
  - DoD: schemas match PRD samples; unit tests (pytest) cover 100% of stubs.

- **B2 — Flutter Demo Toggle**
  - `--dart-define=DEMO_MODE=true` routes FE to stubs; `API_BASE_URL` configurable.
  - DoD: flag switch works; no runtime errors.

- **B3 — “Try Today” UX Polish**
  - Card padding 16–20px; 16px radius; soft shadow; skeleton loader.
  - DoD: Lighthouse ≥ 90/90/90; color contrast ≥ 4.5:1.

- **B4 — Shareable Card (PNG)**
  - FE compose → POST `/v1/share/card` (mock); returns 1080×1350 PNG.
  - DoD: brand font/color; no PII; saved to `/tmp/cards/`.

## Epic C — Telemetry & Validation (no signup)
- **C1 — Event Logger (FE helper)**
  - `logEvent(name, props)`; events: `insight_view`, `compat_run`, `chart_view`, `helpful_vote`, `share_created`.
  - DoD: POST `/v1/events`; retries + offline queue.

- **C2 — FastAPI `/v1/events`**
  - SQLite insert: `event, session_id, props_json, ts, ip, ua`.
  - DoD: p99 < 50ms; IP rate-limit.

- **C3 — Day‑3 Micro‑Survey Modal**
  - 3 Qs + NPS; submits to `/v1/events` with `survey_submit`.
  - DoD: one‑time per session cohort; accessible controls.

## Epic D — Copy Guardrails (“value gates”)
- **D1 — Copy Linter (CI)**
  - Blocks publish if: no `cause` (Personalized), missing `next_step` verb (Actionable), or banned words (“never/always/guarantee”, Caring).
  - DoD: CI fails on violation; README includes override procedure.

## Epic E — Roadmap Scaffolding
- **E1 — Alerts/Transits (stub)**
  - `/v1/alerts/today` returns two sample alerts (retrograde, lunar); timezone-aware.
  - DoD: Today page chip renders gracefully with/without alerts.

- **E2 — AI Astrologer (lite stub)**
  - `/v1/ai/ask` returns canned `answer` + `sources[]`.
  - DoD: FE bubble renders; safety disclaimer visible.

### Global DoD
- p95 API < 300ms; no console errors; Sentry wired (FE/BE); basic analytics live; README updated.
