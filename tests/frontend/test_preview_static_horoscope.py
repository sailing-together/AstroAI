from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PREVIEW_DIR = ROOT / "frontend" / "preview"


def test_preview_entrypoint_exists():
    assert (PREVIEW_DIR / "index.html").exists()
    assert (PREVIEW_DIR / "styles.css").exists()
    assert (PREVIEW_DIR / "app.js").exists()
    assert (PREVIEW_DIR / "start-preview.ps1").exists()


def test_preview_uses_public_static_horoscope_api():
    html = (PREVIEW_DIR / "index.html").read_text(encoding="utf-8")
    js = (PREVIEW_DIR / "app.js").read_text(encoding="utf-8")

    assert "AstroAI Preview" in html
    assert "/api/v1/utils/sun-sign" in js
    assert "/api/v1/horoscope/bundle/" in js
    assert "GeminiClient" not in js


def test_preview_has_first_screen_controls():
    html = (PREVIEW_DIR / "index.html").read_text(encoding="utf-8")

    assert 'id="signSelect"' in html
    assert 'id="birthDate"' in html
    assert 'id="yearInput"' in html
    assert 'id="loadButton"' in html
    assert 'id="focusTabs"' in html
