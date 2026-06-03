from datetime import date, datetime, timezone

from backend.database.models_static_horoscope import StaticHoroscope
from backend.schemas.horoscope import (
    SUPPORTED_HOROSCOPE_FOCUSES,
    HoroscopeDimension,
    HoroscopeEntryResponse,
)


def test_static_horoscope_model_keeps_content_identity_and_generation_metadata():
    row = StaticHoroscope(
        sign="gemini",
        target_year=2026,
        period="weekly",
        focus="general",
        content_date=date(2025, 12, 29),
        period_end_date=date(2026, 1, 4),
        title="A focused title",
        summary="Short scannable summary.",
        body="Full horoscope copy.",
        lucky_numbers=[3, 14, 22],
        lucky_color="Yellow",
        source="codex-dev",
        generation_model="codex-dev",
        prompt_version="dev-static-v1",
        knowledge_version="astroai-dev-v1",
        content_version=1,
        is_active=True,
    )

    assert row.sign == "gemini"
    assert row.target_year == 2026
    assert row.period == "weekly"
    assert row.focus == "general"
    assert row.content_date == date(2025, 12, 29)
    assert row.period_end_date == date(2026, 1, 4)
    assert row.lucky_numbers == [3, 14, 22]
    assert row.source == "codex-dev"
    assert row.prompt_version == "dev-static-v1"
    assert row.knowledge_version == "astroai-dev-v1"
    assert row.content_version == 1
    assert row.is_active is True


def test_horoscope_entry_response_matches_public_contract():
    response = HoroscopeEntryResponse(
        sign="Gemini",
        period="daily",
        date="2026-06-02",
        focus="general",
        title="A focused title",
        summary="Short scannable summary.",
        body="Full horoscope copy.",
        lucky_numbers=[3, 14, 22],
        lucky_color="Yellow",
        generated_at=datetime(2026, 6, 2, tzinfo=timezone.utc),
    )

    assert response.model_dump()["sign"] == "Gemini"
    assert response.model_dump()["lucky_numbers"] == [3, 14, 22]


def test_horoscope_entry_response_exposes_static_metadata():
    response = HoroscopeEntryResponse(
        sign="Gemini",
        target_year=2026,
        period="weekly",
        date="2025-12-29",
        period_end_date="2026-01-04",
        focus="general",
        title="A focused title",
        summary="Short scannable summary.",
        body="Full horoscope copy.",
        lucky_numbers=[3, 14, 22],
        lucky_color="Yellow",
        source="static",
        generated_at=datetime(2026, 1, 1, tzinfo=timezone.utc),
    )

    payload = response.model_dump()
    assert payload["target_year"] == 2026
    assert payload["period_end_date"] == "2026-01-04"
    assert payload["source"] == "static"


def test_supported_horoscope_dimensions_match_source_of_truth():
    assert SUPPORTED_HOROSCOPE_FOCUSES == (
        "general",
        "love",
        "career",
        "money",
        "wellness",
        "social",
        "family",
        "study",
        "mood_energy",
    )
    assert HoroscopeDimension(title="Title", summary="Summary", body="Body").title == "Title"
