import asyncio
import gzip
import json

from backend.services.static_horoscope_seed_service import StaticHoroscopeSeedService
from backend.tasks.seed_static_horoscopes import build_parser, export_rows_to_ndjson, run_seed


def test_seed_command_parser_defaults_to_all_signs_dry_run():
    args = build_parser().parse_args(["--year", "2026", "--dry-run"])

    assert args.year == 2026
    assert args.sign == []
    assert args.dry_run is True
    assert args.write_db is False
    assert args.source == "codex-dev"


def test_seed_command_parser_accepts_multiple_signs():
    args = build_parser().parse_args(["--year", "2026", "--sign", "gemini", "--sign", "leo", "--dry-run"])

    assert args.sign == ["gemini", "leo"]


def test_seed_command_dry_run_generates_without_persisting(capsys):
    exit_code = asyncio.run(run_seed(["--year", "2026", "--sign", "gemini", "--dry-run"]))

    output = capsys.readouterr().out
    assert exit_code == 0
    assert "year=2026" in output
    assert "signs=gemini" in output
    assert "rows=3879" in output
    assert "expected=3879" in output
    assert "coverage=complete" in output
    assert "persisted=0" in output
    assert "dry_run=true" in output


def test_seed_command_dry_run_defaults_to_all_signs(capsys):
    exit_code = asyncio.run(run_seed(["--year", "2026", "--dry-run"]))

    output = capsys.readouterr().out
    assert exit_code == 0
    assert "signs=all" in output
    assert "rows=46548" in output
    assert "expected=46548" in output
    assert "coverage=complete" in output


def test_seed_command_persists_through_injected_writer(capsys):
    writer = RecordingWriter()

    exit_code = asyncio.run(run_seed(["--year", "2026", "--sign", "gemini", "--write-db"], writer=writer))

    output = capsys.readouterr().out
    assert exit_code == 0
    assert len(writer.rows) == 3879
    assert "expected=3879" in output
    assert "coverage=complete" in output
    assert "persisted=3879" in output
    assert "write=complete" in output
    assert "dry_run=false" in output


def test_seed_command_exports_ndjson(tmp_path, capsys):
    export_path = tmp_path / "static-horoscopes-2026-gemini.ndjson"

    exit_code = asyncio.run(
        run_seed(["--year", "2026", "--sign", "gemini", "--export-ndjson", str(export_path)])
    )

    output = capsys.readouterr().out
    lines = export_path.read_text(encoding="utf-8").splitlines()
    first_row = json.loads(lines[0])
    assert exit_code == 0
    assert len(lines) == 3879
    assert first_row["sign"] == "gemini"
    assert first_row["target_year"] == 2026
    assert first_row["period"] == "yearly"
    assert "export=" in output
    assert "persisted=0" in output
    assert "dry_run=false" in output


def test_seed_command_exports_gzipped_ndjson(tmp_path):
    export_path = tmp_path / "static-horoscopes-2026-gemini.ndjson.gz"

    exit_code = asyncio.run(
        run_seed(["--year", "2026", "--sign", "gemini", "--export-ndjson", str(export_path)])
    )

    with gzip.open(export_path, "rt", encoding="utf-8") as handle:
        rows = [json.loads(line) for line in handle]
    assert exit_code == 0
    assert len(rows) == 3879
    assert rows[-1]["period"] == "daily"


def test_seed_command_writes_export_summary_json(tmp_path):
    export_path = tmp_path / "static-horoscopes-2026-gemini.ndjson.gz"
    summary_path = tmp_path / "static-horoscopes-2026-gemini.summary.json"

    exit_code = asyncio.run(
        run_seed(
            [
                "--year",
                "2026",
                "--sign",
                "gemini",
                "--export-ndjson",
                str(export_path),
                "--summary-json",
                str(summary_path),
            ]
        )
    )

    summary = json.loads(summary_path.read_text(encoding="utf-8"))
    assert exit_code == 0
    assert summary["year"] == 2026
    assert summary["signs"] == ["gemini"]
    assert summary["row_count"] == 3879
    assert summary["expected_count"] == 3879
    assert summary["coverage"] == "complete"
    assert summary["export_path"] == str(export_path)
    assert summary["export_size_bytes"] > 0
    assert summary["period_counts"] == {
        "daily": 3285,
        "monthly": 108,
        "weekly": 477,
        "yearly": 9,
    }
    assert summary["sign_counts"] == {"gemini": 3879}
    assert summary["focus_count"] == 9


def test_seed_command_validates_existing_ndjson_export(tmp_path, capsys):
    export_path = tmp_path / "static-horoscopes-2026-gemini.ndjson.gz"
    rows = StaticHoroscopeSeedService().build_rows(year=2026, signs=("gemini",))
    export_rows_to_ndjson(rows, export_path)

    exit_code = asyncio.run(
        run_seed(["--year", "2026", "--sign", "gemini", "--validate-ndjson", str(export_path)])
    )

    output = capsys.readouterr().out
    assert exit_code == 0
    assert "rows=3879" in output
    assert "expected=3879" in output
    assert "coverage=complete" in output
    assert "validate=" in output


def test_seed_command_writes_database_from_valid_ndjson_export(tmp_path, capsys):
    export_path = tmp_path / "static-horoscopes-2026-gemini.ndjson.gz"
    rows = StaticHoroscopeSeedService().build_rows(year=2026, signs=("gemini",))
    export_rows_to_ndjson(rows, export_path)
    writer = RecordingWriter()

    exit_code = asyncio.run(
        run_seed(
            [
                "--year",
                "2026",
                "--sign",
                "gemini",
                "--from-ndjson",
                str(export_path),
                "--write-db",
            ],
            writer=writer,
        )
    )

    output = capsys.readouterr().out
    assert exit_code == 0
    assert len(writer.rows) == 3879
    assert "rows=3879" in output
    assert "expected=3879" in output
    assert "coverage=complete" in output
    assert "persisted=3879" in output
    assert "write=complete" in output
    assert "input=" in output


def test_seed_command_blocks_database_write_from_incomplete_ndjson(tmp_path):
    export_path = tmp_path / "static-horoscopes-2026-gemini-truncated.ndjson.gz"
    rows = StaticHoroscopeSeedService().build_rows(year=2026, signs=("gemini",))
    export_rows_to_ndjson(rows[:-1], export_path)
    writer = RecordingWriter()

    try:
        asyncio.run(
            run_seed(
                [
                    "--year",
                    "2026",
                    "--sign",
                    "gemini",
                    "--from-ndjson",
                    str(export_path),
                    "--write-db",
                ],
                writer=writer,
            )
        )
    except RuntimeError as exc:
        assert "coverage is incomplete" in str(exc)
    else:
        raise AssertionError("Expected incomplete NDJSON coverage to block write-db.")
    assert writer.rows == []


def test_seed_command_requires_write_db_with_from_ndjson(tmp_path):
    export_path = tmp_path / "static-horoscopes-2026-gemini.ndjson.gz"
    rows = StaticHoroscopeSeedService().build_rows(year=2026, signs=("gemini",))
    export_rows_to_ndjson(rows, export_path)

    try:
        asyncio.run(run_seed(["--year", "2026", "--sign", "gemini", "--from-ndjson", str(export_path)]))
    except RuntimeError as exc:
        assert "--write-db" in str(exc)
    else:
        raise AssertionError("Expected --from-ndjson to require --write-db.")


def test_seed_command_reports_incomplete_write(capsys):
    writer = RecordingWriter(persisted_count=3878)

    exit_code = asyncio.run(run_seed(["--year", "2026", "--sign", "gemini", "--write-db"], writer=writer))

    output = capsys.readouterr().out
    assert exit_code == 0
    assert "rows=3879" in output
    assert "expected=3879" in output
    assert "coverage=complete" in output
    assert "persisted=3878" in output
    assert "write=incomplete" in output


def test_seed_command_requires_explicit_write_db_for_persistence():
    writer = RecordingWriter()

    try:
        asyncio.run(run_seed(["--year", "2026", "--sign", "gemini"], writer=writer))
    except RuntimeError as exc:
        assert "--write-db" in str(exc)
    else:
        raise AssertionError("Expected run_seed to require --write-db.")


class RecordingWriter:
    def __init__(self, persisted_count: int | None = None) -> None:
        self.rows = []
        self.persisted_count = persisted_count

    async def upsert_rows(self, rows):
        self.rows = list(rows)
        return self.persisted_count if self.persisted_count is not None else len(self.rows)
