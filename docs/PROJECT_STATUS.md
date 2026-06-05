# AstroAI Project Status

> Status: Daily development guidance.
> Last updated: 2026-06-05

This file records where the redevelopment stands today. Use it with the canonical source-of-truth docs:

- `PRODUCT.md` for product direction, roadmap, AI policy, tier policy, and MVP scope.
- `ARCHITECTURE.md` for system boundaries and provider decisions.
- `API_SPEC.md` for backend/frontend contracts.
- `SCHEMA.md` for Supabase/PostgreSQL schema.
- `FRONTEND_SPEC.md` for web routes, UX, and design rules.

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
- `frontend/preview` remains a developer/API tester only.

## In Progress

### Static Horoscope DB Persistence

Current state:

- SQLAlchemy model shape exists.
- Dev row importer exists.
- Repository can read persisted rows when rows are passed in.
- Database store boundary exists for active-row query construction and repository hydration.
- Seed service boundary exists for deterministic row generation, versioned identity validation, and injected persistence writers.

Missing:

- Public API still uses a process-level repository with generated/dev seed fallback.
- Public API does not yet query Supabase/PostgreSQL through `AsyncSession`.
- There is no operator command for writing the 2026 static rows to a configured database.
- There is no migration or DDL workflow checked in for the `static_horoscopes` table.
- Redis caching is documented but not implemented.
- Production missing-data behavior is not enforced yet.

Next plan:

- Use `docs/superpowers/plans/2026-06-05-static-horoscope-db-persistence.md`.

## Next Recommended Work

1. Finish static horoscope DB persistence.
2. Add a local/dev seed command for 2026 all-sign static horoscope rows.
3. Wire public horoscope API reads to database rows in development and production-shaped tests.
4. Add a data-not-ready response for production when static rows are missing.
5. Build the production public horoscope UI to replace the current rough page.
6. Add sign profile and sign-pair compatibility static content after horoscope data is stable.
7. Return to registered-user foundation: Supabase auth screens, birth data onboarding, natal chart persistence, and chart reveal.

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
