# AstroAI Project Status

> Status: Daily development guidance.
> Last updated: 2026-06-27

This file records where the redevelopment stands today. Use it with the canonical source-of-truth docs:

- `PRODUCT.md` for product direction, roadmap, AI policy, tier policy, and MVP scope.
- `ARCHITECTURE.md` for system boundaries and provider decisions.
- `API_SPEC.md` for backend/frontend contracts.
- `SCHEMA.md` for Supabase/PostgreSQL schema.
- `FRONTEND_SPEC.md` for web routes, UX, and design rules.
- `STATIC_HOROSCOPE_OPERATIONS.md` for 2026 static data generation, export, validation, and database handoff.
- `docs/superpowers/specs/2026-06-27-conversation-first-ai-companion-home.md` for registered AI companion-home direction.

Deprecated files such as `ROADMAP_DEVELOPMENT_PLAN.md`, `MEETING_CONCLUSIONS.md`, `DECISIONS.md`, `DATABASE_SCHEMA.md`, `DESIGN.md`, `BACKEND_API.md`, and `FRONTEND_ARCHITECTURE.md` are not sources of truth.

## Current Branch Policy

- Main development target: `v2`.
- Codex work should use isolated branches with the `codex/` prefix.
- Work should be pushed as PRs into `v2` for review.
- The reviewer merges PRs into `v2`; new work starts from latest `origin/v2`.

## Daily Start Checklist

At the beginning of each work session, report:

1. Current branch and worktree.
2. Latest `v2` status.
3. What was completed last session.
4. Today's intended slice.
5. Any blockers or decisions needed.
6. Expected commit, push, and PR outcome.

## Completed on `v2`

### Phase 0: Direction and Source-of-Truth Docs

- Canonical source-of-truth docs exist: `PRODUCT.md`, `ARCHITECTURE.md`, `API_SPEC.md`, `SCHEMA.md`, and `FRONTEND_SPEC.md`.
- MVP provider policy is frozen: Gemini only; no Claude/Sonnet in MVP backend code.
- Tier names are frozen: `free` and `premium`; avoid `pro`.
- Public static horoscope rules are recorded: anonymous reads must not call Gemini.
- Registered product direction is conversation-first: AI Astrologer is primary, while chart, horoscope, compatibility, mood, and memory modules provide context.
- Deprecated planning files point back to canonical docs.

### Phase 1: Backend Foundation

- FastAPI `/api/v1` router family exists.
- Backend configuration uses Pydantic Settings.
- Supabase/PostgreSQL-oriented SQLAlchemy session and models exist.
- User, natal chart, chat, health, utility, and public horoscope route families exist at contract level.
- Deterministic chart service scaffolding exists.
- Gemini client wrapper scaffolding exists.

### Phase 1.5: Static Horoscope Foundation

- Public horoscope routes exist:
  - `GET /api/v1/horoscope/bundle/{sign}`
  - `GET /api/v1/horoscope/daily/{sign}`
  - `GET /api/v1/horoscope/weekly/{sign}`
  - `GET /api/v1/horoscope/monthly/{sign}`
  - `GET /api/v1/horoscope/yearly/{sign}`
- Birth-date-to-Sun-sign utility exists:
  - `GET /api/v1/utils/sun-sign`
- 2026 static horoscope coverage rules are implemented:
  - 1 yearly row per focus.
  - 12 monthly rows per focus.
  - 53 weekly rows per focus for weeks intersecting 2026.
  - 365 daily rows per focus.
  - 3,879 rows per sign, 46,548 rows for all 12 signs.
- Weekly selected-date lookup works for dates such as `2026-01-01`, mapping to week start `2025-12-29`.
- Development seed generation produces reader-facing copy without visible provider names.
- `StaticHoroscopeRepository` can hydrate its response seed from persisted `StaticHoroscope` model rows.
- `build_all_static_horoscope_rows(year=2026)` can build deterministic dev rows for all signs.

### Phase 2: Public Web Foundation

- `frontend/web` Next.js 14 App Router app exists.
- Public `/horoscope` experience exists as the first production-facing web entry.
- Public web calls canonical `/api/v1` backend routes.
- Public web has runtime feedback for loading and local API fallback states.
- Public web has a dedicated WSL runner at `frontend/web/start-web.sh` that starts FastAPI and Next.js together.
- Public web dependency security is being upgraded from Next.js 14 to Next.js 16 with a PostCSS override to clear npm audit findings.
- `frontend/preview` remains a developer/API tester only.
- Public web UX consolidation spec exists at `docs/superpowers/specs/2026-06-05-public-web-ux-design.md`.
- Public horoscope product surface has a first production-design pass on `/horoscope`, with a clearer bridge from free static guidance to chart-grounded personalization.

## In Progress

### Public Horoscope UX Shell

Current state:

- `/horoscope` is being moved from a tester-style interface toward the production public horoscope surface.
- The selected view date drives the daily reading, matching week, matching month, and year overview.
- Development-only wording such as backend connection details, API base labels, and static bundle language is being removed from the user-facing page.
- The page prioritizes the daily reading in the first viewport, with sign, birth date, and view date controls as supporting tools.
- The public web API client can distinguish production static-data-not-ready responses from connection failures.
- Product direction is now conversation-first: public horoscope remains the acquisition and utility layer, while the registered experience should make AI Astrologer the primary interaction and use modules as context sources.
- Conversation-first companion-home design is captured in `docs/superpowers/specs/2026-06-27-conversation-first-ai-companion-home.md`.

Next plan:

- Continue applying `docs/superpowers/specs/2026-06-05-public-web-ux-design.md`.
- Design the registered AI companion home around direct questions, suggested prompts, natal chart context, and quota visibility instead of a module grid.
- Add visual QA once browser tooling is available for the current worktree page.
- Follow with richer visual polish, zodiac education, and conversion paths after the static data/API flow is stable.

### Static Horoscope DB Persistence

Current state:

- SQLAlchemy model shape exists.
- Dev row importer exists.
- Repository can read persisted rows when rows are passed in.
- Database store boundary exists for active-row query construction and repository hydration.
- Seed service boundary exists for deterministic row generation, versioned identity validation, and injected persistence writers.
- Operator seed command exists for deterministic dry-run generation and injected-writer execution.
- PostgreSQL seed writer boundary exists for versioned static horoscope upserts.
- Public bundle route now has a database-first read path when active persisted rows are available.
- Public daily, weekly, monthly, and yearly routes now have database-first read paths when active persisted rows are available.
- Weekly DB-first reads preserve the selected target year for cross-year weeks such as `2026-W01` starting on `2025-12-29`.
- Local development still falls back to deterministic dev content if the configured database is unavailable or has no rows.
- Production returns `503 static_horoscope_not_ready` when static rows are missing or the configured database cannot be read.
- Static horoscope table SQL migration exists at `backend/database/migrations/20260605_create_static_horoscopes.sql`.
- Static horoscope coverage validation exists for expected period/focus/date counts.
- The seed command dry-run reports expected row count and coverage completeness.
- The seed command write path reports whether the writer persisted the complete generated row count.
- The seed command can export generated rows to local NDJSON or gzip-compressed NDJSON for review/import handoff.
- Static horoscope NDJSON exports can be reloaded and validated before database import/write handoff.

Missing:

- The operator seed command can write through PostgreSQL, but it still needs real environment variables and database/migration setup before live use.
- Redis caching is documented but not implemented.

Next plan:

- Use `docs/superpowers/plans/2026-06-05-static-horoscope-db-persistence.md`.

## Next Recommended Work

1. Validate the seed command against a real configured PostgreSQL/Supabase environment.
2. Add Redis caching after PostgreSQL read correctness is stable.
3. Continue the production public horoscope UI from `docs/superpowers/specs/2026-06-05-public-web-ux-design.md`.
4. Design the registered AI companion home as a conversation-first surface, not a feature/module directory.
5. Add sign profile and sign-pair compatibility static content after horoscope data is stable.
6. Return to registered-user foundation: Supabase auth screens, birth data onboarding, natal chart persistence, and chart reveal.

## Known Technical Debt

- Legacy backend modules still exist under `backend/api/*`, `backend/models/*`, and several Gemini prompt services. Do not delete them casually; remove them only with tests proving canonical `/api/v1` replacements are used.
- Existing SQLite ephemeris assets remain in the repo. Production persistence target is Supabase/PostgreSQL.
- Some generated Python cache files may exist locally. They are not development targets.
- `frontend/preview` is useful for API validation but must not drive production design.
- `gh` may not be available in the current WSL environment, so Codex can push branches but may need to provide PR links instead of creating PRs automatically.

## Definition of Done for Each Development Slice

- Work starts from latest `origin/v2`.
- Changes are scoped to one feature or documentation slice.
- Tests are added or updated before implementation when behavior changes.
- Relevant backend/frontend verification passes.
- Docs are updated when contracts, schema, roadmap, or user-facing behavior changes.
- Branch is pushed with a PR link for review into `v2`.
