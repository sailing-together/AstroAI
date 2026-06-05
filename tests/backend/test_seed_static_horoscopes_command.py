import asyncio

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
    assert "persisted=0" in output
    assert "dry_run=true" in output


def test_seed_command_dry_run_defaults_to_all_signs(capsys):
    exit_code = asyncio.run(run_seed(["--year", "2026", "--dry-run"]))

    output = capsys.readouterr().out
    assert exit_code == 0
    assert "signs=all" in output
    assert "rows=46548" in output


def test_seed_command_persists_through_injected_writer(capsys):
    writer = RecordingWriter()

    exit_code = asyncio.run(run_seed(["--year", "2026", "--sign", "gemini", "--write-db"], writer=writer))

    output = capsys.readouterr().out
    assert exit_code == 0
    assert len(writer.rows) == 3879
    assert "persisted=3879" in output
    assert "dry_run=false" in output


def test_seed_command_requires_explicit_write_db_for_persistence():
    writer = RecordingWriter()

    try:
        asyncio.run(run_seed(["--year", "2026", "--sign", "gemini"], writer=writer))
    except RuntimeError as exc:
        assert "--write-db" in str(exc)
    else:
        raise AssertionError("Expected run_seed to require --write-db.")


class RecordingWriter:
    def __init__(self) -> None:
        self.rows = []

    async def upsert_rows(self, rows):
        self.rows = list(rows)
        return len(self.rows)
