from calendar import monthrange
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone

from backend.schemas.horoscope import SUPPORTED_HOROSCOPE_FOCUSES
from backend.services.zodiac import sign_label


CODEX_DEV_GENERATION_MODEL = "codex-dev"
CODEX_DEV_GENERATED_AT = datetime(2026, 1, 1, tzinfo=timezone.utc)


@dataclass(frozen=True)
class CodexDevHoroscopeSeedEntry:
    sign: str
    period: str
    focus: str
    content_date: date
    title: str
    summary: str
    body: str
    lucky_numbers: list[int]
    lucky_color: str
    generation_model: str
    generated_at: datetime


@dataclass(frozen=True)
class CodexDevHoroscopeYearSeed:
    sign: str
    year: int
    yearly: list[CodexDevHoroscopeSeedEntry]
    monthly: list[CodexDevHoroscopeSeedEntry]
    weekly: list[CodexDevHoroscopeSeedEntry]
    daily: list[CodexDevHoroscopeSeedEntry]


class CodexDevHoroscopeSeedGenerator:
    def generate_year(self, sign: str, year: int) -> CodexDevHoroscopeYearSeed:
        return CodexDevHoroscopeYearSeed(
            sign=sign,
            year=year,
            yearly=self._build_entries(sign, year, "yearly"),
            monthly=self._build_entries(sign, year, "monthly"),
            weekly=self._build_entries(sign, year, "weekly"),
            daily=self._build_entries(sign, year, "daily"),
        )

    def generate_entry(
        self,
        sign: str,
        period: str,
        focus: str,
        content_date: date,
    ) -> CodexDevHoroscopeSeedEntry:
        return self._build_entry(sign, period, focus, content_date)

    def _build_entries(self, sign: str, year: int, period: str) -> list[CodexDevHoroscopeSeedEntry]:
        return [
            self._build_entry(sign, period, focus, content_date)
            for content_date in _period_dates_for_year(year, period)
            for focus in SUPPORTED_HOROSCOPE_FOCUSES
        ]

    def _build_entry(
        self,
        sign: str,
        period: str,
        focus: str,
        content_date: date,
    ) -> CodexDevHoroscopeSeedEntry:
        label = sign_label(sign)
        focus_label = focus.replace("_", " ").title()
        return CodexDevHoroscopeSeedEntry(
            sign=sign,
            period=period,
            focus=focus,
            content_date=content_date,
            title=f"{label} {focus_label} {period.title()} Guidance",
            summary=f"Codex dev seed {period} {focus} guidance for {label}.",
            body=(
                f"{label} receives Codex-authored development seed content for "
                f"{period} {focus} on {content_date.isoformat()}."
            ),
            lucky_numbers=[3, 14, 22],
            lucky_color="Yellow",
            generation_model=CODEX_DEV_GENERATION_MODEL,
            generated_at=CODEX_DEV_GENERATED_AT,
        )


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
        return [
            date(year, month, day)
            for month in range(1, 13)
            for day in range(1, monthrange(year, month)[1] + 1)
        ]
    raise ValueError(f"Unsupported horoscope period: {period}")
