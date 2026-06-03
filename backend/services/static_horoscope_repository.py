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
from backend.services.codex_static_seed_loader import load_codex_static_seed
from backend.services.static_horoscope_calendar import period_start_for_selected_date
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
            self._year_cache[key] = _merge_year_seed(
                generated=self._seed_generator.generate_year(sign, year),
                authored=load_codex_static_seed(sign, year),
            )
        return self._year_cache[key]

    def build_entry(self, sign: str, period: str, focus: str, content_date: date) -> HoroscopeEntryResponse:
        year_seed = self.get_or_create_year(sign, content_date.year)
        found_entry = _find_entry(year_seed, period, focus, content_date)
        if found_entry is not None:
            return _to_entry_response(found_entry)

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
        return _to_period_response(sign, period, content_date, _matching_entries(year_seed, period, content_date))

    def build_period_for_selected_date(
        self,
        sign: str,
        period: str,
        selected_date: date,
    ) -> HoroscopePeriodResponse:
        content_date = period_start_for_selected_date(selected_date, period)
        year_seed = self.get_or_create_year(sign, selected_date.year)
        return _to_period_response(sign, period, content_date, _matching_entries(year_seed, period, content_date))

    def build_entry_for_selected_date(
        self,
        sign: str,
        period: str,
        focus: str,
        selected_date: date,
    ) -> HoroscopeEntryResponse:
        content_date = period_start_for_selected_date(selected_date, period)
        year_seed = self.get_or_create_year(sign, selected_date.year)
        found_entry = _find_entry(year_seed, period, focus, content_date)
        if found_entry is not None:
            return _to_entry_response(found_entry)
        return _to_entry_response(
            self._seed_generator.generate_entry(
                sign=sign,
                period=period,
                focus=focus,
                content_date=content_date,
                target_year=selected_date.year,
            )
        )

    def validate_year_coverage(self, sign: str, year: int) -> dict[str, int]:
        year_seed = self.get_or_create_year(sign, year)
        return {
            "yearly": len(year_seed.yearly),
            "monthly": len(year_seed.monthly),
            "weekly": len(year_seed.weekly),
            "daily": len(year_seed.daily),
        }

    def build_year_entries(self, sign: str, year: int, period: str) -> list[HoroscopeEntryResponse]:
        return [_to_entry_response(entry) for entry in _entries_for_period(self.get_or_create_year(sign, year), period)]


def _matching_entries(
    year_seed: CodexDevHoroscopeYearSeed,
    period: str,
    content_date: date,
) -> list[HoroscopeEntryResponse]:
    return [
        _to_entry_response(entry)
        for entry in _entries_for_period(year_seed, period)
        if entry.content_date == content_date
    ]


def _find_entry(
    year_seed: CodexDevHoroscopeYearSeed,
    period: str,
    focus: str,
    content_date: date,
) -> CodexDevHoroscopeSeedEntry | None:
    for entry in _entries_for_period(year_seed, period):
        if entry.focus == focus and entry.content_date == content_date:
            return entry
    return None


def _to_period_response(
    sign: str,
    period: str,
    content_date: date,
    entries: list[HoroscopeEntryResponse],
) -> HoroscopePeriodResponse:
    period_end = entries[0].period_end_date if entries else None
    target_year = entries[0].target_year if entries else content_date.year
    return HoroscopePeriodResponse(
        sign=sign_label(sign),
        target_year=target_year,
        period=period,
        date=content_date.isoformat(),
        period_end_date=period_end,
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
        target_year=entry.target_year,
        period=entry.period,
        date=entry.content_date.isoformat(),
        period_end_date=entry.period_end_date.isoformat(),
        focus=entry.focus,
        title=entry.title,
        summary=entry.summary,
        body=entry.body,
        lucky_numbers=entry.lucky_numbers,
        lucky_color=entry.lucky_color,
        source="static",
        generated_at=entry.generated_at,
    )


def _merge_year_seed(
    generated: CodexDevHoroscopeYearSeed,
    authored: CodexDevHoroscopeYearSeed | None,
) -> CodexDevHoroscopeYearSeed:
    if authored is None:
        return generated
    return CodexDevHoroscopeYearSeed(
        sign=generated.sign,
        year=generated.year,
        yearly=_merge_entries(generated.yearly, authored.yearly),
        monthly=_merge_entries(generated.monthly, authored.monthly),
        weekly=_merge_entries(generated.weekly, authored.weekly),
        daily=_merge_entries(generated.daily, authored.daily),
    )


def _merge_entries(
    generated: list[CodexDevHoroscopeSeedEntry],
    authored: list[CodexDevHoroscopeSeedEntry],
) -> list[CodexDevHoroscopeSeedEntry]:
    authored_by_key = {(entry.content_date, entry.focus): entry for entry in authored}
    return [authored_by_key.get((entry.content_date, entry.focus), entry) for entry in generated]
