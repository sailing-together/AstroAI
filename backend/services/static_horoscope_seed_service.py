from collections.abc import Iterable, Sequence
from dataclasses import dataclass
from datetime import date
from typing import Protocol

from backend.database.models_static_horoscope import StaticHoroscope
from backend.services.static_horoscope_dev_importer import build_static_horoscope_rows
from backend.services.zodiac import VALID_SIGNS


StaticHoroscopeIdentity = tuple[str, int, str, str, date, int]


class StaticHoroscopeSeedWriter(Protocol):
    async def upsert_rows(self, rows: Sequence[StaticHoroscope]) -> int:
        """Persist rows and return the number of rows written."""


@dataclass(frozen=True)
class StaticHoroscopeSeedResult:
    year: int
    signs: tuple[str, ...]
    row_count: int
    persisted_count: int


class StaticHoroscopeSeedService:
    def build_rows(self, year: int, signs: Iterable[str] | None = None) -> list[StaticHoroscope]:
        canonical_signs = _canonical_signs(signs)
        rows = build_static_horoscope_rows(signs=canonical_signs, year=year)
        self.validate_unique_identities(rows)
        return rows

    async def seed(
        self,
        writer: StaticHoroscopeSeedWriter,
        year: int,
        signs: Iterable[str] | None = None,
    ) -> StaticHoroscopeSeedResult:
        rows = self.build_rows(year=year, signs=signs)
        persisted_count = await writer.upsert_rows(rows)
        return StaticHoroscopeSeedResult(
            year=year,
            signs=_canonical_signs(signs),
            row_count=len(rows),
            persisted_count=persisted_count,
        )

    def validate_unique_identities(self, rows: Iterable[StaticHoroscope]) -> None:
        seen: set[StaticHoroscopeIdentity] = set()
        for row in rows:
            identity = static_horoscope_identity(row)
            if identity in seen:
                raise ValueError(f"Duplicate static horoscope seed identity: {identity}")
            seen.add(identity)


def static_horoscope_identity(row: StaticHoroscope) -> StaticHoroscopeIdentity:
    return (
        row.sign,
        row.target_year,
        row.period,
        row.focus,
        row.content_date,
        row.content_version,
    )


def _canonical_signs(signs: Iterable[str] | None) -> tuple[str, ...]:
    if signs is None:
        return VALID_SIGNS
    return tuple(sign.lower() for sign in signs)
