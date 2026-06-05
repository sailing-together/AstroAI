from datetime import date

from sqlalchemy.dialects import postgresql

from backend.services.static_horoscope_db_store import StaticHoroscopeDbStore
from backend.services.static_horoscope_dev_importer import build_static_horoscope_rows


def test_db_store_builds_active_year_rows_query():
    statement = StaticHoroscopeDbStore.build_year_rows_statement("Gemini", 2026, period="daily")
    compiled = _compile_statement(statement)

    assert "static_horoscopes.sign = 'gemini'" in compiled
    assert "static_horoscopes.target_year = 2026" in compiled
    assert "static_horoscopes.period = 'daily'" in compiled
    assert "static_horoscopes.is_active IS true" in compiled
    assert "ORDER BY" in compiled


def test_db_store_builds_focused_entry_rows_query():
    statement = StaticHoroscopeDbStore.build_entry_rows_statement(
        sign="gemini",
        target_year=2026,
        period="weekly",
        content_date=date(2025, 12, 29),
        focus="general",
    )
    compiled = _compile_statement(statement)

    assert "static_horoscopes.sign = 'gemini'" in compiled
    assert "static_horoscopes.target_year = 2026" in compiled
    assert "static_horoscopes.period = 'weekly'" in compiled
    assert "static_horoscopes.content_date = '2025-12-29'" in compiled
    assert "static_horoscopes.focus = 'general'" in compiled
    assert "static_horoscopes.is_active IS true" in compiled


def test_db_store_hydrates_repository_from_active_rows():
    rows = build_static_horoscope_rows(signs=["gemini"], year=2026)
    rows[0].title = "Stored Active Reading"

    repository = StaticHoroscopeDbStore.repository_from_rows(rows)
    entry = repository.build_entry("gemini", rows[0].period, rows[0].focus, rows[0].content_date)

    assert entry.title == "Stored Active Reading"


def test_db_store_inactive_rows_do_not_override_active_rows():
    active_rows = build_static_horoscope_rows(signs=["gemini"], year=2026)
    inactive_row = build_static_horoscope_rows(signs=["gemini"], year=2026)[0]
    inactive_row.title = "Old Inactive Reading"
    inactive_row.is_active = False
    active_rows[0].title = "Current Active Reading"

    repository = StaticHoroscopeDbStore.repository_from_rows([inactive_row, *active_rows])
    entry = repository.build_entry("gemini", active_rows[0].period, active_rows[0].focus, active_rows[0].content_date)

    assert entry.title == "Current Active Reading"


def _compile_statement(statement) -> str:
    return str(statement.compile(dialect=postgresql.dialect(), compile_kwargs={"literal_binds": True}))
