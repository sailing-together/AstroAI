from datetime import date
from pathlib import Path

from backend.services.codex_static_seed_loader import load_codex_static_seed
from backend.services.static_horoscope_repository import StaticHoroscopeRepository


ROOT = Path(__file__).resolve().parents[2]
SEED_DIR = ROOT / "backend" / "static" / "seed" / "horoscopes" / "2026"


def test_codex_static_seed_file_uses_zodiac_name_not_provider_name():
    assert (SEED_DIR / "sign-gemini.json").exists()
    assert not (SEED_DIR / "gemini.json").exists()
    assert not (SEED_DIR / "zodiac-gemini.json").exists()


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


def test_static_repository_fallback_copy_is_reader_facing():
    repository = StaticHoroscopeRepository()
    year_seed = repository.get_or_create_year("gemini", 2026)

    entries = [*year_seed.monthly, *year_seed.weekly, *year_seed.daily]
    assert entries
    for entry in entries:
        text = f"{entry.title} {entry.summary} {entry.body}"
        assert "Codex dev seed" not in text
        assert "development seed" not in text
