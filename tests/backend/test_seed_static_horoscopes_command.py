import asyncio
import gzip
import json

from backend.tasks.seed_static_horoscopes import build_parser, run_seed


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
