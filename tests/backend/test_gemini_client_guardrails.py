import importlib

import pytest

from backend.core.finops import AiSpendLimitExceeded


def load_gemini_client(monkeypatch):
    monkeypatch.setenv("GEMINI_API_KEY", "test")
    monkeypatch.setenv("SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setenv("SUPABASE_ANON_KEY", "anon")
    monkeypatch.setenv("SUPABASE_SERVICE_ROLE_KEY", "service")
    monkeypatch.setenv("SUPABASE_JWT_SECRET", "secret")
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost:5432/db")
    monkeypatch.setenv("REDIS_URL", "redis://localhost:6379/0")
    config = importlib.import_module("backend.core.config")
    importlib.reload(config)
    module = importlib.import_module("backend.services.gemini_client")
    return importlib.reload(module).GeminiClient


@pytest.mark.asyncio
async def test_gemini_client_blocks_primary_generation_when_ai_is_disabled(monkeypatch):
    GeminiClient = load_gemini_client(monkeypatch)
    client = GeminiClient(current_spend_aud=lambda: 0)

    def fail_if_provider_is_loaded(_model_name):
        raise AssertionError("provider should not be loaded when AI is disabled")

    monkeypatch.setattr(client, "_model", fail_if_provider_is_loaded)

    with pytest.raises(AiSpendLimitExceeded, match="ai_disabled"):
        await client.generate_primary("hello")


@pytest.mark.asyncio
async def test_gemini_client_blocks_light_generation_when_static_generation_is_disabled(monkeypatch):
    GeminiClient = load_gemini_client(monkeypatch)
    client = GeminiClient(current_spend_aud=lambda: 0)

    def fail_if_provider_is_loaded(_model_name):
        raise AssertionError("provider should not be loaded when static generation is disabled")

    monkeypatch.setattr(client, "_model", fail_if_provider_is_loaded)

    with pytest.raises(AiSpendLimitExceeded, match="static_generation_ai_disabled"):
        await client.generate_light("hello", is_static_generation=True)
