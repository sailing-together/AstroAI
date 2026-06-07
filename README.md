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
- `frontend/web/` is the production-facing Next.js public web app.
- `frontend/preview/` is a developer/API tester for static horoscope backend validation, not production UI.

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

The existing Flutter app remains useful as a demo/reference, but the redevelopment target is the Next.js public web app in `frontend/web`.

## Public Web App

The production-facing web app lives in `frontend/web`.

From WSL, start the FastAPI backend and Next.js public web app together:

```bash
cd /mnt/d/Projects/AstroAI/AstroAI
bash frontend/web/start-web.sh
```

The script chooses free local ports, writes ignored local development env files, and sets
`NEXT_PUBLIC_API_BASE_URL` so the web app calls the matching backend instance.

Open the printed `/horoscope` URL. The page should hide API/debug controls and use the
static horoscope bundle API through `NEXT_PUBLIC_API_BASE_URL`.

## Developer Preview

The developer API tester remains in `frontend/preview`.

```bash
cd frontend/preview
bash start-preview.sh
```

Use the preview page only to validate backend API behavior and static bundle data.
