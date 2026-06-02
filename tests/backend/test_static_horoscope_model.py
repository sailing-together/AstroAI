from datetime import date, datetime, timezone

from backend.database.models_static_horoscope import StaticHoroscope
from backend.schemas.horoscope import (
    SUPPORTED_HOROSCOPE_FOCUSES,
    HoroscopeDimension,
    HoroscopeEntryResponse,
)


def test_static_horoscope_model_keeps_content_identity_fields():
    row = StaticHoroscope(
        sign="gemini",
        period="daily",
        focus="general",
        content_date=date(2026, 6, 2),
        title="A focused title",
        summary="Short scannable summary.",
        body="Full horoscope copy.",
        lucky_numbers=[3, 14, 22],
        lucky_color="Yellow",
        generation_model="gemini-2.5-flash-lite",
    )

    assert row.sign == "gemini"
    assert row.period == "daily"
    assert row.focus == "general"
    assert row.content_date == date(2026, 6, 2)
    assert row.lucky_numbers == [3, 14, 22]


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
