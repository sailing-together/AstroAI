import argparse
import asyncio
import gzip
import json
import os
from collections import Counter
from collections.abc import Sequence
from pathlib import Path

from backend.database.models_static_horoscope import StaticHoroscope
from backend.services.static_horoscope_coverage import validate_static_horoscope_coverage
from backend.services.static_horoscope_ndjson import load_static_horoscope_ndjson
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
    parser.add_argument(
        "--validate-ndjson",
        help="Validate an existing NDJSON or .ndjson.gz export without generating or persisting rows.",
    )
    parser.add_argument(
        "--from-ndjson",
        help="Load rows from an existing NDJSON or .ndjson.gz export before --write-db.",
    )
    parser.add_argument(
        "--allow-production-write",
        action="store_true",
        help="Required when ENVIRONMENT=production and --write-db is used.",
    )
    parser.add_argument(
        "--preflight-db",
        action="store_true",
        help="Check database connectivity and static_horoscopes table availability without writing rows.",
    )
    return parser


async def run_seed(argv: Sequence[str] | None = None, writer: StaticHoroscopeSeedWriter | None = None) -> int:
    args = build_parser().parse_args(argv)
    service = StaticHoroscopeSeedService()
    signs = tuple(args.sign) if args.sign else None
    canonical_signs = tuple(sign.lower() for sign in signs) if signs is not None else None
    if args.write_db:
        _guard_production_write(allow_production_write=args.allow_production_write)

    if args.preflight_db:
        async def preflight_operation(resolved_writer: StaticHoroscopeSeedWriter):
            await _run_writer_preflight(resolved_writer)

        await _with_seed_writer(writer, preflight_operation)
        summary = build_seed_summary(
            year=args.year,
            signs=canonical_signs,
            rows=[],
            row_count=0,
            expected_count=0,
            coverage_complete=True,
            persisted_count=0,
            write_complete=True,
            dry_run=False,
            export_path=None,
            validate_path=None,
            input_path=None,
            row_source="database",
            preflight_complete=True,
        )
        if args.summary_json:
            write_summary_json(summary, Path(args.summary_json))
        _print_summary(summary)
        return _exit_code_for_summary(summary)

    if args.validate_ndjson:
        rows = load_static_horoscope_ndjson(Path(args.validate_ndjson))
        coverage = validate_static_horoscope_coverage(
            rows,
            signs=canonical_signs if canonical_signs is not None else tuple({row.sign for row in rows}),
            year=args.year,
        )
        summary = build_seed_summary(
            year=args.year,
            signs=canonical_signs,
            rows=rows,
            expected_count=coverage.expected_total,
            coverage_complete=coverage.is_complete,
            persisted_count=0,
            write_complete=True,
            dry_run=False,
            export_path=None,
            validate_path=Path(args.validate_ndjson),
            input_path=None,
            row_source="ndjson",
        )
        if args.summary_json:
            write_summary_json(summary, Path(args.summary_json))
        _print_summary(summary)
        return _exit_code_for_summary(summary)

    if args.from_ndjson:
        if not args.write_db:
            raise RuntimeError("Use --write-db with --from-ndjson to persist a validated export.")
        rows = load_static_horoscope_ndjson(Path(args.from_ndjson))
        coverage = validate_static_horoscope_coverage(
            rows,
            signs=canonical_signs if canonical_signs is not None else tuple({row.sign for row in rows}),
            year=args.year,
        )
        if not coverage.is_complete:
            raise RuntimeError(
                "Static horoscope NDJSON coverage is incomplete; refusing to write database rows "
                f"from {args.from_ndjson}."
            )
        async def ndjson_write_operation(resolved_writer: StaticHoroscopeSeedWriter):
            await _run_writer_preflight(resolved_writer)
            return await resolved_writer.upsert_rows(rows)

        persisted_count = await _with_seed_writer(writer, ndjson_write_operation)
        summary = build_seed_summary(
            year=args.year,
            signs=canonical_signs,
            rows=rows,
            expected_count=coverage.expected_total,
            coverage_complete=coverage.is_complete,
            persisted_count=persisted_count,
            write_complete=persisted_count == len(rows),
            dry_run=False,
            export_path=None,
            validate_path=None,
            input_path=Path(args.from_ndjson),
            row_source="ndjson",
            preflight_complete=True,
        )
        if args.summary_json:
            write_summary_json(summary, Path(args.summary_json))
        _print_summary(summary)
        return _exit_code_for_summary(summary)

    if args.dry_run or args.export_ndjson:
        rows = service.build_rows(year=args.year, signs=signs)
        coverage = validate_static_horoscope_coverage(
            rows,
            signs=canonical_signs if canonical_signs is not None else tuple({row.sign for row in rows}),
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
            validate_path=None,
            input_path=None,
            row_source="generated",
        )
        if args.summary_json:
            write_summary_json(summary, Path(args.summary_json))
        _print_summary(summary)
        return 0

    if not args.write_db:
        raise RuntimeError("Use --dry-run to validate rows or --write-db to persist them.")

    async def generated_write_operation(resolved_writer: StaticHoroscopeSeedWriter):
        await _run_writer_preflight(resolved_writer)
        return await service.seed(writer=resolved_writer, year=args.year, signs=signs)

    result = await _with_seed_writer(writer, generated_write_operation)
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
        validate_path=None,
        input_path=None,
        row_source="generated",
        preflight_complete=True,
    )
    if args.summary_json:
        write_summary_json(summary, Path(args.summary_json))
    _print_summary(summary)
    return _exit_code_for_summary(summary)


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
    validate_path: Path | None,
    input_path: Path | None,
    row_source: str,
    preflight_complete: bool = False,
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
        "validate_path": str(validate_path) if validate_path is not None else None,
        "input_path": str(input_path) if input_path is not None else None,
        "row_source": row_source,
        "preflight": "complete" if preflight_complete else "skipped",
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
    validate_text = f" validate={summary['validate_path']}" if summary["validate_path"] is not None else ""
    input_text = f" input={summary['input_path']}" if summary["input_path"] is not None else ""
    preflight_text = f" preflight={summary['preflight']}" if summary["preflight"] == "complete" else ""
    print(
        "Static horoscope seed "
        f"year={summary['year']} "
        f"signs={sign_text} "
        f"rows={summary['row_count']} "
        f"expected={summary['expected_count']} "
        f"coverage={summary['coverage']} "
        f"row_source={summary['row_source']} "
        f"persisted={summary['persisted_count']} "
        f"write={summary['write']} "
        f"dry_run={str(summary['dry_run']).lower()}"
        f"{preflight_text}"
        f"{export_text}"
        f"{validate_text}"
        f"{input_text}"
    )


def _exit_code_for_summary(summary: dict[str, object]) -> int:
    if summary["coverage"] != "complete":
        return 1
    if summary["write"] != "complete":
        return 1
    return 0


def _guard_production_write(allow_production_write: bool) -> None:
    if os.getenv("ENVIRONMENT", "").lower() != "production":
        return
    if allow_production_write:
        return
    raise RuntimeError("ENVIRONMENT=production requires --allow-production-write before --write-db.")


async def _with_seed_writer(writer: StaticHoroscopeSeedWriter | None, operation):
    if writer is not None:
        return await operation(writer)
    from backend.database.session import AsyncSessionLocal
    from backend.services.static_horoscope_seed_writer import StaticHoroscopePostgresSeedWriter

    async with AsyncSessionLocal() as session:
        return await operation(StaticHoroscopePostgresSeedWriter(session=session))


async def _run_writer_preflight(writer: StaticHoroscopeSeedWriter) -> None:
    preflight = getattr(writer, "preflight", None)
    if preflight is None:
        return
    await preflight()


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
