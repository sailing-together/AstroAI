from calendar import monthrange
from datetime import date, timedelta


SUPPORTED_PERIODS = ("daily", "weekly", "monthly", "yearly")


def period_dates_for_year(year: int, period: str) -> list[date]:
    _validate_period(period)
    if period == "yearly":
        return [date(year, 1, 1)]
    if period == "monthly":
        return [date(year, month, 1) for month in range(1, 13)]
    if period == "daily":
        return [
            date(year, month, day)
            for month in range(1, 13)
            for day in range(1, monthrange(year, month)[1] + 1)
        ]

    first_day = date(year, 1, 1)
    first_week_start = first_day - timedelta(days=first_day.weekday())
    last_day = date(year, 12, 31)
    dates: list[date] = []
    current = first_week_start
    while current <= last_day:
        dates.append(current)
        current += timedelta(days=7)
    return dates


def period_start_for_selected_date(selected_date: date, period: str) -> date:
    _validate_period(period)
    if period == "daily":
        return selected_date
    if period == "weekly":
        return selected_date - timedelta(days=selected_date.weekday())
    if period == "monthly":
        return selected_date.replace(day=1)
    return selected_date.replace(month=1, day=1)


def period_end_date(content_date: date, period: str) -> date:
    _validate_period(period)
    if period == "daily":
        return content_date
    if period == "weekly":
        return content_date + timedelta(days=6)
    if period == "monthly":
        return content_date.replace(day=monthrange(content_date.year, content_date.month)[1])
    return content_date.replace(month=12, day=31)


def _validate_period(period: str) -> None:
    if period not in SUPPORTED_PERIODS:
        raise ValueError(f"Unsupported horoscope period: {period}")
