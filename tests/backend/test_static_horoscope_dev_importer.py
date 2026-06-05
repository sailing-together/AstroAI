from backend.database.models_static_horoscope import StaticHoroscope
from backend.services.static_horoscope_dev_importer import build_all_static_horoscope_rows, build_static_horoscope_rows
from backend.services.zodiac import VALID_SIGNS


def test_dev_importer_builds_model_rows_for_generated_seed():
    rows = build_static_horoscope_rows(signs=["gemini"], year=2026)

    assert len(rows) == 3879
    assert isinstance(rows[0], StaticHoroscope)
    assert rows[0].sign == "gemini"
    assert rows[0].target_year == 2026
    assert rows[0].source == "codex-dev"
    assert rows[0].is_active is True


def test_dev_importer_visible_copy_does_not_mention_providers():
    rows = build_static_horoscope_rows(signs=["gemini"], year=2026)
    visible_text = " ".join(f"{row.title} {row.summary} {row.body}" for row in rows[:50])

    assert "Codex" not in visible_text
    assert "Gemini API" not in visible_text
    assert "provider" not in visible_text.lower()


def test_dev_importer_can_build_full_year_rows_for_all_signs():
    rows = build_all_static_horoscope_rows(year=2026)
    row_keys = {(row.sign, row.period, row.focus, row.content_date) for row in rows}

    assert len(rows) == 3879 * len(VALID_SIGNS)
    assert len(row_keys) == len(rows)
    assert {row.sign for row in rows} == set(VALID_SIGNS)
