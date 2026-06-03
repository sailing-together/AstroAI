from backend.services.codex_dev_horoscope_seed import CodexDevHoroscopeSeedGenerator
from backend.schemas.horoscope import SUPPORTED_HOROSCOPE_FOCUSES


def test_codex_dev_seed_generates_full_year_static_content():
    seed = CodexDevHoroscopeSeedGenerator().generate_year(sign="gemini", year=2026)

    assert seed.sign == "gemini"
    assert seed.year == 2026
    assert len(seed.yearly) == len(SUPPORTED_HOROSCOPE_FOCUSES)
    assert len(seed.monthly) == 12 * len(SUPPORTED_HOROSCOPE_FOCUSES)
    assert len(seed.weekly) == 52 * len(SUPPORTED_HOROSCOPE_FOCUSES)
    assert len(seed.daily) == 365 * len(SUPPORTED_HOROSCOPE_FOCUSES)
    assert seed.daily[0].generation_model == "codex-dev"


def test_codex_dev_seed_is_deterministic_for_same_sign_and_year():
    generator = CodexDevHoroscopeSeedGenerator()

    first = generator.generate_year(sign="gemini", year=2026)
    second = generator.generate_year(sign="gemini", year=2026)

    assert first.daily[0] == second.daily[0]
    assert first.monthly[0].title == "Gemini Monthly General Forecast"


def test_codex_dev_seed_uses_reader_facing_copy():
    seed = CodexDevHoroscopeSeedGenerator().generate_year(sign="gemini", year=2026)
    samples = [seed.monthly[1], seed.weekly[1], seed.daily[1]]

    for entry in samples:
        text = f"{entry.title} {entry.summary} {entry.body}"
        assert "Codex dev seed" not in text
        assert "development seed" not in text
        assert "Gemini" in entry.title
