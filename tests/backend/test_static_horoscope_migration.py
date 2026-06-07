from pathlib import Path


MIGRATION_PATH = Path("backend/database/migrations/20260605_create_static_horoscopes.sql")


def test_static_horoscope_migration_defines_public_read_table():
    migration = MIGRATION_PATH.read_text(encoding="utf-8")

    assert "create table if not exists public.static_horoscopes" in migration
    assert "sign text not null" in migration
    assert "target_year integer not null" in migration
    assert "period text not null" in migration
    assert "focus text not null" in migration
    assert "content_date date not null" in migration
    assert "period_end_date date" in migration
    assert "lucky_numbers integer[]" in migration
    assert "is_active boolean not null default true" in migration


def test_static_horoscope_migration_preserves_versioned_and_active_identity():
    migration = MIGRATION_PATH.read_text(encoding="utf-8")
    normalized = " ".join(migration.split())

    assert "constraint uq_static_horoscope_versioned_identity" in migration
    assert "unique ( sign, target_year, period, focus, content_date, content_version )" in normalized
    assert "create unique index if not exists uq_static_horoscope_active_identity" in migration
    assert "where is_active = true" in migration


def test_static_horoscope_migration_supports_public_query_paths():
    migration = MIGRATION_PATH.read_text(encoding="utf-8")

    assert "idx_static_horoscopes_active_year" in migration
    assert "(sign, target_year, period, is_active)" in migration
    assert "idx_static_horoscopes_active_entry" in migration
    assert "(sign, target_year, period, content_date, focus)" in migration
