# Phase 1.5 Static Horoscopes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the public no-login static horoscope backend foundation without live Gemini calls during user reads.

**Architecture:** Keep FastAPI `/api/v1` routing. Add deterministic Sun-sign utility, static horoscope database model, Pydantic response schemas, an in-memory repository boundary for the first API contract, and public read routes. In development, first loading a sign/year may generate a full-year Codex-authored static seed in memory, marked as `codex-dev`; production generation remains a separate Gemini Flash-Lite job boundary.

**Tech Stack:** FastAPI, Pydantic, SQLAlchemy 2.x, pytest.

---

## Task 1: Public Sun-Sign Utility

**Files:**
- Create: `backend/api/v1/utils.py`
- Create: `backend/services/zodiac.py`
- Modify: `backend/api/v1/router.py`
- Test: `tests/backend/test_public_static_horoscopes.py`

- [ ] Write failing tests for `/api/v1/utils/sun-sign`.
- [ ] Run the targeted test and verify it fails with 404.
- [ ] Implement deterministic zodiac calculation returning lowercase canonical signs in services and Title Case in API response.
- [ ] Register the utils router.
- [ ] Run the targeted test and verify it passes.
- [ ] Commit with `feat: add public sun sign utility`.

## Task 2: Static Horoscope Model and Schemas

**Files:**
- Create: `backend/database/models_static_horoscope.py`
- Create: `backend/schemas/horoscope.py`
- Modify: `backend/database/__init__.py`
- Test: `tests/backend/test_static_horoscope_model.py`

- [ ] Write failing model/schema tests for dimensions, arrays, generated timestamp, and unique content identity fields.
- [ ] Run tests and verify missing module failure.
- [ ] Implement `StaticHoroscope` SQLAlchemy model.
- [ ] Implement horoscope response and bundle schemas.
- [ ] Export the model from `backend/database/__init__.py`.
- [ ] Run tests and verify they pass.
- [ ] Commit with `feat: add static horoscope model`.

## Task 3: Public Horoscope Read API

**Files:**
- Create: `backend/api/v1/horoscope.py`
- Create: `backend/services/static_horoscope_repository.py`
- Modify: `backend/api/v1/router.py`
- Test: `tests/backend/test_public_static_horoscopes.py`

- [ ] Write failing tests for bundle, daily, invalid sign, and no-auth access.
- [ ] Run tests and verify route failures.
- [ ] Implement a static repository boundary seeded with deterministic sample rows for API contract verification.
- [ ] Implement `/horoscope/bundle/{sign}` and `/horoscope/daily|weekly|monthly|yearly/{sign}` routes.
- [ ] Register the horoscope router.
- [ ] Run public horoscope tests and verify they pass.
- [ ] Commit with `feat: add public static horoscope API`.

## Task 3.5: Codex Dev First-Load Full-Year Seed

**Files:**
- Create: `backend/services/codex_dev_horoscope_seed.py`
- Modify: `backend/services/static_horoscope_repository.py`
- Test: `tests/backend/test_codex_dev_horoscope_seed.py`

- [ ] Write failing tests proving a first-load seed generates yearly, 12 monthly periods, all year weekdays, and all year days for 9 focuses.
- [ ] Run tests and verify missing module failure.
- [ ] Implement a deterministic Codex-authored seed generator marked with `generation_model="codex-dev"`.
- [ ] Wire `StaticHoroscopeRepository` through `get_or_create_year(sign, year)`.
- [ ] Run tests and verify they pass.
- [ ] Commit with `feat: add Codex dev horoscope seed generation`.

## Task 4: Generation Boundary

**Files:**
- Create: `backend/services/static_horoscope_generator.py`
- Test: `tests/backend/test_static_horoscope_generator.py`

- [ ] Write failing tests proving generation uses Flash-Lite model name and produces one row per supported focus.
- [ ] Run tests and verify missing module failure.
- [ ] Implement generation request dataclass and prompt/result boundary without making a real Gemini call in tests.
- [ ] Run generator tests and verify they pass.
- [ ] Commit with `feat: add static horoscope generation boundary`.

## Task 5: Verification

**Files:**
- Review all files touched in Tasks 1-4.

- [ ] Run `pytest tests/backend -v`.
- [ ] Confirm active public read routes do not import `GeminiClient`.
- [ ] Confirm route table includes `/api/v1/utils/sun-sign` and public horoscope routes.
- [ ] Push `codex/phase-1-5-static-horoscopes`.
