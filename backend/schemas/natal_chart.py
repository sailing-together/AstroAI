from datetime import date, datetime, time
from decimal import Decimal

from pydantic import BaseModel, Field


class NatalChartRequest(BaseModel):
    birth_date: date
    birth_time: time | None = None
    unknown_time: bool = False
    birth_place_name: str
    birth_lat: Decimal
    birth_lng: Decimal
    timezone: str


class NatalChartResponse(BaseModel):
    id: str
    sun_sign: str
    moon_sign: str | None = None
    ascendant_sign: str | None = None
    unknown_time: bool
    planets: list[dict] = Field(default_factory=list)
    houses: list[dict] | None = None
    aspects: list[dict] = Field(default_factory=list)
    interpretation: dict | None = None
    created_at: datetime
    updated_at: datetime
