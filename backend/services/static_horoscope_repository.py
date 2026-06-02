from calendar import monthrange
from datetime import date, datetime, timedelta, timezone

from backend.schemas.horoscope import (
    SUPPORTED_HOROSCOPE_FOCUSES,
    HoroscopeDimension,
    HoroscopeEntryResponse,
    HoroscopePeriodResponse,
)
from backend.services.zodiac import sign_label


SUPPORTED_PERIODS = ("daily", "weekly", "monthly", "yearly")
STATIC_GENERATED_AT = datetime(2026, 1, 1, tzinfo=timezone.utc)


class StaticHoroscopeRepository:
    def build_entry(self, sign: str, period: str, focus: str, content_date: date) -> HoroscopeEntryResponse:
        label = sign_label(sign)
        focus_label = focus.replace("_", " ").title()
        return HoroscopeEntryResponse(
            sign=label,
            period=period,
            date=content_date.isoformat(),
            focus=focus,
            title=f"{label} {focus_label} {period.title()} Guidance",
            summary=f"Static {period} {focus} guidance for {label}.",
            body=f"{label} receives stored {period} {focus} guidance for {content_date.isoformat()}.",
            lucky_numbers=[3, 14, 22],
            lucky_color="Yellow",
            generated_at=STATIC_GENERATED_AT,
        )

    def build_period(self, sign: str, period: str, content_date: date) -> HoroscopePeriodResponse:
        entries = [
            self.build_entry(sign=sign, period=period, focus=focus, content_date=content_date)
            for focus in SUPPORTED_HOROSCOPE_FOCUSES
        ]
        return HoroscopePeriodResponse(
            sign=sign_label(sign),
            period=period,
            date=content_date.isoformat(),
            dimensions={
                entry.focus: HoroscopeDimension(
                    title=entry.title,
                    summary=entry.summary,
                    body=entry.body,
                    lucky_numbers=entry.lucky_numbers,
                    lucky_color=entry.lucky_color,
                )
                for entry in entries
            },
            generated_at=STATIC_GENERATED_AT,
        )

    def build_year_entries(self, sign: str, year: int, period: str) -> list[HoroscopeEntryResponse]:
        dates = _period_dates_for_year(year, period)
        return [
            self.build_entry(sign=sign, period=period, focus=focus, content_date=content_date)
            for content_date in dates
            for focus in SUPPORTED_HOROSCOPE_FOCUSES
        ]


def _period_dates_for_year(year: int, period: str) -> list[date]:
    if period == "yearly":
        return [date(year, 1, 1)]
    if period == "monthly":
        return [date(year, month, 1) for month in range(1, 13)]
    if period == "weekly":
        first = date(year, 1, 1)
        first_monday = first + timedelta(days=(7 - first.weekday()) % 7)
        dates = []
        current = first_monday
        while current.year == year:
            dates.append(current)
            current += timedelta(days=7)
        return dates
    if period == "daily":
        dates = []
        for month in range(1, 13):
            for day in range(1, monthrange(year, month)[1] + 1):
                dates.append(date(year, month, day))
        return dates
    raise ValueError(f"Unsupported horoscope period: {period}")
