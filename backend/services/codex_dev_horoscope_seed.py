from calendar import monthrange
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone

from backend.schemas.horoscope import SUPPORTED_HOROSCOPE_FOCUSES
from backend.services.zodiac import sign_label


CODEX_DEV_GENERATION_MODEL = "codex-dev"
CODEX_DEV_GENERATED_AT = datetime(2026, 1, 1, tzinfo=timezone.utc)

FOCUS_COPY = {
    "general": (
        "Keep the day spacious enough for one clear priority.",
        "The useful move is to simplify the noise around you and give your strongest idea a practical next step.",
    ),
    "love": (
        "Warmth grows through honest timing and steady attention.",
        "Let connection be measured by presence, not performance; a direct question opens more than a clever answer.",
    ),
    "career": (
        "Progress comes from turning a smart idea into repeatable work.",
        "Choose the task that compounds, document what matters, and let consistency make your talent easier to trust.",
    ),
    "money": (
        "Small financial choices become easier when they are visible.",
        "Review the numbers before reacting, then make one clean adjustment that future you will appreciate.",
    ),
    "wellness": (
        "Your energy improves when your nervous system gets fewer interruptions.",
        "Protect sleep, hydration, movement, and pauses; simple recovery habits give your mind more room to breathe.",
    ),
    "social": (
        "The right conversations should sharpen you without draining you.",
        "Spend energy where curiosity feels mutual, and let quieter boundaries make your social life feel more intentional.",
    ),
    "family": (
        "Home feels better when truth arrives calmly and early.",
        "Name what you need without turning it into a debate; steady follow-through matters more than perfect wording.",
    ),
    "study": (
        "Learning sticks when it has structure and a reason to matter.",
        "Break the subject into smaller loops, test what you know, and give your curiosity a clear path to follow.",
    ),
    "mood_energy": (
        "Your mood steadies when you stop chasing every signal at once.",
        "Create a little quiet before choosing your pace; your energy returns when attention has somewhere kind to land.",
    ),
}

PERIOD_LABELS = {
    "yearly": "Yearly",
    "monthly": "Monthly",
    "weekly": "Weekly",
    "daily": "Daily",
}

COLORS = (
    "Sunlit Yellow",
    "Rose Quartz",
    "Ink Blue",
    "Olive Green",
    "Soft Mint",
    "Electric Teal",
    "Warm Cream",
    "Sky Blue",
    "Lavender",
)


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
        period_label = PERIOD_LABELS[period]
        summary, focus_body = FOCUS_COPY[focus]
        cadence = _period_cadence(period, content_date)
        return CodexDevHoroscopeSeedEntry(
            sign=sign,
            period=period,
            focus=focus,
            content_date=content_date,
            title=f"{label} {period_label} {focus_label} Forecast",
            summary=summary,
            body=(
                f"{label}, {cadence} highlights your {focus_label.lower()} rhythm. "
                f"{focus_body} This is static guidance prepared for the yearly bundle, "
                "so you can browse without extra AI calls."
            ),
            lucky_numbers=_lucky_numbers(sign, period, focus, content_date),
            lucky_color=COLORS[SUPPORTED_HOROSCOPE_FOCUSES.index(focus) % len(COLORS)],
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


def _period_cadence(period: str, content_date: date) -> str:
    if period == "yearly":
        return f"{content_date.year}"
    if period == "monthly":
        return content_date.strftime("%B")
    if period == "weekly":
        return f"the week of {content_date.strftime('%B %d')}"
    if period == "daily":
        return content_date.strftime("%B %d")
    raise ValueError(f"Unsupported horoscope period: {period}")


def _lucky_numbers(sign: str, period: str, focus: str, content_date: date) -> list[int]:
    base = sum(ord(character) for character in f"{sign}:{period}:{focus}:{content_date.isoformat()}")
    return [base % 9 + 1, base % 17 + 10, base % 23 + 20]
