from fastapi.testclient import TestClient

from backend.services.static_horoscope_dev_importer import build_static_horoscope_rows
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


def test_horoscope_bundle_is_public_static_content(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/horoscope/bundle/gemini", params={"year": 2026})

    assert response.status_code == 200
    payload = response.json()
    assert payload["sign"] == "Gemini"
    assert payload["year"] == 2026
    assert payload["source"] == "static"
    assert payload["daily"][0]["period"] == "daily"
    assert payload["daily"][0]["focus"] == "general"


def test_horoscope_bundle_reads_persisted_rows_when_available(monkeypatch):
    app = load_app(monkeypatch)
    from backend.api.v1 import horoscope as horoscope_api
    from backend.database.session import get_db_session

    rows = build_static_horoscope_rows(signs=["gemini"], year=2026)
    rows[0].title = "Persisted yearly guidance"
    rows[9 + 108 + 477].title = "Persisted daily guidance"

    class FakeStore:
        def __init__(self) -> None:
            self.calls: list[tuple[object, str, int]] = []

        async def fetch_year_rows(self, session: object, sign: str, target_year: int):
            self.calls.append((session, sign, target_year))
            return rows

    fake_session = object()
    fake_store = FakeStore()

    async def override_session():
        yield fake_session

    app.dependency_overrides[get_db_session] = override_session
    app.dependency_overrides[horoscope_api.get_static_horoscope_store] = lambda: fake_store
    client = TestClient(app)

    response = client.get("/api/v1/horoscope/bundle/gemini", params={"year": 2026})

    assert response.status_code == 200
    payload = response.json()
    assert fake_store.calls == [(fake_session, "gemini", 2026)]
    assert payload["yearly"][0]["title"] == "Persisted yearly guidance"
    assert payload["daily"][0]["title"] == "Persisted daily guidance"


def test_daily_horoscope_returns_all_dimensions_when_focus_is_omitted(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/horoscope/daily/gemini", params={"date": "2026-06-02"})

    assert response.status_code == 200
    payload = response.json()
    assert payload["sign"] == "Gemini"
    assert payload["period"] == "daily"
    assert payload["date"] == "2026-06-02"
    assert payload["source"] == "static"
    assert set(payload["dimensions"].keys()) == {
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


def test_daily_horoscope_can_return_a_single_focus(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get(
        "/api/v1/horoscope/daily/gemini",
        params={"date": "2026-06-02", "focus": "love"},
    )

    assert response.status_code == 200
    assert response.json()["focus"] == "love"
    assert response.json()["title"]


def test_monthly_horoscope_accepts_year_month_query(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/horoscope/monthly/gemini", params={"month": "2026-06"})

    assert response.status_code == 200
    assert response.json()["period"] == "monthly"
    assert response.json()["date"] == "2026-06-01"


def test_weekly_horoscope_accepts_iso_week_query(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/horoscope/weekly/gemini", params={"week": "2026-W23"})

    assert response.status_code == 200
    assert response.json()["period"] == "weekly"
    assert response.json()["date"] == "2026-06-01"


def test_horoscope_rejects_unknown_sign(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/horoscope/daily/notasign", params={"date": "2026-06-02"})

    assert response.status_code == 422


def test_bundle_contains_full_2026_static_coverage(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/horoscope/bundle/gemini", params={"year": 2026})

    assert response.status_code == 200
    payload = response.json()
    assert len(payload["yearly"]) == 9
    assert len(payload["monthly"]) == 108
    assert len(payload["weekly"]) == 477
    assert len(payload["daily"]) == 3285
    assert payload["weekly"][0]["date"] == "2025-12-29"
    assert payload["weekly"][0]["period_end_date"] == "2026-01-04"


def test_weekly_horoscope_maps_selected_date_to_intersecting_week(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get(
        "/api/v1/horoscope/weekly/gemini",
        params={"week": "2026-01-01"},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["period"] == "weekly"
    assert payload["date"] == "2025-12-29"
    assert payload["period_end_date"] == "2026-01-04"
