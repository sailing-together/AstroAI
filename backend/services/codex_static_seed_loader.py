import json
from datetime import date, datetime
from pathlib import Path

from backend.services.codex_dev_horoscope_seed import (
    CODEX_DEV_GENERATED_AT,
    CODEX_DEV_GENERATION_MODEL,
    CodexDevHoroscopeSeedEntry,
    CodexDevHoroscopeYearSeed,
)


SEED_ROOT = Path(__file__).resolve().parents[1] / "static" / "seed" / "horoscopes"


def load_codex_static_seed(sign: str, year: int) -> CodexDevHoroscopeYearSeed | None:
    seed_path = SEED_ROOT / str(year) / f"zodiac-{sign}.json"
    if not seed_path.exists():
        return None

    payload = json.loads(seed_path.read_text(encoding="utf-8"))
    return CodexDevHoroscopeYearSeed(
        sign=payload["sign"],
        year=payload["year"],
        yearly=_entries(payload, "yearly"),
        monthly=_entries(payload, "monthly"),
        weekly=_entries(payload, "weekly"),
        daily=_entries(payload, "daily"),
    )


def _entries(payload: dict, period: str) -> list[CodexDevHoroscopeSeedEntry]:
    return [
        CodexDevHoroscopeSeedEntry(
            sign=payload["sign"],
            period=period,
            focus=item["focus"],
            content_date=date.fromisoformat(item["date"]),
            title=item["title"],
            summary=item["summary"],
            body=item["body"],
            lucky_numbers=item.get("lucky_numbers", [3, 14, 22]),
            lucky_color=item.get("lucky_color", "Yellow"),
            generation_model=item.get("generation_model", CODEX_DEV_GENERATION_MODEL),
            generated_at=_parse_generated_at(item.get("generated_at")),
        )
        for item in payload.get(period, [])
    ]


def _parse_generated_at(value: str | None) -> datetime:
    if value is None:
        return CODEX_DEV_GENERATED_AT
    return datetime.fromisoformat(value.replace("Z", "+00:00"))
