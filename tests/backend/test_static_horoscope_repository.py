from backend.services.static_horoscope_repository import StaticHoroscopeRepository


def test_static_repository_reuses_first_load_codex_dev_seed():
    repository = StaticHoroscopeRepository()

    first = repository.get_or_create_year("gemini", 2026)
    second = repository.get_or_create_year("gemini", 2026)

    assert first is second
    assert first.daily[0].generation_model == "codex-dev"
    assert len(first.daily) == 365 * 9
