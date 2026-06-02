from datetime import date, datetime, timezone

from backend.schemas.horoscope import (
    HoroscopeDimension,
    HoroscopeEntryResponse,
    HoroscopePeriodResponse,
)
from backend.services.codex_dev_horoscope_seed import (
    CodexDevHoroscopeSeedEntry,
    CodexDevHoroscopeSeedGenerator,
    CodexDevHoroscopeYearSeed,
)
from backend.services.zodiac import sign_label


SUPPORTED_PERIODS = ("daily", "weekly", "monthly", "yearly")
STATIC_GENERATED_AT = datetime(2026, 1, 1, tzinfo=timezone.utc)


class StaticHoroscopeRepository:
    def __init__(self) -> None:
        self._seed_generator = CodexDevHoroscopeSeedGenerator()
        self._year_cache: dict[tuple[str, int], CodexDevHoroscopeYearSeed] = {}

    def get_or_create_year(self, sign: str, year: int) -> CodexDevHoroscopeYearSeed:
        key = (sign, year)
        if key not in self._year_cache:
            self._year_cache[key] = self._seed_generator.generate_year(sign, year)
        return self._year_cache[key]

    def build_entry(self, sign: str, period: str, focus: str, content_date: date) -> HoroscopeEntryResponse:
        year_seed = self.get_or_create_year(sign, content_date.year)
        for entry in _entries_for_period(year_seed, period):
            if entry.focus == focus and entry.content_date == content_date:
                return _to_entry_response(entry)

        return _to_entry_response(
            self._seed_generator.generate_entry(
                sign=sign,
                period=period,
                focus=focus,
                content_date=content_date,
            )
        )

    def build_period(self, sign: str, period: str, content_date: date) -> HoroscopePeriodResponse:
        year_seed = self.get_or_create_year(sign, content_date.year)
        entries = [
            _to_entry_response(entry)
            for entry in _entries_for_period(year_seed, period)
            if entry.content_date == content_date
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
        return [_to_entry_response(entry) for entry in _entries_for_period(self.get_or_create_year(sign, year), period)]


def _entries_for_period(year_seed: CodexDevHoroscopeYearSeed, period: str) -> list[CodexDevHoroscopeSeedEntry]:
    if period == "yearly":
        return year_seed.yearly
    if period == "monthly":
        return year_seed.monthly
    if period == "weekly":
        return year_seed.weekly
    if period == "daily":
        return year_seed.daily
    raise ValueError(f"Unsupported horoscope period: {period}")


def _to_entry_response(entry: CodexDevHoroscopeSeedEntry) -> HoroscopeEntryResponse:
    return HoroscopeEntryResponse(
        sign=sign_label(entry.sign),
        period=entry.period,
        date=entry.content_date.isoformat(),
        focus=entry.focus,
        title=entry.title,
        summary=entry.summary,
        body=entry.body,
        lucky_numbers=entry.lucky_numbers,
        lucky_color=entry.lucky_color,
        generated_at=entry.generated_at,
    )
