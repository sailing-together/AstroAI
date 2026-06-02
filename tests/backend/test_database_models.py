from backend.database.models_natal_chart import NatalChart
from backend.database.models_user import User


def test_user_tier_default_is_free():
    user = User(auth_id="00000000-0000-0000-0000-000000000001", email="a@example.com")

    assert user.tier == "free"


def test_natal_chart_has_expected_json_fields():
    chart = NatalChart(
        user_id="00000000-0000-0000-0000-000000000001",
        birth_date="1994-06-14",
        unknown_time=False,
        birth_place_name="Sydney, Australia",
        birth_lat=-33.8688,
        birth_lng=151.2093,
        timezone="Australia/Sydney",
        sun_sign="gemini",
        planets=[],
        houses=[],
        aspects=[],
        chart_hash="hash",
    )

    assert chart.planets == []
    assert chart.houses == []
    assert chart.aspects == []
