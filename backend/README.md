# AstroAI Backend

Phase 1 target: FastAPI backend under `/api/v1` using Supabase PostgreSQL/Auth, Redis rate limiting, deterministic natal chart calculation, and Gemini 2.5 Flash/Flash-Lite.

Legacy root routes such as `/horoscope`, `/compatibility`, `/natal_chart`, `/review_event`, and `/with_celebrity` are retained only as reference until the new `/api/v1` implementation replaces them.

## Local Setup

Copy the env example and fill real values locally:

```bash
cp backend/.env.example backend/.env
```

Run locally:

```bash
pip install -r backend/requirements.txt
uvicorn backend.main:app --reload
```

Do not commit real `.env` files or secrets.

## Static Horoscope Seed Command

Apply the static horoscope table migration to the configured Supabase/PostgreSQL database before writing rows:

```bash
psql "$DATABASE_URL" -f backend/database/migrations/20260605_create_static_horoscopes.sql
```

Generate and validate deterministic 2026 static horoscope rows without writing to a database:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --dry-run
```

Dry-run output includes generated row count, expected row count, and coverage status.

Generate one sign for a smaller local check:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --sign gemini --dry-run
```

Write rows to the configured PostgreSQL database only when the backend environment variables are set:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --sign gemini --write-db
```

The command currently supports deterministic `codex-dev` seed rows. Use `--dry-run` first before any real database write.
