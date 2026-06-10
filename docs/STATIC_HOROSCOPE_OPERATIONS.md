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

The command returns a non-zero exit code when validation coverage is incomplete, so CI or shell scripts can stop immediately without parsing logs.

## 4. Smoke Read Existing Export

Before touching a real database, smoke-test the public read path against the export file:

```bash
python -m backend.tasks.seed_static_horoscopes \
  --year 2026 \
  --sign gemini \
  --smoke-read-ndjson downloads/static-horoscopes-2026.ndjson.gz \
  --smoke-date 2026-06-02 \
  --summary-json downloads/static-horoscopes-2026.gemini-smoke-summary.json
```

Expected output includes:

```text
rows=46548 expected=3879 coverage=complete smoke_read=complete input=downloads/static-horoscopes-2026.ndjson.gz
```

The smoke check uses the same repository read shape as the public horoscope API:

- yearly bundle: 9 rows for the selected sign
- monthly bundle: 108 rows for the selected sign
- weekly bundle: 477 rows for the selected sign
- daily bundle: 3,285 rows for the selected sign
- selected yearly/monthly/weekly/daily response: 9 focus dimensions each

If `smoke_read=incomplete`, do not import or write the file to production.

The command returns a non-zero exit code when the smoke read is incomplete.

## 5. Database Write

Only write to Supabase/PostgreSQL after:

- `DATABASE_URL` points to the intended database.
- The migration has been applied:

```bash
psql "$DATABASE_URL" -f backend/database/migrations/20260605_create_static_horoscopes.sql
```

- The dry-run and export validation both report `coverage=complete`.

Run a database preflight check before writing:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --preflight-db
```

This verifies database connectivity and that the `static_horoscopes` table can be queried. `--write-db` runs the same preflight check before upserting rows.

Then write rows through the configured backend environment. The safest handoff is to write from the exact export file that was validated:

```bash
python -m backend.tasks.seed_static_horoscopes \
  --year 2026 \
  --from-ndjson downloads/static-horoscopes-2026.ndjson.gz \
  --write-db
```

`--from-ndjson` reloads the file and validates coverage before writing. If coverage is incomplete, the command refuses to call the database writer.

If `ENVIRONMENT=production`, add the explicit production confirmation flag:

```bash
python -m backend.tasks.seed_static_horoscopes \
  --year 2026 \
  --from-ndjson downloads/static-horoscopes-2026.ndjson.gz \
  --write-db \
  --allow-production-write
```

You can also generate and write in one step:

```bash
python -m backend.tasks.seed_static_horoscopes --year 2026 --write-db
```

Expected complete write output:

```text
rows=46548 expected=46548 coverage=complete persisted=46548 write=complete dry_run=false
```

If `write=incomplete`, stop and investigate before using the public horoscope page against that database.

Database writes are batched to avoid oversized PostgreSQL statements when writing all 46,548 rows for 2026.

The command returns a non-zero exit code when `write=incomplete`.

## 6. Public Read Rule

Public anonymous horoscope requests must read persisted static content only. They must not call Gemini or any other live AI API during page views.
In production, missing or incomplete active rows for a requested sign/year must return `static_horoscope_not_ready` with HTTP 503 rather than filling gaps with generated fallback content.

Allowed AI/API usage:

- backend scheduled or manual generation jobs
- registered-user personalized predictions
- AI Astrologer chat
- AI natal chart interpretation

Not allowed:

- live AI calls for public yearly/monthly/weekly/daily horoscope reads
- committing generated `downloads/` exports to Git
