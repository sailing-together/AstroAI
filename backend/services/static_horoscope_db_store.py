from collections.abc import Iterable
from datetime import date

from sqlalchemy import Select, select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.models_static_horoscope import StaticHoroscope
from backend.services.static_horoscope_repository import StaticHoroscopeRepository


class StaticHoroscopeDbStore:
    @staticmethod
    def build_year_rows_statement(
        sign: str,
        target_year: int,
        period: str | None = None,
    ) -> Select[tuple[StaticHoroscope]]:
        canonical_sign = sign.lower()
        statement = (
            select(StaticHoroscope)
            .where(
                StaticHoroscope.sign == canonical_sign,
                StaticHoroscope.target_year == target_year,
                StaticHoroscope.is_active.is_(True),
            )
            .order_by(
                StaticHoroscope.period,
                StaticHoroscope.content_date,
                StaticHoroscope.focus,
            )
        )
        if period is not None:
            statement = statement.where(StaticHoroscope.period == period)
        return statement

    @staticmethod
    def build_entry_rows_statement(
        sign: str,
        target_year: int,
        period: str,
        content_date: date,
        focus: str | None = None,
    ) -> Select[tuple[StaticHoroscope]]:
        canonical_sign = sign.lower()
        statement = (
            select(StaticHoroscope)
            .where(
                StaticHoroscope.sign == canonical_sign,
                StaticHoroscope.target_year == target_year,
                StaticHoroscope.period == period,
                StaticHoroscope.content_date == content_date,
                StaticHoroscope.is_active.is_(True),
            )
            .order_by(StaticHoroscope.focus)
        )
        if focus is not None:
            statement = statement.where(StaticHoroscope.focus == focus)
        return statement

    async def fetch_year_rows(
        self,
        session: AsyncSession,
        sign: str,
        target_year: int,
        period: str | None = None,
    ) -> list[StaticHoroscope]:
        result = await session.execute(self.build_year_rows_statement(sign, target_year, period))
        return list(result.scalars().all())

    async def fetch_entry_rows(
        self,
        session: AsyncSession,
        sign: str,
        target_year: int,
        period: str,
        content_date: date,
        focus: str | None = None,
    ) -> list[StaticHoroscope]:
        result = await session.execute(
            self.build_entry_rows_statement(
                sign=sign,
                target_year=target_year,
                period=period,
                content_date=content_date,
                focus=focus,
            )
        )
        return list(result.scalars().all())

    @staticmethod
    def repository_from_rows(rows: Iterable[StaticHoroscope]) -> StaticHoroscopeRepository:
        return StaticHoroscopeRepository(persisted_rows=rows)
