# Static Horoscope DB Persistence Implementation Plan

> Status: Ready for implementation after review.
> Date: 2026-06-05
> Target branch: `v2`

## Goal

Make public horoscope reads use persisted `static_horoscopes` rows as the primary source of truth while preserving deterministic development seeding for local work.

The anonymous public API must not call Gemini during user requests.

## Current Baseline

Already merged to `v2`:

- `StaticHoroscope` SQLAlchemy model exists.
- 2026 calendar coverage utilities exist.
- Dev seed generator creates full-year rows for yearly, monthly, weekly, and daily periods.
- `build_all_static_horoscope_rows(year)` can create all 46,548 deterministic rows for 2026.
- `StaticHoroscopeRepository` can hydrate response data from persisted model rows when rows are passed in.
- Public horoscope API still uses a process-level repository that falls back to generated/dev seed content.

## Non-Goals

- Do not build final public UI in this backend slice.
- Do not call Gemini for production-quality horoscope copy yet.
- Do not implement Redis caching in the first DB persistence PR.
- Do not remove legacy backend modules.
- Do not download copyrighted astrology books or unapproved knowledge sources.

## Design

### Data Source Order

Development:

1. Query active database rows for the requested sign/year.
2. If rows are missing and development seed mode is enabled, generate deterministic dev rows and persist them.
3. Serve the response from persisted rows.

Production:

1. Query active database rows for the requested sign/year.
2. If rows are missing, return a clear static-data-not-ready error.
3. Never generate dev rows.
4. Never call Gemini from public read requests.

### Repository Boundary

Add a database-backed store that can:

- Fetch all active rows for a sign/year.
- Fetch rows for a selected sign/year/period/date/focus.
- Upsert deterministic development rows.
- Validate expected coverage for a target year.

The current `StaticHoroscopeRepository` may remain as the response mapper, but route handlers should get rows from the database first.

### Seed Boundary

Keep deterministic seed generation for local development and tests. Treat Codex-authored seed text as development fixture data, not production editorial content.

The seed command should:

- Accept a target year.
- Accept optional signs.
- Generate rows through `build_static_horoscope_rows` or `build_all_static_horoscope_rows`.
- Upsert rows into the configured database.
- Record `source = "codex-dev"` and `generation_model = "codex-dev"`.

## File-Level Plan

### Task 1: Database Store Tests

Files:

- Create `tests/backend/test_static_horoscope_db_store.py`
- Create `backend/services/static_horoscope_db_store.py`

Tests:

- Store builds a query scoped to active rows for `sign`, `target_year`, and optional `period`.
- Store converts fetched rows into a hydrated `StaticHoroscopeRepository`.
- Inactive rows are ignored.
- Duplicate inactive historical rows do not override active rows.

Implementation notes:

- Prefer pure query-building and row-mapping tests first.
- Avoid requiring a live Supabase database in unit tests.
- If using SQLite test databases, do not rely on PostgreSQL-only column types unless the model is adjusted first.

### Task 2: Development Seed Service

Files:

- Create `backend/services/static_horoscope_seed_service.py`
- Create or update `tests/backend/test_static_horoscope_seed_service.py`

Tests:

- Generates 46,548 rows for all 12 signs in 2026.
- Upsert identity is `(sign, target_year, period, focus, content_date, content_version)`.
- Visible copy does not mention Codex, Gemini, provider names, or debug language.
- Seed service is explicit; it does not run during imports.

Implementation notes:

- Keep the service usable from tests without a live database.
- Put database writes behind an injected session/store dependency.

### Task 3: Public API Database Read Path

Files:

- Modify `backend/api/v1/horoscope.py`
- Modify or create `backend/services/static_horoscope_repository.py`
- Modify or create `backend/services/static_horoscope_db_store.py`
- Update `tests/backend/test_public_static_horoscopes.py`

Tests:

- `GET /horoscope/bundle/gemini?year=2026` reads persisted rows when available.
- Public read does not call the dev generator when complete persisted rows exist.
- Weekly selected-date lookup still maps `2026-01-01` to `2025-12-29`.
- Missing production data returns a clear error rather than live generation.
- Development mode can seed missing local rows only when explicitly enabled.

Implementation notes:

- Inject `AsyncSession` through FastAPI dependencies.
- Avoid global mutable repository state for request-time DB reads.
- Preserve existing response DTOs until the frontend contract is deliberately changed.

### Task 4: Coverage Validation

Files:

- Create or update `backend/services/static_horoscope_coverage.py`
- Update `tests/backend/test_static_horoscope_coverage.py`

Tests:

- 2026 expected counts are:
  - `yearly = 9`
  - `monthly = 108`
  - `weekly = 477`
  - `daily = 3285`
  per sign.
- All 12 signs expected count is `46548`.
- Missing focus/date combinations are reported with enough detail for operators.

Implementation notes:

- Use deterministic calendar utilities as the expected source.
- Return structured coverage results, not only booleans.

### Task 5: Operator Command

Files:

- Create `backend/tasks/seed_static_horoscopes.py` or `backend/scripts/seed_static_horoscopes.py`
- Add tests where practical.
- Update `backend/README.md` with the command.

Command behavior:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --source codex-dev
```

Expected:

- Connects to configured database.
- Seeds all 12 signs by default.
- Supports a `--sign gemini` option for smaller local runs.
- Prints row count and coverage summary.
- Does not call Gemini.

## Acceptance Criteria

- Backend tests pass.
- Public horoscope route tests prove persisted rows are used.
- Public read code has no Gemini dependency.
- Development seed command can generate 2026 all-sign content.
- Production missing-data behavior is explicit and tested.
- `PROJECT_STATUS.md` is updated after implementation.

## Risks and Decisions

- The current model uses PostgreSQL `ARRAY(Integer)` for `lucky_numbers`; SQLite-based tests may not compile this column. Choose either PostgreSQL-focused query tests or change the column to a cross-database JSON type in a separate, documented decision.
- Full 46,548-row generation is manageable for local deterministic data, but production AI generation must batch carefully and track prompt/knowledge versions.
- Redis should be added after PostgreSQL read correctness is stable.
