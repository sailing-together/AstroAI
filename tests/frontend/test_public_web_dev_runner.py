from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
WEB_DIR = ROOT / "frontend" / "web"
README = ROOT / "README.md"


def test_public_web_has_dedicated_wsl_runner():
    script = (WEB_DIR / "start-web.sh").read_text(encoding="utf-8")

    assert "uvicorn backend.main:app" in script
    assert "npm run dev" in script
    assert "NEXT_PUBLIC_API_BASE_URL" in script
    assert "find_free_port" in script
    assert "http://127.0.0.1:$WEB_PORT/horoscope" in script


def test_root_readme_uses_public_web_runner_not_preview_for_web_app():
    readme = README.read_text(encoding="utf-8")
    public_web_section = readme.split("## Public Web App", maxsplit=1)[1].split("## Developer Preview", maxsplit=1)[0]

    assert "bash frontend/web/start-web.sh" in public_web_section
    assert "bash frontend/preview/start-preview.sh" not in public_web_section
    assert "NEXT_PUBLIC_API_BASE_URL" in public_web_section
