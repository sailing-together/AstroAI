from collections import Counter
from collections.abc import Iterable, Sequence
from dataclasses import dataclass

from backend.database.models_static_horoscope import StaticHoroscope
from backend.schemas.horoscope import SUPPORTED_HOROSCOPE_FOCUSES
from backend.services.static_horoscope_calendar import period_dates_for_year


@dataclass(frozen=True)
class StaticHoroscopeCoverageResult:
    is_complete: bool
    expected_total: int
    actual_total: int
    expected_counts: dict[str, int]
    actual_counts: dict[str, int]
    missing: list[dict[str, str]]


def expected_static_horoscope_counts(year: int) -> dict[str, int]:
    return {
        "yearly": len(period_dates_for_year(year, "yearly")) * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "monthly": len(period_dates_for_year(year, "monthly")) * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "weekly": len(period_dates_for_year(year, "weekly")) * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "daily": len(period_dates_for_year(year, "daily")) * len(SUPPORTED_HOROSCOPE_FOCUSES),
    }


def expected_static_horoscope_total(year: int, signs: Sequence[str]) -> int:
    return sum(expected_static_horoscope_counts(year).values()) * len(signs)


def validate_static_horoscope_coverage(
    rows: Iterable[StaticHoroscope],
    signs: Sequence[str],
    year: int,
) -> StaticHoroscopeCoverageResult:
    row_list = [row for row in rows if row.is_active and row.target_year == year and row.sign in signs]
    present_keys = {(row.sign, row.period, row.focus, row.content_date) for row in row_list}
    expected_keys = {
        (sign, period, focus, content_date)
        for sign in signs
        for period in ("yearly", "monthly", "weekly", "daily")
        for focus in SUPPORTED_HOROSCOPE_FOCUSES
        for content_date in period_dates_for_year(year, period)
    }
    missing = [
        {
            "sign": sign,
            "period": period,
            "focus": focus,
            "content_date": content_date.isoformat(),
        }
        for sign, period, focus, content_date in sorted(expected_keys - present_keys)
    ]
    actual_counts = Counter(row.period for row in row_list)
    expected_counts = expected_static_horoscope_counts(year)
    expected_total = expected_static_horoscope_total(year, signs)

    return StaticHoroscopeCoverageResult(
        is_complete=not missing and len(row_list) == expected_total,
        expected_total=expected_total,
        actual_total=len(row_list),
        expected_counts=expected_counts,
        actual_counts={period: actual_counts.get(period, 0) for period in expected_counts},
        missing=missing,
    )
