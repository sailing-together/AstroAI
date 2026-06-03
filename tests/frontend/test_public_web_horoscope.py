from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
WEB_DIR = ROOT / "frontend" / "web"


def test_public_web_horoscope_files_exist():
    assert (WEB_DIR / "src" / "app" / "horoscope" / "page.tsx").exists()
    assert (WEB_DIR / "src" / "components" / "horoscope" / "HoroscopeExperience.tsx").exists()
    assert (WEB_DIR / "src" / "components" / "horoscope" / "FocusTabs.tsx").exists()
    assert (WEB_DIR / "src" / "components" / "horoscope" / "ReadingPanel.tsx").exists()


def test_public_web_horoscope_avoids_preview_only_controls():
    component = (WEB_DIR / "src" / "components" / "horoscope" / "HoroscopeExperience.tsx").read_text(
        encoding="utf-8"
    )

    assert "API base" not in component
    assert "Load Bundle" not in component
    assert "debug" not in component.lower()
    assert "weeklyList" not in component
    assert "getHoroscopeBundle" in component
    assert "getSunSignFromBirthDate" in component


def test_public_web_horoscope_is_date_driven():
    component = (WEB_DIR / "src" / "components" / "horoscope" / "HoroscopeExperience.tsx").read_text(
        encoding="utf-8"
    )

    assert 'type="date"' in component
    assert "findDailyEntry" in component
    assert "findWeeklyEntry" in component
    assert "This week" in component
