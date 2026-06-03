import json
from datetime import date, datetime
from pathlib import Path

from backend.services.codex_dev_horoscope_seed import (
    CODEX_DEV_GENERATED_AT,
    CODEX_DEV_GENERATION_MODEL,
    CODEX_DEV_KNOWLEDGE_VERSION,
    CODEX_DEV_PROMPT_VERSION,
    CODEX_DEV_SOURCE,
    CodexDevHoroscopeSeedEntry,
    CodexDevHoroscopeYearSeed,
)
from backend.services.static_horoscope_calendar import period_end_date


SEED_ROOT = Path(__file__).resolve().parents[1] / "static" / "seed" / "horoscopes"


def load_codex_static_seed(sign: str, year: int) -> CodexDevHoroscopeYearSeed | None:
    seed_path = SEED_ROOT / str(year) / f"sign-{sign}.json"
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
            target_year=payload["year"],
            period=period,
            focus=item["focus"],
            content_date=date.fromisoformat(item["date"]),
            period_end_date=period_end_date(date.fromisoformat(item["date"]), period),
            title=item["title"],
            summary=item["summary"],
            body=item["body"],
            lucky_numbers=item.get("lucky_numbers", [3, 14, 22]),
            lucky_color=item.get("lucky_color", "Yellow"),
            source=item.get("source", CODEX_DEV_SOURCE),
            generation_model=item.get("generation_model", CODEX_DEV_GENERATION_MODEL),
            prompt_version=item.get("prompt_version", CODEX_DEV_PROMPT_VERSION),
            knowledge_version=item.get("knowledge_version", CODEX_DEV_KNOWLEDGE_VERSION),
            content_version=item.get("content_version", 1),
            is_active=item.get("is_active", True),
            generated_at=_parse_generated_at(item.get("generated_at")),
        )
        for item in payload.get(period, [])
    ]


def _parse_generated_at(value: str | None) -> datetime:
    if value is None:
        return CODEX_DEV_GENERATED_AT
    return datetime.fromisoformat(value.replace("Z", "+00:00"))
