# AstroAI

AstroAI is being redeveloped around the canonical source-of-truth docs in `docs/`:

- `docs/PRODUCT.md`
- `docs/ARCHITECTURE.md`
- `docs/API_SPEC.md`
- `docs/SCHEMA.md`
- `docs/FRONTEND_SPEC.md`

## Current Code Status

- `backend/` contains the FastAPI redevelopment base plus legacy demo routes.
- `frontend/flutter/` is the existing legacy/demo frontend.
- `frontend/nextjs/` does not exist yet and is not part of Phase 1.

## Current Development Focus

Phase 1 focuses on:

- FastAPI `/api/v1` route foundation.
- Supabase Auth and PostgreSQL foundations.
- Deterministic natal chart calculation.
- Gemini 2.5 Flash / Flash-Lite client setup.
- Redis-backed AI rate limiting.

Phase 1.5 will add the public static horoscope engine:

- No-login yearly/monthly/weekly/daily horoscope bundle reads.
- Birth-date-to-Sun-sign utility.
- Scheduled and manual static content generation.
- Stored PostgreSQL/Redis reads that do not call Gemini at request time.

The existing Flutter app remains useful as a demo/reference, but the redevelopment target is a Next.js public web entry after the backend foundation is stable.
