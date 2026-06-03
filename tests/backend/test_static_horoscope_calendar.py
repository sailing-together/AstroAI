from datetime import date

from backend.services.static_horoscope_calendar import (
    period_dates_for_year,
    period_end_date,
    period_start_for_selected_date,
)


def test_2026_weekly_dates_include_weeks_intersecting_year():
    weekly_dates = period_dates_for_year(2026, "weekly")

    assert len(weekly_dates) == 53
    assert weekly_dates[0] == date(2025, 12, 29)
    assert weekly_dates[-1] == date(2026, 12, 28)


def test_2026_period_counts_match_static_foundation_spec():
    assert len(period_dates_for_year(2026, "yearly")) == 1
    assert len(period_dates_for_year(2026, "monthly")) == 12
    assert len(period_dates_for_year(2026, "weekly")) == 53
    assert len(period_dates_for_year(2026, "daily")) == 365


def test_selected_date_maps_to_period_start():
    selected = date(2026, 1, 1)

    assert period_start_for_selected_date(selected, "daily") == date(2026, 1, 1)
    assert period_start_for_selected_date(selected, "weekly") == date(2025, 12, 29)
    assert period_start_for_selected_date(selected, "monthly") == date(2026, 1, 1)
    assert period_start_for_selected_date(selected, "yearly") == date(2026, 1, 1)


def test_period_end_dates_are_explicit():
    assert period_end_date(date(2026, 1, 1), "daily") == date(2026, 1, 1)
    assert period_end_date(date(2025, 12, 29), "weekly") == date(2026, 1, 4)
    assert period_end_date(date(2026, 2, 1), "monthly") == date(2026, 2, 28)
    assert period_end_date(date(2026, 1, 1), "yearly") == date(2026, 12, 31)
