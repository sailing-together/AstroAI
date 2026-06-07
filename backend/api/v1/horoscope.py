import os
from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession

from backend.database.session import get_db_session
from backend.schemas.horoscope import (
    SUPPORTED_HOROSCOPE_FOCUSES,
    HoroscopeBundleResponse,
    HoroscopeEntryResponse,
    HoroscopePeriodResponse,
)
from backend.services.static_horoscope_db_store import StaticHoroscopeDbStore
from backend.services.static_horoscope_repository import StaticHoroscopeRepository
from backend.services.zodiac import VALID_SIGNS

router = APIRouter(prefix="/horoscope", tags=["horoscope"])
repository = StaticHoroscopeRepository()
static_horoscope_store = StaticHoroscopeDbStore()


def get_static_horoscope_store() -> StaticHoroscopeDbStore:
    return static_horoscope_store


@router.get("/bundle/{sign}", response_model=HoroscopeBundleResponse)
async def get_horoscope_bundle(
    sign: str,
    year: int | None = None,
    session: AsyncSession = Depends(get_db_session),
    store: StaticHoroscopeDbStore = Depends(get_static_horoscope_store),
) -> HoroscopeBundleResponse:
    canonical_sign = _validate_sign(sign)
    target_year = year or datetime.now(timezone.utc).year
    active_repository = await _repository_for_year(session, store, canonical_sign, target_year)
    yearly = active_repository.build_year_entries(canonical_sign, target_year, "yearly")
    monthly = active_repository.build_year_entries(canonical_sign, target_year, "monthly")
    weekly = active_repository.build_year_entries(canonical_sign, target_year, "weekly")
    daily = active_repository.build_year_entries(canonical_sign, target_year, "daily")
    generated_at = max(entry.generated_at for entry in yearly + monthly + weekly + daily)
    return HoroscopeBundleResponse(
        sign=yearly[0].sign,
        year=target_year,
        yearly=yearly,
        monthly=monthly,
        weekly=weekly,
        daily=daily,
        generated_at=generated_at,
    )


@router.get("/daily/{sign}", response_model=HoroscopeEntryResponse | HoroscopePeriodResponse)
async def get_daily_horoscope(
    sign: str,
    content_date: date | None = Query(default=None, alias="date"),
    focus: str | None = None,
    session: AsyncSession = Depends(get_db_session),
    store: StaticHoroscopeDbStore = Depends(get_static_horoscope_store),
):
    return await _get_horoscope_period(sign, "daily", content_date or date.today(), focus, session, store)


@router.get("/weekly/{sign}", response_model=HoroscopeEntryResponse | HoroscopePeriodResponse)
async def get_weekly_horoscope(
    sign: str,
    week: str | None = None,
    focus: str | None = None,
    session: AsyncSession = Depends(get_db_session),
    store: StaticHoroscopeDbStore = Depends(get_static_horoscope_store),
):
    target_date = _parse_week_or_date(week)
    return await _get_horoscope_period(
        sign,
        "weekly",
        target_date,
        focus,
        session,
        store,
        selected_date_mode=True,
        target_year=_parse_week_target_year(week, target_date),
    )


@router.get("/monthly/{sign}", response_model=HoroscopeEntryResponse | HoroscopePeriodResponse)
async def get_monthly_horoscope(
    sign: str,
    month: str | None = None,
    focus: str | None = None,
    session: AsyncSession = Depends(get_db_session),
    store: StaticHoroscopeDbStore = Depends(get_static_horoscope_store),
):
    return await _get_horoscope_period(sign, "monthly", _parse_month(month), focus, session, store)


@router.get("/yearly/{sign}", response_model=HoroscopeEntryResponse | HoroscopePeriodResponse)
async def get_yearly_horoscope(
    sign: str,
    year: int | None = None,
    focus: str | None = None,
    session: AsyncSession = Depends(get_db_session),
    store: StaticHoroscopeDbStore = Depends(get_static_horoscope_store),
):
    target_date = date(year or datetime.now(timezone.utc).year, 1, 1)
    return await _get_horoscope_period(sign, "yearly", target_date, focus, session, store)


async def _get_horoscope_period(
    sign: str,
    period: str,
    content_date: date,
    focus: str | None,
    session: AsyncSession,
    store: StaticHoroscopeDbStore,
    selected_date_mode: bool = False,
    target_year: int | None = None,
) -> HoroscopeEntryResponse | HoroscopePeriodResponse:
    canonical_sign = _validate_sign(sign)
    repository_year = target_year or content_date.year
    active_repository = await _repository_for_year(session, store, canonical_sign, repository_year)
    if focus is not None:
        canonical_focus = _validate_focus(focus)
        if selected_date_mode:
            return active_repository.build_entry_for_selected_date(
                canonical_sign,
                period,
                canonical_focus,
                content_date,
                target_year=repository_year,
            )
        return active_repository.build_entry(canonical_sign, period, canonical_focus, content_date)
    if selected_date_mode:
        return active_repository.build_period_for_selected_date(
            canonical_sign,
            period,
            content_date,
            target_year=repository_year,
        )
    return active_repository.build_period(canonical_sign, period, content_date)


async def _repository_for_year(
    session: AsyncSession,
    store: StaticHoroscopeDbStore,
    sign: str,
    target_year: int,
) -> StaticHoroscopeRepository:
    try:
        rows = await store.fetch_year_rows(session, sign, target_year)
    except (OSError, SQLAlchemyError) as exc:
        if _is_production():
            raise _static_horoscope_not_ready(sign, target_year) from exc
        rows = []
    if not rows:
        if _is_production():
            raise _static_horoscope_not_ready(sign, target_year)
        return repository
    return StaticHoroscopeRepository(persisted_rows=rows)


def _is_production() -> bool:
    return os.getenv("ENVIRONMENT", "development").lower() == "production"


def _static_horoscope_not_ready(sign: str, target_year: int) -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        detail={
            "code": "static_horoscope_not_ready",
            "message": "Static horoscope data is not ready for this sign and year.",
            "sign": sign,
            "year": target_year,
        },
    )


def _validate_sign(sign: str) -> str:
    canonical_sign = sign.lower()
    if canonical_sign not in VALID_SIGNS:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Unsupported zodiac sign")
    return canonical_sign


def _validate_focus(focus: str) -> str:
    canonical_focus = focus.lower()
    if canonical_focus not in SUPPORTED_HOROSCOPE_FOCUSES:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Unsupported horoscope focus")
    return canonical_focus


def _parse_month(month: str | None) -> date:
    if month is None:
        return date.today().replace(day=1)
    try:
        year_text, month_text = month.split("-", 1)
        return date(int(year_text), int(month_text), 1)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid month format") from exc


def _parse_week_or_date(week: str | None) -> date:
    if week is None:
        return date.today()
    if "-W" not in week:
        try:
            return date.fromisoformat(week)
        except ValueError as exc:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid week format") from exc
    try:
        year_text, week_text = week.split("-W", 1)
        return date.fromisocalendar(int(year_text), int(week_text), 1)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid week format") from exc


def _parse_week_target_year(week: str | None, parsed_date: date) -> int:
    if week is None or "-W" not in week:
        return parsed_date.year
    try:
        year_text, _ = week.split("-W", 1)
        return int(year_text)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid week format") from exc
