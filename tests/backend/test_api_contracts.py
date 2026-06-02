import importlib

from fastapi.testclient import TestClient


def load_app(monkeypatch):
    monkeypatch.setenv("GEMINI_API_KEY", "test")
    monkeypatch.setenv("SUPABASE_URL", "https://example.supabase.co")
    monkeypatch.setenv("SUPABASE_ANON_KEY", "anon")
    monkeypatch.setenv("SUPABASE_SERVICE_ROLE_KEY", "service")
    monkeypatch.setenv("SUPABASE_JWT_SECRET", "secret")
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://user:pass@localhost:5432/db")
    monkeypatch.setenv("REDIS_URL", "redis://localhost:6379/0")
    module = importlib.import_module("backend.main")
    return importlib.reload(module).app


def test_health_endpoint_uses_api_v1_prefix(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_users_me_requires_authentication(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/users/me")

    assert response.status_code == 401


def test_natal_chart_requires_authentication(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/users/me/natal-chart")

    assert response.status_code == 401
