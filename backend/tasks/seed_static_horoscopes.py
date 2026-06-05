import argparse
import asyncio
from collections.abc import Sequence

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
    return parser


async def run_seed(argv: Sequence[str] | None = None, writer: StaticHoroscopeSeedWriter | None = None) -> int:
    args = build_parser().parse_args(argv)
    service = StaticHoroscopeSeedService()
    signs = tuple(args.sign) if args.sign else None

    if args.dry_run:
        rows = service.build_rows(year=args.year, signs=signs)
        _print_summary(
            year=args.year,
            signs=None if signs is None else tuple(sign.lower() for sign in signs),
            row_count=len(rows),
            persisted_count=0,
            dry_run=True,
        )
        return 0

    if writer is None:
        raise RuntimeError("A static horoscope seed writer is required unless --dry-run is used.")

    result = await service.seed(writer=writer, year=args.year, signs=signs)
    _print_summary(
        year=result.year,
        signs=result.signs,
        row_count=result.row_count,
        persisted_count=result.persisted_count,
        dry_run=False,
    )
    return 0


def main() -> int:
    return asyncio.run(run_seed())


def _print_summary(
    year: int,
    signs: tuple[str, ...] | None,
    row_count: int,
    persisted_count: int,
    dry_run: bool,
) -> None:
    sign_text = "all" if signs is None else ",".join(signs)
    print(
        "Static horoscope seed "
        f"year={year} "
        f"signs={sign_text} "
        f"rows={row_count} "
        f"persisted={persisted_count} "
        f"dry_run={str(dry_run).lower()}"
    )


if __name__ == "__main__":
    raise SystemExit(main())
