from datetime import date

from backend.schemas.horoscope import SUPPORTED_HOROSCOPE_FOCUSES
from backend.services.static_horoscope_repository import StaticHoroscopeRepository


def test_static_repository_reuses_first_load_codex_dev_seed():
    repository = StaticHoroscopeRepository()

    first = repository.get_or_create_year("gemini", 2026)
    second = repository.get_or_create_year("gemini", 2026)

    assert first is second
    assert first.daily[0].generation_model == "codex-dev"
    assert len(first.daily) == 365 * 9


def test_static_repository_validates_2026_bundle_coverage():
    repository = StaticHoroscopeRepository()

    coverage = repository.validate_year_coverage("gemini", 2026)

    assert coverage == {
        "yearly": 1 * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "monthly": 12 * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "weekly": 53 * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "daily": 365 * len(SUPPORTED_HOROSCOPE_FOCUSES),
    }


def test_static_repository_maps_selected_date_to_matching_week():
    repository = StaticHoroscopeRepository()

    period = repository.build_period_for_selected_date("gemini", "weekly", date(2026, 1, 1))

    assert period.period == "weekly"
    assert period.date == "2025-12-29"
    assert period.period_end_date == "2026-01-04"
    assert set(period.dimensions.keys()) == set(SUPPORTED_HOROSCOPE_FOCUSES)
