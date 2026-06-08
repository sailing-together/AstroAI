import argparse
import asyncio
import gzip
import json
from collections import Counter
from collections.abc import Sequence
from pathlib import Path

from backend.database.models_static_horoscope import StaticHoroscope
from backend.services.static_horoscope_coverage import validate_static_horoscope_coverage
from backend.services.static_horoscope_seed_service import StaticHoroscopeSeedService, StaticHoroscopeSeedWriter


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Seed deterministic static horoscope rows.")
    parser.add_argument("--year", type=int, required=True, help="Target horoscope bundle year, e.g. 2026.")
    parser.add_argument(
        "--sign",
        action="append",
        default=[],
        help="Canonical sign slug to seed. Repeat for multiple signs. Defaults to all signs.",
    )
    parser.add_argument(
        "--source",
        default="codex-dev",
        choices=("codex-dev",),
        help="Seed source. The current command supports deterministic development rows only.",
    )
    parser.add_argument("--dry-run", action="store_true", help="Generate and validate rows without persisting them.")
    parser.add_argument("--write-db", action="store_true", help="Persist rows to the configured PostgreSQL database.")
    parser.add_argument(
        "--export-ndjson",
        help="Write generated rows to an NDJSON file. If the path ends in .gz, write gzip-compressed NDJSON.",
    )
    parser.add_argument(
        "--summary-json",
        help="Write an operator-friendly JSON summary for generated or persisted rows.",
    )
    return parser


async def run_seed(argv: Sequence[str] | None = None, writer: StaticHoroscopeSeedWriter | None = None) -> int:
    args = build_parser().parse_args(argv)
    service = StaticHoroscopeSeedService()
    signs = tuple(args.sign) if args.sign else None

    if args.dry_run or args.export_ndjson:
        rows = service.build_rows(year=args.year, signs=signs)
        coverage = validate_static_horoscope_coverage(
            rows,
            signs=tuple(sign.lower() for sign in signs) if signs is not None else tuple({row.sign for row in rows}),
            year=args.year,
        )
        if args.export_ndjson:
            export_path = export_rows_to_ndjson(rows, Path(args.export_ndjson))
        else:
            export_path = None
        summary = build_seed_summary(
            year=args.year,
            signs=None if signs is None else tuple(sign.lower() for sign in signs),
            rows=rows,
            expected_count=coverage.expected_total,
            coverage_complete=coverage.is_complete,
            persisted_count=0,
            write_complete=True,
            dry_run=args.dry_run,
            export_path=export_path,
        )
        if args.summary_json:
            write_summary_json(summary, Path(args.summary_json))
        _print_summary(summary)
        return 0

    if not args.write_db:
        raise RuntimeError("Use --dry-run to validate rows or --write-db to persist them.")

    if writer is None:
        from backend.database.session import AsyncSessionLocal
        from backend.services.static_horoscope_seed_writer import StaticHoroscopePostgresSeedWriter

        async with AsyncSessionLocal() as session:
            writer = StaticHoroscopePostgresSeedWriter(session=session)

    result = await service.seed(writer=writer, year=args.year, signs=signs)
    summary = build_seed_summary(
        year=result.year,
        signs=result.signs,
        rows=[],
        row_count=result.row_count,
        dry_run=False,
        expected_count=result.row_count,
        coverage_complete=True,
        persisted_count=result.persisted_count,
        write_complete=result.persisted_count == result.row_count,
        export_path=None,
    )
    if args.summary_json:
        write_summary_json(summary, Path(args.summary_json))
    _print_summary(summary)
    return 0


def main() -> int:
    return asyncio.run(run_seed())


def build_seed_summary(
    year: int,
    signs: tuple[str, ...] | None,
    rows: Sequence[StaticHoroscope],
    expected_count: int,
    coverage_complete: bool,
    persisted_count: int,
    write_complete: bool,
    dry_run: bool,
    export_path: Path | None,
    row_count: int | None = None,
) -> dict[str, object]:
    period_counts = Counter(row.period for row in rows)
    sign_counts = Counter(row.sign for row in rows)
    focus_counts = Counter(row.focus for row in rows)
    signs_value = ["all"] if signs is None else list(signs)
    export_size = export_path.stat().st_size if export_path is not None and export_path.exists() else None
    return {
        "year": year,
        "signs": signs_value,
        "row_count": len(rows) if row_count is None else row_count,
        "expected_count": expected_count,
        "coverage": "complete" if coverage_complete else "incomplete",
        "persisted_count": persisted_count,
        "write": "complete" if write_complete else "incomplete",
        "dry_run": dry_run,
        "export_path": str(export_path) if export_path is not None else None,
        "export_size_bytes": export_size,
        "period_counts": dict(sorted(period_counts.items())),
        "sign_counts": dict(sorted(sign_counts.items())),
        "focus_count": len(focus_counts),
        "focus_counts": dict(sorted(focus_counts.items())),
    }


def write_summary_json(summary: dict[str, object], path: Path) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path


def _print_summary(summary: dict[str, object]) -> None:
    signs = summary["signs"]
    if isinstance(signs, list):
        sign_text = "all" if signs == ["all"] else ",".join(str(sign) for sign in signs)
    else:
        sign_text = str(signs)
    export_text = f" export={summary['export_path']}" if summary["export_path"] is not None else ""
    print(
        "Static horoscope seed "
        f"year={summary['year']} "
        f"signs={sign_text} "
        f"rows={summary['row_count']} "
        f"expected={summary['expected_count']} "
        f"coverage={summary['coverage']} "
        f"persisted={summary['persisted_count']} "
        f"write={summary['write']} "
        f"dry_run={str(summary['dry_run']).lower()}"
        f"{export_text}"
    )


def export_rows_to_ndjson(rows: Sequence[StaticHoroscope], path: Path) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    opener = gzip.open if path.suffix == ".gz" else open
    with opener(path, "wt", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(_row_to_json(row), ensure_ascii=False, separators=(",", ":")) + "\n")
    return path


def _row_to_json(row: StaticHoroscope) -> dict[str, object]:
    return {
        "id": row.id,
        "sign": row.sign,
        "target_year": row.target_year,
        "period": row.period,
        "focus": row.focus,
        "content_date": _isoformat(row.content_date),
        "period_end_date": _isoformat(row.period_end_date),
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
        "generated_at": _isoformat(row.generated_at),
        "created_at": _isoformat(row.created_at),
        "updated_at": _isoformat(row.updated_at),
    }


def _isoformat(value) -> str | None:
    return value.isoformat() if value is not None else None


if __name__ == "__main__":
    raise SystemExit(main())
