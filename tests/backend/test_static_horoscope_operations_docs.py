from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DOC = ROOT / "docs" / "STATIC_HOROSCOPE_OPERATIONS.md"


def test_static_horoscope_operations_doc_records_seed_workflow():
    content = DOC.read_text(encoding="utf-8")

    assert "--dry-run" in content
    assert "--export-ndjson" in content
    assert "--summary-json" in content
    assert "--validate-ndjson" in content
    assert "--smoke-read-ndjson" in content
    assert "smoke_read=complete" in content
    assert "--from-ndjson" in content
    assert "--write-db" in content
    assert "--preflight-db" in content
    assert "--allow-production-write" in content
    assert "downloads/static-horoscopes-2026.ndjson.gz" in content
    assert "46,548" in content
    assert "non-zero exit code" in content
    assert "Supabase/PostgreSQL" in content
