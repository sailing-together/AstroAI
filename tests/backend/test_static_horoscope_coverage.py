from datetime import date

from backend.services.static_horoscope_coverage import (
    expected_static_horoscope_counts,
    expected_static_horoscope_total,
    validate_static_horoscope_coverage,
)
from backend.services.static_horoscope_dev_importer import build_static_horoscope_rows
from backend.services.zodiac import VALID_SIGNS


def test_expected_static_horoscope_counts_for_2026():
    assert expected_static_horoscope_counts(2026) == {
        "yearly": 9,
        "monthly": 108,
        "weekly": 477,
        "daily": 3285,
    }
    assert expected_static_horoscope_total(2026, signs=VALID_SIGNS) == 46548


def test_static_horoscope_coverage_passes_for_complete_sign_rows():
    rows = build_static_horoscope_rows(signs=["gemini"], year=2026)

    result = validate_static_horoscope_coverage(rows, signs=["gemini"], year=2026)

    assert result.is_complete is True
    assert result.expected_total == 3879
    assert result.actual_total == 3879
    assert result.missing == []


def test_static_horoscope_coverage_reports_missing_focus_date_detail():
    rows = [
        row
        for row in build_static_horoscope_rows(signs=["gemini"], year=2026)
        if not (row.period == "daily" and row.focus == "general" and row.content_date == date(2026, 6, 2))
    ]

    result = validate_static_horoscope_coverage(rows, signs=["gemini"], year=2026)

    assert result.is_complete is False
    assert result.expected_total == 3879
    assert result.actual_total == 3878
    assert {
        "sign": "gemini",
        "period": "daily",
        "focus": "general",
        "content_date": "2026-06-02",
    } in result.missing
