from collections.abc import Sequence
from typing import Protocol

from sqlalchemy.dialects.postgresql import insert

from backend.database.models_static_horoscope import StaticHoroscope

DEFAULT_STATIC_HOROSCOPE_SEED_BATCH_SIZE = 1000


UPSERT_IDENTITY_COLUMNS = (
    "sign",
    "target_year",
    "period",
    "focus",
    "content_date",
    "content_version",
)

UPSERT_UPDATE_COLUMNS = (
    "period_end_date",
    "title",
    "summary",
    "body",
    "lucky_numbers",
    "lucky_color",
    "source",
    "generation_model",
    "prompt_version",
    "knowledge_version",
    "is_active",
    "generated_at",
    "updated_at",
)


class AsyncSeedSession(Protocol):
    async def execute(self, statement):
        ...

    async def commit(self):
        ...


class StaticHoroscopePostgresSeedWriter:
    def __init__(
        self,
        session: AsyncSeedSession,
        batch_size: int = DEFAULT_STATIC_HOROSCOPE_SEED_BATCH_SIZE,
    ) -> None:
        if batch_size < 1:
            raise ValueError("batch_size must be at least 1.")
        self._session = session
        self._batch_size = batch_size

    async def upsert_rows(self, rows: Sequence[StaticHoroscope]) -> int:
        if not rows:
            return 0
        for batch in _batched(rows, self._batch_size):
            await self._session.execute(build_upsert_statement(batch))
        await self._session.commit()
        return len(rows)


def _batched(rows: Sequence[StaticHoroscope], batch_size: int):
    for start in range(0, len(rows), batch_size):
        yield rows[start : start + batch_size]


def build_upsert_statement(rows: Sequence[StaticHoroscope]):
    values = [_row_to_values(row) for row in rows]
    statement = insert(StaticHoroscope).values(values)
    return statement.on_conflict_do_update(
        index_elements=[getattr(StaticHoroscope, column) for column in UPSERT_IDENTITY_COLUMNS],
        set_={column: getattr(statement.excluded, column) for column in UPSERT_UPDATE_COLUMNS},
    )


def _row_to_values(row: StaticHoroscope) -> dict[str, object]:
    return {
        "id": row.id,
        "sign": row.sign,
        "target_year": row.target_year,
        "period": row.period,
        "focus": row.focus,
        "content_date": row.content_date,
        "period_end_date": row.period_end_date,
        "title": row.title,
        "summary": row.summary,
        "body": row.body,
        "lucky_numbers": row.lucky_numbers,
        "lucky_color": row.lucky_color,
        "source": row.source,
        "generation_model": row.generation_model,
        "prompt_version": row.prompt_version,
        "knowledge_version": row.knowledge_version,
        "content_version": row.content_version,
        "is_active": row.is_active,
        "generated_at": row.generated_at,
        "created_at": row.created_at,
        "updated_at": row.updated_at,
    }
