from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PREVIEW_DIR = ROOT / "frontend" / "preview"


def test_preview_entrypoint_exists():
    assert (PREVIEW_DIR / "index.html").exists()
    assert (PREVIEW_DIR / "styles.css").exists()
    assert (PREVIEW_DIR / "app.js").exists()
    assert (PREVIEW_DIR / "start-preview.ps1").exists()
    assert (PREVIEW_DIR / "start-preview.sh").exists()


def test_preview_uses_public_static_horoscope_api():
    html = (PREVIEW_DIR / "index.html").read_text(encoding="utf-8")
    js = (PREVIEW_DIR / "app.js").read_text(encoding="utf-8")
    css = (PREVIEW_DIR / "styles.css").read_text(encoding="utf-8")

    assert "AstroAI Preview" in html
    assert "Your 2026 Gemini Horoscope" in html
    assert "Static horoscope tester" not in html
    assert "/api/v1/utils/sun-sign" in js
    assert "/api/v1/horoscope/bundle/" in js
    assert "GeminiClient" not in js
    assert "window.ASTROAI_API_BASE" in js
    assert '<script src="./runtime-config.js"></script>' in html
    assert 'document.addEventListener("DOMContentLoaded", loadBundle)' in js
    assert "#4097ff" in css.lower()
    assert "#ff92a2" in css.lower()
    assert "#fff3f8" in css.lower()


def test_preview_has_first_screen_controls():
    html = (PREVIEW_DIR / "index.html").read_text(encoding="utf-8")

    assert 'id="signSelect"' in html
    assert 'id="birthDate"' in html
    assert 'id="yearInput"' in html
    assert 'id="loadButton"' in html
    assert 'id="focusTabs"' in html


def test_preview_has_wsl_start_script():
    script = (PREVIEW_DIR / "start-preview.sh").read_text(encoding="utf-8")

    assert "uvicorn backend.main:app" in script
    assert "find_free_port" in script
    assert "runtime-config.js" in script
    assert "BACKEND_CORS_ORIGINS" in script
