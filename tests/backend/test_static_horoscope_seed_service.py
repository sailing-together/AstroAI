import asyncio

import pytest

from backend.services.static_horoscope_seed_service import (
    StaticHoroscopeSeedService,
    static_horoscope_identity,
)
from backend.services.zodiac import VALID_SIGNS


def test_seed_service_builds_full_year_rows_for_all_signs():
    service = StaticHoroscopeSeedService()

    rows = service.build_rows(year=2026)

    assert len(rows) == 3879 * len(VALID_SIGNS)
    assert {row.sign for row in rows} == set(VALID_SIGNS)
    assert all(row.source == "codex-dev" for row in rows)
    assert all(row.generation_model == "codex-dev" for row in rows)


def test_seed_service_builds_rows_for_selected_signs():
    service = StaticHoroscopeSeedService()

    rows = service.build_rows(year=2026, signs=["Gemini"])

    assert len(rows) == 3879
    assert {row.sign for row in rows} == {"gemini"}


def test_static_horoscope_identity_matches_versioned_upsert_key():
    row = StaticHoroscopeSeedService().build_rows(year=2026, signs=["gemini"])[0]

    assert static_horoscope_identity(row) == (
        row.sign,
        row.target_year,
        row.period,
        row.focus,
        row.content_date,
        row.content_version,
    )


def test_seed_service_rejects_duplicate_versioned_identities():
    service = StaticHoroscopeSeedService()
    row = service.build_rows(year=2026, signs=["gemini"])[0]

    with pytest.raises(ValueError, match="Duplicate static horoscope seed identity"):
        service.validate_unique_identities([row, row])


def test_seed_service_persists_rows_through_injected_writer():
    writer = RecordingSeedWriter()
    service = StaticHoroscopeSeedService()

    result = asyncio.run(service.seed(writer=writer, year=2026, signs=["gemini"]))

    assert result.year == 2026
    assert result.signs == ("gemini",)
    assert result.row_count == 3879
    assert result.persisted_count == 3879
    assert len(writer.rows) == 3879


class RecordingSeedWriter:
    def __init__(self) -> None:
        self.rows = []

    async def upsert_rows(self, rows):
        self.rows = list(rows)
        return len(self.rows)
