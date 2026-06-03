from datetime import date

from backend.services.codex_static_seed_loader import load_codex_static_seed
from backend.services.static_horoscope_repository import StaticHoroscopeRepository


def test_codex_static_seed_file_loads_preview_copy():
    seed = load_codex_static_seed("gemini", 2026)

    assert seed is not None
    assert seed.yearly[0].title == "Gemini 2026: A Year of Clearer Signals"
    assert "curiosity into commitments" in seed.yearly[0].summary
    assert seed.daily[0].content_date == date(2026, 1, 1)


def test_static_repository_prefers_codex_static_seed_copy():
    repository = StaticHoroscopeRepository()

    yearly = repository.build_entry("gemini", "yearly", "general", date(2026, 1, 1))
    daily = repository.build_entry("gemini", "daily", "general", date(2026, 1, 1))

    assert yearly.title == "Gemini 2026: A Year of Clearer Signals"
    assert "Codex dev seed" not in yearly.summary
    assert daily.title == "Gemini Daily Reset"
