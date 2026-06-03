# Static Horoscope Data Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the 2026 static horoscope data foundation so public horoscope reads use stored/static content, cover all 12 signs and all selected-date periods, and never call live AI during anonymous page views.

**Architecture:** Keep the existing FastAPI `/api/v1` route family and current in-memory/dev seed repository during this phase, but add production-shaped model/schema metadata and deterministic coverage utilities. The work proceeds from pure calendar logic to model/schema metadata, seed generation, repository lookup, API behavior, and a small frontend alignment test.

**Tech Stack:** FastAPI, Python 3.11+, SQLAlchemy, Pydantic, pytest, Next.js 14, TypeScript node tests.

---

## File Structure

- Create `backend/services/static_horoscope_calendar.py`: pure date utilities for 2026 coverage, period end dates, and selected-date lookup keys.
- Modify `backend/services/codex_dev_horoscope_seed.py`: generate rows with `target_year`, `period_end_date`, `source`, `prompt_version`, `knowledge_version`, `content_version`, and `is_active` metadata.
- Modify `backend/database/models_static_horoscope.py`: align SQLAlchemy model with the static data foundation spec.
- Modify `backend/schemas/horoscope.py`: include metadata in public/backend DTOs without breaking existing frontend fields.
- Modify `backend/services/static_horoscope_repository.py`: use calendar utilities, support date-driven weekly lookup, and expose coverage validation.
- Modify `backend/api/v1/horoscope.py`: make weekly/default date behavior call repository selected-date lookup instead of exact Monday-only lookup.
- Create `backend/services/static_horoscope_dev_importer.py`: convert deterministic generated rows into `StaticHoroscope` model instances for local database seeding.
- Create `tests/backend/test_static_horoscope_calendar.py`: pure calendar and coverage tests.
- Modify `tests/backend/test_codex_dev_horoscope_seed.py`: assert 2026 has 53 intersecting weeks and metadata.
- Modify `tests/backend/test_static_horoscope_model.py`: assert new model metadata fields.
- Modify `tests/backend/test_static_horoscope_repository.py`: assert coverage validation and selected-date weekly matching.
- Modify `tests/backend/test_public_static_horoscopes.py`: assert public weekly endpoint handles `2026-01-01` and bundle coverage counts.
- Create `tests/backend/test_static_horoscope_dev_importer.py`: assert dev import produces model rows without provider names in visible copy.
- Modify `frontend/web/src/__tests__/horoscope.test.ts`: assert selected date maps to matching weekly and monthly entries.
- Modify `frontend/web/src/lib/horoscope.ts`: use period end dates for weekly matching.

---

## Task 1: Calendar Coverage Utilities

**Files:**
- Create: `backend/services/static_horoscope_calendar.py`
- Test: `tests/backend/test_static_horoscope_calendar.py`

- [ ] **Step 1: Write the failing calendar tests**

Create `tests/backend/test_static_horoscope_calendar.py`:

```python
from datetime import date

from backend.services.static_horoscope_calendar import (
    period_end_date,
    period_start_for_selected_date,
    period_dates_for_year,
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
python -m pytest tests/backend/test_static_horoscope_calendar.py -q
```

Expected: FAIL because `backend.services.static_horoscope_calendar` does not exist.

- [ ] **Step 3: Implement the calendar module**

Create `backend/services/static_horoscope_calendar.py`:

```python
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
```

- [ ] **Step 4: Run the calendar tests**

Run:

```bash
python -m pytest tests/backend/test_static_horoscope_calendar.py -q
```

Expected: PASS.

- [ ] **Step 5: Commit Task 1**

```bash
git add backend/services/static_horoscope_calendar.py tests/backend/test_static_horoscope_calendar.py
git commit -m "feat: add static horoscope calendar coverage"
```

---

## Task 2: Static Horoscope Model and Schema Metadata

**Files:**
- Modify: `backend/database/models_static_horoscope.py`
- Modify: `backend/schemas/horoscope.py`
- Modify: `tests/backend/test_static_horoscope_model.py`

- [ ] **Step 1: Write failing model/schema tests**

Replace `test_static_horoscope_model_keeps_content_identity_fields` in `tests/backend/test_static_horoscope_model.py` with:

```python
def test_static_horoscope_model_keeps_content_identity_and_generation_metadata():
    row = StaticHoroscope(
        sign="gemini",
        target_year=2026,
        period="weekly",
        focus="general",
        content_date=date(2025, 12, 29),
        period_end_date=date(2026, 1, 4),
        title="A focused title",
        summary="Short scannable summary.",
        body="Full horoscope copy.",
        lucky_numbers=[3, 14, 22],
        lucky_color="Yellow",
        source="codex-dev",
        generation_model="codex-dev",
        prompt_version="dev-static-v1",
        knowledge_version="astroai-dev-v1",
        content_version=1,
        is_active=True,
    )

    assert row.sign == "gemini"
    assert row.target_year == 2026
    assert row.period == "weekly"
    assert row.period_end_date == date(2026, 1, 4)
    assert row.source == "codex-dev"
    assert row.prompt_version == "dev-static-v1"
    assert row.knowledge_version == "astroai-dev-v1"
    assert row.content_version == 1
    assert row.is_active is True
```

Add this schema test to the same file:

```python
def test_horoscope_entry_response_exposes_static_metadata():
    response = HoroscopeEntryResponse(
        sign="Gemini",
        target_year=2026,
        period="weekly",
        date="2025-12-29",
        period_end_date="2026-01-04",
        focus="general",
        title="A focused title",
        summary="Short scannable summary.",
        body="Full horoscope copy.",
        lucky_numbers=[3, 14, 22],
        lucky_color="Yellow",
        source="static",
        generated_at=datetime(2026, 1, 1, tzinfo=timezone.utc),
    )

    payload = response.model_dump()
    assert payload["target_year"] == 2026
    assert payload["period_end_date"] == "2026-01-04"
    assert payload["source"] == "static"
```

- [ ] **Step 2: Run the model/schema tests to verify failure**

Run:

```bash
python -m pytest tests/backend/test_static_horoscope_model.py -q
```

Expected: FAIL because `target_year`, `period_end_date`, and metadata fields do not exist on the model/schema.

- [ ] **Step 3: Update the SQLAlchemy model**

Modify `backend/database/models_static_horoscope.py` to include the new fields:

```python
import uuid
from datetime import date, datetime, timezone

from sqlalchemy import Boolean, Date, DateTime, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import Mapped, mapped_column

from backend.database.base import Base


class StaticHoroscope(Base):
    __tablename__ = "static_horoscopes"
    __table_args__ = (
        UniqueConstraint(
            "sign",
            "target_year",
            "period",
            "focus",
            "content_date",
            "content_version",
            name="uq_static_horoscope_versioned_identity",
        ),
    )

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    sign: Mapped[str] = mapped_column(String, nullable=False, index=True)
    target_year: Mapped[int] = mapped_column(Integer, nullable=False, index=True)
    period: Mapped[str] = mapped_column(String, nullable=False, index=True)
    focus: Mapped[str] = mapped_column(String, nullable=False, index=True)
    content_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    period_end_date: Mapped[date | None] = mapped_column(Date, nullable=True, index=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    summary: Mapped[str] = mapped_column(String, nullable=False)
    body: Mapped[str] = mapped_column(String, nullable=False)
    lucky_numbers: Mapped[list[int] | None] = mapped_column(ARRAY(Integer), nullable=True)
    lucky_color: Mapped[str | None] = mapped_column(String, nullable=True)
    source: Mapped[str] = mapped_column(String, nullable=False, default="codex-dev")
    generation_model: Mapped[str] = mapped_column(String, nullable=False)
    prompt_version: Mapped[str | None] = mapped_column(String, nullable=True)
    knowledge_version: Mapped[str | None] = mapped_column(String, nullable=True)
    content_version: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    generated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
```

- [ ] **Step 4: Update Pydantic response schemas**

Modify `HoroscopeEntryResponse` in `backend/schemas/horoscope.py`:

```python
class HoroscopeEntryResponse(BaseModel):
    sign: str
    target_year: int | None = None
    period: str
    date: str
    period_end_date: str | None = None
    focus: str
    title: str
    summary: str
    body: str
    lucky_numbers: list[int] | None = None
    lucky_color: str | None = None
    source: str = "static"
    generated_at: datetime
```

Modify `HoroscopePeriodResponse` in the same file:

```python
class HoroscopePeriodResponse(BaseModel):
    sign: str
    target_year: int | None = None
    period: str
    date: str
    period_end_date: str | None = None
    dimensions: dict[str, HoroscopeDimension]
    source: str = "static"
    generated_at: datetime
```

- [ ] **Step 5: Run model/schema tests**

Run:

```bash
python -m pytest tests/backend/test_static_horoscope_model.py -q
```

Expected: PASS.

- [ ] **Step 6: Commit Task 2**

```bash
git add backend/database/models_static_horoscope.py backend/schemas/horoscope.py tests/backend/test_static_horoscope_model.py
git commit -m "feat: add static horoscope metadata fields"
```

---

## Task 3: Codex Dev Seed Full 2026 Coverage

**Files:**
- Modify: `backend/services/codex_dev_horoscope_seed.py`
- Modify: `tests/backend/test_codex_dev_horoscope_seed.py`

- [ ] **Step 1: Update seed tests for 53-week coverage and metadata**

Modify `test_codex_dev_seed_generates_full_year_static_content` in `tests/backend/test_codex_dev_horoscope_seed.py`:

```python
def test_codex_dev_seed_generates_full_year_static_content():
    seed = CodexDevHoroscopeSeedGenerator().generate_year(sign="gemini", year=2026)

    assert seed.sign == "gemini"
    assert seed.year == 2026
    assert len(seed.yearly) == len(SUPPORTED_HOROSCOPE_FOCUSES)
    assert len(seed.monthly) == 12 * len(SUPPORTED_HOROSCOPE_FOCUSES)
    assert len(seed.weekly) == 53 * len(SUPPORTED_HOROSCOPE_FOCUSES)
    assert len(seed.daily) == 365 * len(SUPPORTED_HOROSCOPE_FOCUSES)
    assert seed.weekly[0].content_date.isoformat() == "2025-12-29"
    assert seed.weekly[0].period_end_date.isoformat() == "2026-01-04"
    assert seed.weekly[0].target_year == 2026
    assert seed.daily[0].generation_model == "codex-dev"
    assert seed.daily[0].source == "codex-dev"
    assert seed.daily[0].prompt_version == "dev-static-v1"
    assert seed.daily[0].knowledge_version == "astroai-dev-v1"
    assert seed.daily[0].content_version == 1
    assert seed.daily[0].is_active is True
```

- [ ] **Step 2: Run the seed tests to verify failure**

Run:

```bash
python -m pytest tests/backend/test_codex_dev_horoscope_seed.py -q
```

Expected: FAIL because weekly count is still 52 and metadata fields are missing.

- [ ] **Step 3: Update seed dataclass fields**

Modify `CodexDevHoroscopeSeedEntry` in `backend/services/codex_dev_horoscope_seed.py`:

```python
@dataclass(frozen=True)
class CodexDevHoroscopeSeedEntry:
    sign: str
    target_year: int
    period: str
    focus: str
    content_date: date
    period_end_date: date
    title: str
    summary: str
    body: str
    lucky_numbers: list[int]
    lucky_color: str
    source: str
    generation_model: str
    prompt_version: str
    knowledge_version: str
    content_version: int
    is_active: bool
    generated_at: datetime
```

Add constants near the existing generation constants:

```python
CODEX_DEV_SOURCE = "codex-dev"
CODEX_DEV_PROMPT_VERSION = "dev-static-v1"
CODEX_DEV_KNOWLEDGE_VERSION = "astroai-dev-v1"
```

- [ ] **Step 4: Use calendar utilities in the seed generator**

Add imports:

```python
from backend.services.static_horoscope_calendar import period_dates_for_year, period_end_date
```

Change `_build_entries` to use the shared utility:

```python
    def _build_entries(self, sign: str, year: int, period: str) -> list[CodexDevHoroscopeSeedEntry]:
        return [
            self._build_entry(sign, year, period, focus, content_date)
            for content_date in period_dates_for_year(year, period)
            for focus in SUPPORTED_HOROSCOPE_FOCUSES
        ]
```

Change `generate_entry` and `_build_entry` signatures:

```python
    def generate_entry(
        self,
        sign: str,
        period: str,
        focus: str,
        content_date: date,
        target_year: int | None = None,
    ) -> CodexDevHoroscopeSeedEntry:
        return self._build_entry(sign, target_year or content_date.year, period, focus, content_date)

    def _build_entry(
        self,
        sign: str,
        target_year: int,
        period: str,
        focus: str,
        content_date: date,
    ) -> CodexDevHoroscopeSeedEntry:
        label = sign_label(sign)
        focus_label = focus.replace("_", " ").title()
        period_label = PERIOD_LABELS[period]
        summary, focus_body = FOCUS_COPY[focus]
        cadence = _period_cadence(period, content_date)
        return CodexDevHoroscopeSeedEntry(
            sign=sign,
            target_year=target_year,
            period=period,
            focus=focus,
            content_date=content_date,
            period_end_date=period_end_date(content_date, period),
            title=f"{label} {period_label} {focus_label} Forecast",
            summary=summary,
            body=(
                f"{label}, {cadence} highlights your {focus_label.lower()} rhythm. "
                f"{focus_body} This guidance is prepared ahead of time, "
                "so you can browse it freely without waiting for a live prediction."
            ),
            lucky_numbers=_lucky_numbers(sign, period, focus, content_date),
            lucky_color=COLORS[SUPPORTED_HOROSCOPE_FOCUSES.index(focus) % len(COLORS)],
            source=CODEX_DEV_SOURCE,
            generation_model=CODEX_DEV_GENERATION_MODEL,
            prompt_version=CODEX_DEV_PROMPT_VERSION,
            knowledge_version=CODEX_DEV_KNOWLEDGE_VERSION,
            content_version=1,
            is_active=True,
            generated_at=CODEX_DEV_GENERATED_AT,
        )
```

Remove the old local `_period_dates_for_year` function from `codex_dev_horoscope_seed.py`.

- [ ] **Step 5: Run seed tests**

Run:

```bash
python -m pytest tests/backend/test_codex_dev_horoscope_seed.py -q
```

Expected: PASS.

- [ ] **Step 6: Commit Task 3**

```bash
git add backend/services/codex_dev_horoscope_seed.py tests/backend/test_codex_dev_horoscope_seed.py
git commit -m "feat: expand dev horoscope seed coverage"
```

---

## Task 4: Repository Coverage and Date-Driven Lookup

**Files:**
- Modify: `backend/services/static_horoscope_repository.py`
- Modify: `tests/backend/test_static_horoscope_repository.py`

- [ ] **Step 1: Add failing repository tests**

Append to `tests/backend/test_static_horoscope_repository.py`:

```python
from datetime import date

from backend.schemas.horoscope import SUPPORTED_HOROSCOPE_FOCUSES


def test_static_repository_validates_2026_bundle_coverage():
    repository = StaticHoroscopeRepository()

    coverage = repository.validate_year_coverage("gemini", 2026)

    assert coverage == {
        "yearly": 1 * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "monthly": 12 * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "weekly": 53 * len(SUPPORTED_HOROSCOPE_FOCUSES),
        "daily": 365 * len(SUPPORTED_HOROSCOPE_FOCUSES),
    }


def test_static_repository_maps_selected_date_to_matching_week():
    repository = StaticHoroscopeRepository()

    period = repository.build_period_for_selected_date("gemini", "weekly", date(2026, 1, 1))

    assert period.period == "weekly"
    assert period.date == "2025-12-29"
    assert period.period_end_date == "2026-01-04"
    assert set(period.dimensions.keys()) == set(SUPPORTED_HOROSCOPE_FOCUSES)
```

- [ ] **Step 2: Run repository tests to verify failure**

Run:

```bash
python -m pytest tests/backend/test_static_horoscope_repository.py -q
```

Expected: FAIL because `validate_year_coverage` and `build_period_for_selected_date` do not exist.

- [ ] **Step 3: Implement repository date-driven methods**

Add import:

```python
from backend.services.static_horoscope_calendar import period_start_for_selected_date
```

Add methods to `StaticHoroscopeRepository`:

```python
    def build_period_for_selected_date(
        self,
        sign: str,
        period: str,
        selected_date: date,
    ) -> HoroscopePeriodResponse:
        return self.build_period(sign, period, period_start_for_selected_date(selected_date, period))

    def build_entry_for_selected_date(
        self,
        sign: str,
        period: str,
        focus: str,
        selected_date: date,
    ) -> HoroscopeEntryResponse:
        return self.build_entry(sign, period, focus, period_start_for_selected_date(selected_date, period))

    def validate_year_coverage(self, sign: str, year: int) -> dict[str, int]:
        year_seed = self.get_or_create_year(sign, year)
        return {
            "yearly": len(year_seed.yearly),
            "monthly": len(year_seed.monthly),
            "weekly": len(year_seed.weekly),
            "daily": len(year_seed.daily),
        }
```

- [ ] **Step 4: Include metadata in response mapping**

Modify `_to_entry_response`:

```python
def _to_entry_response(entry: CodexDevHoroscopeSeedEntry) -> HoroscopeEntryResponse:
    return HoroscopeEntryResponse(
        sign=sign_label(entry.sign),
        target_year=entry.target_year,
        period=entry.period,
        date=entry.content_date.isoformat(),
        period_end_date=entry.period_end_date.isoformat(),
        focus=entry.focus,
        title=entry.title,
        summary=entry.summary,
        body=entry.body,
        lucky_numbers=entry.lucky_numbers,
        lucky_color=entry.lucky_color,
        source="static",
        generated_at=entry.generated_at,
    )
```

Modify `build_period` response creation:

```python
        period_end = entries[0].period_end_date if entries else None
        return HoroscopePeriodResponse(
            sign=sign_label(sign),
            target_year=entries[0].target_year if entries else content_date.year,
            period=period,
            date=content_date.isoformat(),
            period_end_date=period_end.isoformat() if period_end else None,
            dimensions={
                entry.focus: HoroscopeDimension(
                    title=entry.title,
                    summary=entry.summary,
                    body=entry.body,
                    lucky_numbers=entry.lucky_numbers,
                    lucky_color=entry.lucky_color,
                )
                for entry in entries
            },
            generated_at=STATIC_GENERATED_AT,
        )
```

- [ ] **Step 5: Run repository tests**

Run:

```bash
python -m pytest tests/backend/test_static_horoscope_repository.py -q
```

Expected: PASS.

- [ ] **Step 6: Commit Task 4**

```bash
git add backend/services/static_horoscope_repository.py tests/backend/test_static_horoscope_repository.py
git commit -m "feat: add date-driven horoscope repository lookup"
```

---

## Task 5: Public API Coverage and Weekly Edge Behavior

**Files:**
- Modify: `backend/api/v1/horoscope.py`
- Modify: `tests/backend/test_public_static_horoscopes.py`

- [ ] **Step 1: Add failing public API tests**

Append to `tests/backend/test_public_static_horoscopes.py`:

```python
def test_bundle_contains_full_2026_static_coverage(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get("/api/v1/horoscope/bundle/gemini", params={"year": 2026})

    assert response.status_code == 200
    payload = response.json()
    assert len(payload["yearly"]) == 9
    assert len(payload["monthly"]) == 108
    assert len(payload["weekly"]) == 477
    assert len(payload["daily"]) == 3285
    assert payload["weekly"][0]["date"] == "2025-12-29"
    assert payload["weekly"][0]["period_end_date"] == "2026-01-04"


def test_weekly_horoscope_maps_selected_date_to_intersecting_week(monkeypatch):
    client = TestClient(load_app(monkeypatch))

    response = client.get(
        "/api/v1/horoscope/weekly/gemini",
        params={"week": "2026-01-01"},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["period"] == "weekly"
    assert payload["date"] == "2025-12-29"
    assert payload["period_end_date"] == "2026-01-04"
```

- [ ] **Step 2: Run API tests to verify failure**

Run:

```bash
python -m pytest tests/backend/test_public_static_horoscopes.py -q
```

Expected: FAIL because weekly API currently parses only ISO week strings and exact Monday starts.

- [ ] **Step 3: Update weekly route parsing**

Modify `get_weekly_horoscope` in `backend/api/v1/horoscope.py`:

```python
@router.get("/weekly/{sign}", response_model=HoroscopeEntryResponse | HoroscopePeriodResponse)
async def get_weekly_horoscope(
    sign: str,
    week: str | None = None,
    focus: str | None = None,
):
    selected_date = _parse_week_or_date(week)
    return _get_horoscope_period(sign, "weekly", selected_date, focus, selected_date_mode=True)
```

Modify `_get_horoscope_period`:

```python
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
```

Replace `_parse_week` with:

```python
def _parse_week_or_date(week: str | None) -> date:
    if week is None:
        return date.today()
    if "-W" in week:
        try:
            year_text, week_text = week.split("-W", 1)
            return date.fromisocalendar(int(year_text), int(week_text), 1)
        except ValueError as exc:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid week format") from exc
    try:
        return date.fromisoformat(week)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid week format") from exc
```

- [ ] **Step 4: Run public API tests**

Run:

```bash
python -m pytest tests/backend/test_public_static_horoscopes.py -q
```

Expected: PASS.

- [ ] **Step 5: Commit Task 5**

```bash
git add backend/api/v1/horoscope.py tests/backend/test_public_static_horoscopes.py
git commit -m "feat: align public horoscope weekly lookup"
```

---

## Task 6: Dev Importer and Frontend Date Contract

**Files:**
- Create: `backend/services/static_horoscope_dev_importer.py`
- Create: `tests/backend/test_static_horoscope_dev_importer.py`
- Modify: `frontend/web/src/lib/horoscope.ts`
- Modify: `frontend/web/src/__tests__/horoscope.test.ts`

- [ ] **Step 1: Write failing dev importer tests**

Create `tests/backend/test_static_horoscope_dev_importer.py`:

```python
from backend.database.models_static_horoscope import StaticHoroscope
from backend.services.static_horoscope_dev_importer import build_static_horoscope_rows


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
```

- [ ] **Step 2: Run importer tests to verify failure**

Run:

```bash
python -m pytest tests/backend/test_static_horoscope_dev_importer.py -q
```

Expected: FAIL because `static_horoscope_dev_importer.py` does not exist.

- [ ] **Step 3: Implement dev importer**

Create `backend/services/static_horoscope_dev_importer.py`:

```python
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
```

- [ ] **Step 4: Write failing frontend date contract test**

Modify `frontend/web/src/__tests__/horoscope.test.ts` to include a weekly entry with `period_end_date`:

```typescript
test("findWeeklyEntry returns the week containing the selected date using period_end_date", () => {
  const entries = [
    {
      sign: "Gemini",
      period: "weekly",
      date: "2025-12-29",
      period_end_date: "2026-01-04",
      focus: "general",
      title: "Week",
      summary: "Weekly",
      body: "Weekly body",
      generated_at: "2026-01-01T00:00:00Z"
    }
  ] as const;

  const entry = findWeeklyEntry([...entries], "2026-01-01", "general");

  assert.equal(entry?.date, "2025-12-29");
});
```

- [ ] **Step 5: Run frontend tests to verify failure**

Run:

```bash
cd frontend/web
npm test
```

Expected: FAIL because `HoroscopeEntry` does not yet include `period_end_date` or `findWeeklyEntry` does not use it.

- [ ] **Step 6: Update frontend type and helper**

Modify `frontend/web/src/lib/types.ts`:

```typescript
export interface HoroscopeEntry {
  sign: string;
  target_year?: number;
  period: HoroscopePeriod;
  date: string;
  period_end_date?: string | null;
  focus: HoroscopeFocus;
  title: string;
  summary: string;
  body: string;
  lucky_numbers?: number[] | null;
  lucky_color?: string | null;
  source?: "static";
  generated_at: string;
}
```

Modify `findWeeklyEntry` in `frontend/web/src/lib/horoscope.ts`:

```typescript
export function findWeeklyEntry(entries: HoroscopeEntry[], date: string, focus: HoroscopeFocus) {
  return entries.find((entry) => {
    if (entry.period !== "weekly" || entry.focus !== focus) return false;
    const endDate = entry.period_end_date ?? addDaysIso(entry.date, 6);
    return entry.date <= date && date <= endDate;
  });
}

function addDaysIso(dateText: string, days: number) {
  const date = new Date(`${dateText}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}
```

- [ ] **Step 7: Run importer and frontend tests**

Run:

```bash
python -m pytest tests/backend/test_static_horoscope_dev_importer.py -q
cd frontend/web
npm test
```

Expected: PASS.

- [ ] **Step 8: Commit Task 6**

```bash
git add backend/services/static_horoscope_dev_importer.py tests/backend/test_static_horoscope_dev_importer.py frontend/web/src/lib/types.ts frontend/web/src/lib/horoscope.ts frontend/web/src/__tests__/horoscope.test.ts
git commit -m "feat: add dev horoscope import and frontend date contract"
```

---

## Final Verification

- [ ] **Step 1: Run backend tests**

```bash
python -m pytest tests/backend -q
```

Expected: all backend tests pass.

- [ ] **Step 2: Run frontend tests**

```bash
cd frontend/web
npm test
```

Expected: all frontend node tests pass.

- [ ] **Step 3: Run frontend build**

```bash
cd frontend/web
npm run build
```

Expected: Next.js build succeeds and `/horoscope` is listed.

- [ ] **Step 4: Search for forbidden visible/provider wording**

```bash
rg -n "Codex dev seed|development seed|Gemini API|20[0]6" backend frontend/web/src tests
```

Expected: no user-visible horoscope copy contains provider or dev-seed wording. The only `Codex` occurrences allowed are developer metadata, docs, branch names, and test names.

- [ ] **Step 5: Push branch and create PR**

```bash
git push -u origin codex/static-horoscope-data-foundation
gh pr create --base v2 --head codex/static-horoscope-data-foundation --title "feat: add static horoscope data foundation" --body "## Summary
- Add 2026 static horoscope calendar coverage and metadata
- Expand dev seed generation to cover intersecting ISO weeks
- Align backend API and frontend date lookup with selected-date daily/weekly/monthly/yearly behavior

## Verification
- python -m pytest tests/backend -q
- cd frontend/web && npm test
- cd frontend/web && npm run build"
```

Expected: branch pushed and PR opened against `v2`.
