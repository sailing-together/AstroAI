# Static Horoscope Operations

This file is the operator handoff for public static horoscope data. It explains how to generate, export, validate, and later persist the 2026 yearly/monthly/weekly/daily horoscope rows.

## Scope

- Target year: 2026.
- Data shape: 12 zodiac signs, 9 focus dimensions, yearly/monthly/weekly/daily periods.
- Expected total: 46,548 rows.
- Source: deterministic `codex-dev` seed data for development and import testing.
- Durable production target: Supabase/PostgreSQL table `static_horoscopes`.
- Git policy: generated export files stay under `downloads/`, which is ignored by Git.

## 1. Dry-Run Coverage

Use dry-run first. This generates rows in memory and validates coverage without writing a file or database.

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --dry-run
```

Expected output includes:

```text
rows=46548 expected=46548 coverage=complete persisted=0 write=complete dry_run=true
```

For one sign:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --sign gemini --dry-run
```

Expected one-sign row count is `3,879`.

## 2. Export Handoff File

Export gzip-compressed NDJSON plus a JSON summary:

```bash
python -m backend.tasks.seed_static_horoscopes \
  --year 2026 \
  --export-ndjson downloads/static-horoscopes-2026.ndjson.gz \
  --summary-json downloads/static-horoscopes-2026.summary.json
```

The summary records:

- row count and expected count
- coverage status
- export file path and size
- period counts
- sign counts
- focus counts

Expected 2026 period counts:

```text
yearly=108
monthly=1296
weekly=5724
daily=39420
```

## 3. Validate Existing Export

Before import or database write handoff, validate the existing file:

```bash
python -m backend.tasks.seed_static_horoscopes \
  --year 2026 \
  --validate-ndjson downloads/static-horoscopes-2026.ndjson.gz \
  --summary-json downloads/static-horoscopes-2026.validate-summary.json
```

Expected output includes:

```text
rows=46548 expected=46548 coverage=complete validate=downloads/static-horoscopes-2026.ndjson.gz
```

If coverage is incomplete, do not import or write the file to production.

## 4. Database Write

Only write to Supabase/PostgreSQL after:

- `DATABASE_URL` points to the intended database.
- The migration has been applied:

```bash
psql "$DATABASE_URL" -f backend/database/migrations/20260605_create_static_horoscopes.sql
```

- The dry-run and export validation both report `coverage=complete`.

Then write rows through the configured backend environment:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --write-db
```

Expected complete write output:

```text
rows=46548 expected=46548 coverage=complete persisted=46548 write=complete dry_run=false
```

If `write=incomplete`, stop and investigate before using the public horoscope page against that database.

## 5. Public Read Rule

Public anonymous horoscope requests must read persisted static content only. They must not call Gemini or any other live AI API during page views.

Allowed AI/API usage:

- backend scheduled or manual generation jobs
- registered-user personalized predictions
- AI Astrologer chat
- AI natal chart interpretation

Not allowed:

- live AI calls for public yearly/monthly/weekly/daily horoscope reads
- committing generated `downloads/` exports to Git
