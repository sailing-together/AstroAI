from fastapi.testclient import TestClient

from tests.backend.test_api_contracts import load_app


def test_sun_sign_utility_is_public_and_deterministic(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/utils/sun-sign", params={"birth_date": "1994-06-14"})

    assert response.status_code == 200
    assert response.json() == {
        "birth_date": "1994-06-14",
        "sun_sign": "Gemini",
    }


def test_sun_sign_utility_handles_capricorn_year_boundary(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/utils/sun-sign", params={"birth_date": "2026-01-05"})

    assert response.status_code == 200
    assert response.json()["sun_sign"] == "Capricorn"
