from collections.abc import Iterable

from backend.database.models_static_horoscope import StaticHoroscope
from backend.services.codex_dev_horoscope_seed import CodexDevHoroscopeSeedGenerator


def build_static_horoscope_rows(signs: Iterable[str], year: int) -> list[StaticHoroscope]:
    generator = CodexDevHoroscopeSeedGenerator()
    rows: list[StaticHoroscope] = []
    for sign in signs:
        seed = generator.generate_year(sign=sign, year=year)
        for entry in [*seed.yearly, *seed.monthly, *seed.weekly, *seed.daily]:
            rows.append(
                StaticHoroscope(
                    sign=entry.sign,
                    target_year=entry.target_year,
                    period=entry.period,
                    focus=entry.focus,
                    content_date=entry.content_date,
                    period_end_date=entry.period_end_date,
                    title=entry.title,
                    summary=entry.summary,
                    body=entry.body,
                    lucky_numbers=entry.lucky_numbers,
                    lucky_color=entry.lucky_color,
                    source=entry.source,
                    generation_model=entry.generation_model,
                    prompt_version=entry.prompt_version,
                    knowledge_version=entry.knowledge_version,
                    content_version=entry.content_version,
                    is_active=entry.is_active,
                    generated_at=entry.generated_at,
                )
            )
    return rows
