import asyncio

from sqlalchemy.dialects import postgresql

from backend.services.static_horoscope_dev_importer import build_static_horoscope_rows
from backend.services.static_horoscope_seed_writer import StaticHoroscopePostgresSeedWriter, build_upsert_statement


def test_seed_writer_builds_postgres_upsert_statement():
    row = build_static_horoscope_rows(signs=["gemini"], year=2026)[0]

    statement = build_upsert_statement([row])
    compiled = str(statement.compile(dialect=postgresql.dialect()))

    assert "INSERT INTO static_horoscopes" in compiled
    assert "ON CONFLICT (sign, target_year, period, focus, content_date, content_version)" in compiled
    assert "DO UPDATE SET" in compiled
    assert "title = excluded.title" in compiled
    assert "is_active = excluded.is_active" in compiled


def test_seed_writer_executes_upsert_and_commits():
    rows = build_static_horoscope_rows(signs=["gemini"], year=2026)[:2]
    session = RecordingAsyncSession()
    writer = StaticHoroscopePostgresSeedWriter(session=session)

    persisted_count = asyncio.run(writer.upsert_rows(rows))

    assert persisted_count == 2
    assert len(session.executed_statements) == 1
    assert session.commit_count == 1


def test_seed_writer_batches_large_upserts_and_commits_once():
    rows = build_static_horoscope_rows(signs=["gemini"], year=2026)[:5]
    session = RecordingAsyncSession()
    writer = StaticHoroscopePostgresSeedWriter(session=session, batch_size=2)

    persisted_count = asyncio.run(writer.upsert_rows(rows))

    assert persisted_count == 5
    assert len(session.executed_statements) == 3
    assert session.commit_count == 1


def test_seed_writer_skips_empty_rows_without_commit():
    session = RecordingAsyncSession()
    writer = StaticHoroscopePostgresSeedWriter(session=session)

    persisted_count = asyncio.run(writer.upsert_rows([]))

    assert persisted_count == 0
    assert session.executed_statements == []
    assert session.commit_count == 0


def test_seed_writer_rejects_invalid_batch_size():
    try:
        StaticHoroscopePostgresSeedWriter(session=RecordingAsyncSession(), batch_size=0)
    except ValueError as exc:
        assert "batch_size" in str(exc)
    else:
        raise AssertionError("Expected invalid batch size to raise.")


class RecordingAsyncSession:
    def __init__(self) -> None:
        self.executed_statements = []
        self.commit_count = 0

    async def execute(self, statement):
        self.executed_statements.append(statement)

    async def commit(self):
        self.commit_count += 1
