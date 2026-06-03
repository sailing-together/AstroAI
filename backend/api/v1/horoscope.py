from datetime import date, datetime, timezone

from fastapi import APIRouter, HTTPException, Query, status

from backend.schemas.horoscope import (
    SUPPORTED_HOROSCOPE_FOCUSES,
    HoroscopeBundleResponse,
    HoroscopeEntryResponse,
    HoroscopePeriodResponse,
)
from backend.services.static_horoscope_repository import StaticHoroscopeRepository
from backend.services.zodiac import VALID_SIGNS

router = APIRouter(prefix="/horoscope", tags=["horoscope"])
repository = StaticHoroscopeRepository()


@router.get("/bundle/{sign}", response_model=HoroscopeBundleResponse)
async def get_horoscope_bundle(sign: str, year: int | None = None) -> HoroscopeBundleResponse:
    canonical_sign = _validate_sign(sign)
    target_year = year or datetime.now(timezone.utc).year
    yearly = repository.build_year_entries(canonical_sign, target_year, "yearly")
    monthly = repository.build_year_entries(canonical_sign, target_year, "monthly")
    weekly = repository.build_year_entries(canonical_sign, target_year, "weekly")
    daily = repository.build_year_entries(canonical_sign, target_year, "daily")
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
):
    return _get_horoscope_period(sign, "daily", content_date or date.today(), focus)


@router.get("/weekly/{sign}", response_model=HoroscopeEntryResponse | HoroscopePeriodResponse)
async def get_weekly_horoscope(
    sign: str,
    week: str | None = None,
    focus: str | None = None,
):
    return _get_horoscope_period(sign, "weekly", _parse_week_or_date(week), focus, selected_date_mode=True)


@router.get("/monthly/{sign}", response_model=HoroscopeEntryResponse | HoroscopePeriodResponse)
async def get_monthly_horoscope(
    sign: str,
    month: str | None = None,
    focus: str | None = None,
):
    return _get_horoscope_period(sign, "monthly", _parse_month(month), focus)


@router.get("/yearly/{sign}", response_model=HoroscopeEntryResponse | HoroscopePeriodResponse)
async def get_yearly_horoscope(
    sign: str,
    year: int | None = None,
    focus: str | None = None,
):
    target_date = date(year or datetime.now(timezone.utc).year, 1, 1)
    return _get_horoscope_period(sign, "yearly", target_date, focus)


def _get_horoscope_period(
    sign: str,
    period: str,
    content_date: date,
    focus: str | None,
    selected_date_mode: bool = False,
) -> HoroscopeEntryResponse | HoroscopePeriodResponse:
    canonical_sign = _validate_sign(sign)
    if focus is not None:
        canonical_focus = _validate_focus(focus)
        if selected_date_mode:
            return repository.build_entry_for_selected_date(canonical_sign, period, canonical_focus, content_date)
        return repository.build_entry(canonical_sign, period, canonical_focus, content_date)
    if selected_date_mode:
        return repository.build_period_for_selected_date(canonical_sign, period, content_date)
    return repository.build_period(canonical_sign, period, content_date)


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
