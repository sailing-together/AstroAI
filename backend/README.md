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

Generate and validate deterministic 2026 static horoscope rows without writing to a database:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --dry-run
```

Generate one sign for a smaller local check:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --sign gemini --dry-run
```

The command currently supports deterministic `codex-dev` seed rows and dry-run validation. A database writer will be added before using it to populate Supabase/PostgreSQL.
