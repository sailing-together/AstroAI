import importlib


def load_generator_module(monkeypatch):
    monkeypatch.setenv("GEMINI_API_KEY", "test")
    monkeypatch.setenv("SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setenv("SUPABASE_ANON_KEY", "anon")
    monkeypatch.setenv("SUPABASE_SERVICE_ROLE_KEY", "service")
    monkeypatch.setenv("SUPABASE_JWT_SECRET", "secret")
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost:5432/db")
    monkeypatch.setenv("REDIS_URL", "redis://localhost:6379/0")
    module = importlib.import_module("backend.services.static_horoscope_generator")
    return importlib.reload(module)


def test_static_horoscope_generator_uses_flash_lite(monkeypatch):
    module = load_generator_module(monkeypatch)
    generator = module.StaticHoroscopeGenerator()

    assert generator.model_name == "gemini-2.5-flash-lite"


def test_static_horoscope_generator_builds_one_payload_per_focus(monkeypatch):
    module = load_generator_module(monkeypatch)
    generator = module.StaticHoroscopeGenerator()

    payloads = generator.build_generation_payloads(
        module.HoroscopeGenerationRequest(sign="gemini", period="daily", year=2026)
    )

    assert len(payloads) == 9
    assert {payload.focus for payload in payloads} == {
        "general",
        "love",
        "career",
        "money",
        "wellness",
        "social",
        "family",
        "study",
        "mood_energy",
    }
    assert all(payload.model_name == "gemini-2.5-flash-lite" for payload in payloads)
