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
