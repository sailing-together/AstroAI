import gzip
import json
from datetime import date, datetime
from pathlib import Path
from typing import Any

from backend.database.models_static_horoscope import StaticHoroscope
from backend.services.static_horoscope_coverage import StaticHoroscopeCoverageResult, validate_static_horoscope_coverage


def load_static_horoscope_ndjson(path: Path | str) -> list[StaticHoroscope]:
    source_path = Path(path)
    opener = gzip.open if source_path.suffix == ".gz" else open
    rows: list[StaticHoroscope] = []
    with opener(source_path, "rt", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            if not line.strip():
                continue
            try:
                rows.append(_row_from_json(json.loads(line)))
            except (TypeError, ValueError, KeyError) as exc:
                raise ValueError(f"Invalid static horoscope NDJSON row {line_number} in {source_path}: {exc}") from exc
    return rows


def validate_static_horoscope_ndjson(
    path: Path | str,
    year: int,
    signs: tuple[str, ...],
) -> StaticHoroscopeCoverageResult:
    return validate_static_horoscope_coverage(load_static_horoscope_ndjson(path), signs=signs, year=year)


def _row_from_json(payload: dict[str, Any]) -> StaticHoroscope:
    return StaticHoroscope(
        id=payload["id"],
        sign=payload["sign"],
        target_year=int(payload["target_year"]),
        period=payload["period"],
        focus=payload["focus"],
        content_date=_parse_date(payload["content_date"]),
        period_end_date=_parse_optional_date(payload.get("period_end_date")),
        title=payload["title"],
        summary=payload["summary"],
        body=payload["body"],
        lucky_numbers=payload.get("lucky_numbers"),
        lucky_color=payload.get("lucky_color"),
        source=payload["source"],
        generation_model=payload["generation_model"],
        prompt_version=payload.get("prompt_version"),
        knowledge_version=payload.get("knowledge_version"),
        content_version=int(payload["content_version"]),
        is_active=bool(payload["is_active"]),
        generated_at=_parse_datetime(payload.get("generated_at")),
        created_at=_parse_datetime(payload.get("created_at")),
        updated_at=_parse_datetime(payload.get("updated_at")),
    )


def _parse_date(value: str) -> date:
    return date.fromisoformat(value)


def _parse_optional_date(value: str | None) -> date | None:
    return date.fromisoformat(value) if value else None


def _parse_datetime(value: str | None) -> datetime | None:
    return datetime.fromisoformat(value) if value else None
