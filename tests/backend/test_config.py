import importlib


def load_config(monkeypatch):
    monkeypatch.setenv("GEMINI_API_KEY", "test")
    monkeypatch.setenv("SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setenv("SUPABASE_ANON_KEY", "anon")
    monkeypatch.setenv("SUPABASE_SERVICE_ROLE_KEY", "service")
    monkeypatch.setenv("SUPABASE_JWT_SECRET", "secret")
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost:5432/db")
    monkeypatch.setenv("REDIS_URL", "redis://localhost:6379/0")
    module = importlib.import_module("backend.core.config")
    return importlib.reload(module)


def test_settings_defaults_to_gemini_25_models(monkeypatch):
    config = load_config(monkeypatch)

    settings = config.Settings(
        gemini_api_key="test",
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon",
        supabase_service_role_key="service",
        supabase_jwt_secret="secret",
        database_url="postgresql+asyncpg://user:pass@localhost:5432/db",
        redis_url="redis://localhost:6379/0",
    )

    assert settings.gemini_primary_model == "gemini-2.5-flash"
    assert settings.gemini_light_model == "gemini-2.5-flash-lite"
    assert settings.ai_chat_free_daily_limit == 3
    assert settings.ai_chat_premium_daily_limit == 50


def test_frontend_cors_origins_are_parsed_from_csv(monkeypatch):
    config = load_config(monkeypatch)

    settings = config.Settings(
        gemini_api_key="test",
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon",
        supabase_service_role_key="service",
        supabase_jwt_secret="secret",
        database_url="postgresql+asyncpg://user:pass@localhost:5432/db",
        redis_url="redis://localhost:6379/0",
        backend_cors_origins="http://localhost:3000,https://astroai.example",
    )

    assert settings.cors_origins == ["http://localhost:3000", "https://astroai.example"]
