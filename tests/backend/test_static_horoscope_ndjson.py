import gzip
import json

from backend.services.static_horoscope_ndjson import load_static_horoscope_ndjson, validate_static_horoscope_ndjson
from backend.tasks.seed_static_horoscopes import export_rows_to_ndjson
from backend.services.static_horoscope_seed_service import StaticHoroscopeSeedService


def test_load_static_horoscope_ndjson_reads_plain_and_gzip_exports(tmp_path):
    rows = StaticHoroscopeSeedService().build_rows(year=2026, signs=("gemini",))
    plain_path = tmp_path / "static-horoscopes-2026-gemini.ndjson"
    gzip_path = tmp_path / "static-horoscopes-2026-gemini.ndjson.gz"
    export_rows_to_ndjson(rows, plain_path)
    export_rows_to_ndjson(rows, gzip_path)

    plain_rows = load_static_horoscope_ndjson(plain_path)
    gzip_rows = load_static_horoscope_ndjson(gzip_path)

    assert len(plain_rows) == 3879
    assert len(gzip_rows) == 3879
    assert plain_rows[0].sign == "gemini"
    assert gzip_rows[-1].period == "daily"


def test_validate_static_horoscope_ndjson_reports_complete_coverage(tmp_path):
    rows = StaticHoroscopeSeedService().build_rows(year=2026, signs=("gemini",))
    export_path = tmp_path / "static-horoscopes-2026-gemini.ndjson.gz"
    export_rows_to_ndjson(rows, export_path)

    result = validate_static_horoscope_ndjson(export_path, year=2026, signs=("gemini",))

    assert result.is_complete is True
    assert result.actual_total == 3879
    assert result.expected_total == 3879
    assert result.actual_counts == {
        "daily": 3285,
        "monthly": 108,
        "weekly": 477,
        "yearly": 9,
    }


def test_validate_static_horoscope_ndjson_reports_missing_rows(tmp_path):
    rows = StaticHoroscopeSeedService().build_rows(year=2026, signs=("gemini",))
    export_path = tmp_path / "static-horoscopes-2026-gemini-truncated.ndjson.gz"
    with gzip.open(export_path, "wt", encoding="utf-8") as handle:
        for row in rows[:-1]:
            handle.write(json.dumps(row_to_json(row), separators=(",", ":")) + "\n")

    result = validate_static_horoscope_ndjson(export_path, year=2026, signs=("gemini",))

    assert result.is_complete is False
    assert result.actual_total == 3878
    assert len(result.missing) == 1


def row_to_json(row):
    return {
        "id": row.id,
        "sign": row.sign,
        "target_year": row.target_year,
        "period": row.period,
        "focus": row.focus,
        "content_date": row.content_date.isoformat(),
        "period_end_date": row.period_end_date.isoformat() if row.period_end_date else None,
        "title": row.title,
        "summary": row.summary,
        "body": row.body,
        "lucky_numbers": row.lucky_numbers,
        "lucky_color": row.lucky_color,
        "source": row.source,
        "generation_model": row.generation_model,
        "prompt_version": row.prompt_version,
        "knowledge_version": row.knowledge_version,
        "content_version": row.content_version,
        "is_active": row.is_active,
        "generated_at": row.generated_at.isoformat(),
        "created_at": None,
        "updated_at": None,
    }
