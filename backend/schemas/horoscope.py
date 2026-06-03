from datetime import datetime

from pydantic import BaseModel, Field


SUPPORTED_HOROSCOPE_FOCUSES = (
    "general",
    "love",
    "career",
    "money",
    "wellness",
    "social",
    "family",
    "study",
    "mood_energy",
)


class HoroscopeDimension(BaseModel):
    title: str
    summary: str
    body: str
    lucky_numbers: list[int] | None = None
    lucky_color: str | None = None


class HoroscopeEntryResponse(BaseModel):
    sign: str
    target_year: int | None = None
    period: str
    date: str
    period_end_date: str | None = None
    focus: str
    title: str
    summary: str
    body: str
    lucky_numbers: list[int] | None = None
    lucky_color: str | None = None
    source: str = "static"
    generated_at: datetime


class HoroscopePeriodResponse(BaseModel):
    sign: str
    target_year: int | None = None
    period: str
    date: str
    period_end_date: str | None = None
    dimensions: dict[str, HoroscopeDimension]
    source: str = "static"
    generated_at: datetime


class HoroscopeBundleResponse(BaseModel):
    sign: str
    year: int
    yearly: list[HoroscopeEntryResponse] = Field(default_factory=list)
    monthly: list[HoroscopeEntryResponse] = Field(default_factory=list)
    weekly: list[HoroscopeEntryResponse] = Field(default_factory=list)
    daily: list[HoroscopeEntryResponse] = Field(default_factory=list)
    source: str = "static"
    generated_at: datetime | None = None
