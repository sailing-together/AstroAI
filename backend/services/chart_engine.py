from dataclasses import dataclass
from datetime import date, time
from decimal import Decimal


@dataclass(frozen=True)
class BirthData:
    birth_date: date
    birth_time: time | None
    unknown_time: bool
    birth_lat: Decimal
    birth_lng: Decimal
    timezone: str


def calculate_natal_chart(birth_data: BirthData) -> dict:
    """Return deterministic natal chart data.

    Phase 1 starts with a stable service boundary. The implementation can be
    replaced with full pyswisseph calculations without changing route code.
    """
    return {
        "sun_sign": "gemini",
        "moon_sign": None if birth_data.unknown_time else "pisces",
        "ascendant_sign": None if birth_data.unknown_time else "leo",
        "planets": [],
        "houses": None if birth_data.unknown_time else [],
        "aspects": [],
    }
