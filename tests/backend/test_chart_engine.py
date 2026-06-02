from datetime import date, time
from decimal import Decimal

from backend.services.chart_engine import BirthData, calculate_natal_chart


def test_calculate_natal_chart_returns_core_keys():
    result = calculate_natal_chart(
        BirthData(
            birth_date=date(1994, 6, 14),
            birth_time=time(8, 30),
            unknown_time=False,
            birth_lat=Decimal("-33.8688"),
            birth_lng=Decimal("151.2093"),
            timezone="Australia/Sydney",
        )
    )

    assert "sun_sign" in result
    assert "planets" in result
    assert "aspects" in result
