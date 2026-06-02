# AstroAI Phase 0/1 Backend Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the existing AstroAI repo into alignment with the canonical source-of-truth docs for Phase 0 and Phase 1.

**Architecture:** Keep the current FastAPI backend as the redevelopment base, but replace legacy root-level demo routes with `/api/v1` modules. Keep the existing Flutter app parked as legacy/demo while Phase 1 builds the backend foundation for the future Next.js web MVP.

**Tech Stack:** FastAPI, Python 3.11+, Pydantic Settings, SQLAlchemy 2.x async, Supabase PostgreSQL/Auth, Redis/Upstash, Gemini 2.5 Flash/Flash-Lite, pyswisseph.

---

## Repo Review Findings

Current codebase:

- `backend/main.py` mounts legacy root-level routers: `/horoscope`, `/compatibility`, `/natal_chart`, `/review_event`, `/with_celebrity`, `/events-today`, `/update-database/`.
- `backend/core/config.py` only reads `gemini_api_key`.
- `backend/database/config.py` uses SQLite at `backend/database/planetary_notification_data.sqlite3`.
- `backend/database/models.py` only models legacy cosmic event tables.
- `backend/services/*_gemini.py` calls `gemini-1.5-flash`.
- `backend/services/simplified_natal_chart_calculation.py` has useful chart-calculation reference logic, but it uses `flatlib` wrappers and legacy response fields.
- `backend/services/scheduler_service.py` uses APScheduler for legacy static event maintenance.
- `frontend/flutter` is still the only frontend implementation.
- There is no `frontend/nextjs` app yet.
- `.gitignore` already ignores `.env`, `.env.*`, and `*.env`.
- No local `.env` files were found under the repo during review.

Decision:

- Reuse FastAPI, existing Gemini package experience, existing Swiss Ephemeris knowledge, and legacy SQLite cosmic-event data as migration reference.
- Replace legacy API route structure, Gemini model names, SQLite-as-primary storage, wildcard CORS, and demo prompt-service organization.
- Do not scaffold Next.js in Phase 1.
- Treat public yearly/monthly/weekly/daily horoscope generation as Phase 1.5. It should be implemented after the backend foundation exists and before the full Next.js web MVP.

## Canonical Docs

Read before implementation:

- `docs/PRODUCT.md`
- `docs/ARCHITECTURE.md`
- `docs/API_SPEC.md`
- `docs/SCHEMA.md`
- `docs/FRONTEND_SPEC.md`

Do not treat deprecated docs as source of truth:

- `docs/BACKEND_API.md`
- `docs/DATABASE_SCHEMA.md`
- `docs/FRONTEND_ARCHITECTURE.md`
- `docs/AI_PROMPTS.md`
- `docs/DESIGN.md`
- `docs/DECISIONS.md`
- `docs/MEETING_CONCLUSIONS.md`
- `docs/ROADMAP_DEVELOPMENT_PLAN.md`

---

## Target File Structure

Create:

- `backend/.env.example`
- `frontend/.env.example`
- `backend/api/v1/__init__.py`
- `backend/api/v1/router.py`
- `backend/api/v1/health.py`
- `backend/api/v1/users.py`
- `backend/api/v1/natal_chart.py`
- `backend/api/v1/chat.py`
- `backend/core/auth.py`
- `backend/core/rate_limit.py`
- `backend/database/session.py`
- `backend/database/base.py`
- `backend/database/models_user.py`
- `backend/database/models_natal_chart.py`
- `backend/schemas/__init__.py`
- `backend/schemas/common.py`
- `backend/schemas/user.py`
- `backend/schemas/natal_chart.py`
- `backend/schemas/chat.py`
- `backend/services/chart_engine.py`
- `backend/services/gemini_client.py`
- `backend/services/context_builder.py`
- `tests/backend/test_config.py`
- `tests/backend/test_api_contracts.py`
- `tests/backend/test_chart_engine.py`

Modify:

- `README.md`
- `backend/README.md`
- `backend/requirements.txt`
- `backend/main.py`
- `backend/core/config.py`
- `backend/database/__init__.py`

Keep as legacy reference for now:

- `backend/api/*_logic.py`
- `backend/services/*_gemini.py`
- `backend/services/*_prompt_builder.py`
- `backend/services/simplified_natal_chart_calculation.py`
- `backend/services/scheduler_service.py`
- `backend/database/planetary_notification_data.sqlite3`
- `backend/database/crud.py`
- `backend/database/models.py`

Do not delete legacy files in Phase 1 unless the implementation agent has a separate cleanup task and tests proving the new backend no longer imports them.

---

## Task 1: Phase 0 Security and Environment Baseline

**Files:**

- Create: `backend/.env.example`
- Create: `frontend/.env.example`
- Modify: `README.md`
- Modify: `backend/README.md`
- Test: manual grep/status checks

- [ ] **Step 1: Create backend env example**

Create `backend/.env.example`:

```env
ENVIRONMENT=development
BACKEND_CORS_ORIGINS=http://localhost:3000

SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
SUPABASE_JWT_SECRET=

DATABASE_URL=
REDIS_URL=

GEMINI_API_KEY=
GEMINI_PRIMARY_MODEL=gemini-2.5-flash
GEMINI_LIGHT_MODEL=gemini-2.5-flash-lite
GEMINI_TIMEOUT_SECONDS=30
GEMINI_MAX_RETRIES=3

AI_CHAT_FREE_DAILY_LIMIT=3
AI_CHAT_PREMIUM_DAILY_LIMIT=50

STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PREMIUM_PRICE_ID=

GOOGLE_PLACES_API_KEY=
FCM_SERVER_KEY=
```

- [ ] **Step 2: Create frontend env example**

Create `frontend/.env.example`:

```env
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api/v1
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

- [ ] **Step 3: Update root README**

Update `README.md` to state:

```md
# AstroAI

AstroAI is being redeveloped around the canonical docs in `docs/`:

- `docs/PRODUCT.md`
- `docs/ARCHITECTURE.md`
- `docs/API_SPEC.md`
- `docs/SCHEMA.md`
- `docs/FRONTEND_SPEC.md`

Current code status:

- `backend/` contains the FastAPI redevelopment base plus legacy demo routes.
- `frontend/flutter/` is the existing legacy/demo frontend.
- `frontend/nextjs/` does not exist yet and is not part of Phase 1.

Phase 1 focuses on FastAPI, Supabase Auth/PostgreSQL, natal chart persistence, Gemini client setup, and `/api/v1` route contracts.
```

- [ ] **Step 4: Update backend README**

Update `backend/README.md` to state:

```md
# AstroAI Backend

Phase 1 target: FastAPI backend under `/api/v1` using Supabase PostgreSQL/Auth, Redis rate limiting, deterministic natal chart calculation, and Gemini 2.5 Flash/Flash-Lite.

Legacy root routes such as `/horoscope`, `/compatibility`, and `/natal_chart` are retained only as reference until the new `/api/v1` implementation replaces them.

Run locally:

```bash
pip install -r requirements.txt
uvicorn backend.main:app --reload
```
```

- [ ] **Step 5: Verify no local secret files are tracked**

Run:

```bash
git status --short
git ls-files | grep -E '(^|/)\.env|\.env\.|\.pem$|service_role|GEMINI_API_KEY'
```

Expected:

- `backend/.env.example` and `frontend/.env.example` may appear.
- No real `.env`, private key, service role key, or API key files appear.

- [ ] **Step 6: Commit Phase 0 baseline**

Run:

```bash
git add README.md backend/README.md backend/.env.example frontend/.env.example
git commit -m "chore: add Phase 0 environment baseline"
```

---

## Task 2: Backend Dependencies and Settings

**Files:**

- Modify: `backend/requirements.txt`
- Modify: `backend/core/config.py`
- Test: `tests/backend/test_config.py`

- [ ] **Step 1: Update backend dependencies**

Ensure `backend/requirements.txt` contains:

```txt
fastapi==0.115.13
uvicorn==0.29.0
pydantic==2.11.7
pydantic-settings==2.7.0
sqlalchemy==2.0.30
asyncpg==0.29.0
python-jose[cryptography]==3.3.0
redis==5.0.4
google-generativeai==0.8.5
pyswisseph==2.10.3.2
geopy==2.4.1
timezonefinder==6.5.9
pytz==2025.2
pytest==8.2.0
httpx==0.27.0
pytest-asyncio==0.23.6
```

Keep `flatlib`, `apscheduler`, `requests`, `skyfield`, and `numpy` only if legacy code still imports them during Phase 1. Remove them later after legacy routes are disabled.

- [ ] **Step 2: Write failing config tests**

Create `tests/backend/test_config.py`:

```python
from backend.core.config import Settings


def test_settings_defaults_to_gemini_25_models():
    settings = Settings(
        gemini_api_key="test",
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon",
        supabase_service_role_key="service",
        supabase_jwt_secret="secret",
        database_url="postgresql+asyncpg://user:pass@localhost:5432/db",
        redis_url="redis://localhost:6379/0",
    )

    assert settings.gemini_primary_model == "gemini-2.5-flash"
    assert settings.gemini_light_model == "gemini-2.5-flash-lite"
    assert settings.ai_chat_free_daily_limit == 3
    assert settings.ai_chat_premium_daily_limit == 50


def test_frontend_cors_origins_are_parsed_from_csv():
    settings = Settings(
        gemini_api_key="test",
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon",
        supabase_service_role_key="service",
        supabase_jwt_secret="secret",
        database_url="postgresql+asyncpg://user:pass@localhost:5432/db",
        redis_url="redis://localhost:6379/0",
        backend_cors_origins="http://localhost:3000,https://astroai.example",
    )

    assert settings.cors_origins == ["http://localhost:3000", "https://astroai.example"]
```

- [ ] **Step 3: Run tests and verify failure**

Run:

```bash
pytest tests/backend/test_config.py -v
```

Expected: FAIL because `Settings` does not define the new fields.

- [ ] **Step 4: Replace settings implementation**

Replace `backend/core/config.py` with:

```python
from functools import cached_property

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    environment: str = "development"
    backend_cors_origins: str = "http://localhost:3000"

    supabase_url: str
    supabase_anon_key: str
    supabase_service_role_key: str
    supabase_jwt_secret: str

    database_url: str
    redis_url: str

    gemini_api_key: str
    gemini_primary_model: str = "gemini-2.5-flash"
    gemini_light_model: str = "gemini-2.5-flash-lite"
    gemini_timeout_seconds: int = 30
    gemini_max_retries: int = 3

    ai_chat_free_daily_limit: int = 3
    ai_chat_premium_daily_limit: int = 50

    stripe_secret_key: str | None = None
    stripe_webhook_secret: str | None = None
    stripe_premium_price_id: str | None = None

    google_places_api_key: str | None = None
    fcm_server_key: str | None = None

    @cached_property
    def cors_origins(self) -> list[str]:
        return [origin.strip() for origin in self.backend_cors_origins.split(",") if origin.strip()]


settings = Settings()
```

- [ ] **Step 5: Run config tests**

Run:

```bash
pytest tests/backend/test_config.py -v
```

Expected: PASS.

- [ ] **Step 6: Commit settings changes**

Run:

```bash
git add backend/requirements.txt backend/core/config.py tests/backend/test_config.py
git commit -m "feat: add backend settings foundation"
```

---

## Task 3: App Factory and `/api/v1` Router

**Files:**

- Modify: `backend/main.py`
- Create: `backend/api/v1/__init__.py`
- Create: `backend/api/v1/router.py`
- Create: `backend/api/v1/health.py`
- Test: `tests/backend/test_api_contracts.py`

- [ ] **Step 1: Write failing API prefix test**

Create `tests/backend/test_api_contracts.py`:

```python
from fastapi.testclient import TestClient

from backend.main import app


def test_health_endpoint_uses_api_v1_prefix():
    client = TestClient(app)

    response = client.get("/api/v1/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
pytest tests/backend/test_api_contracts.py::test_health_endpoint_uses_api_v1_prefix -v
```

Expected: FAIL because `/api/v1/health` does not exist.

- [ ] **Step 3: Create health route**

Create `backend/api/v1/health.py`:

```python
from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
```

- [ ] **Step 4: Create API v1 router**

Create `backend/api/v1/router.py`:

```python
from fastapi import APIRouter

from backend.api.v1 import health

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(health.router)
```

Create `backend/api/v1/__init__.py`:

```python
"""Versioned API routes for AstroAI."""
```

- [ ] **Step 5: Replace main app setup**

Replace `backend/main.py` with:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.api.v1.router import api_router
from backend.core.config import settings


app = FastAPI(title="AstroAI API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)
```

Do not mount legacy root routers in the new app.

- [ ] **Step 6: Run API prefix test**

Run:

```bash
pytest tests/backend/test_api_contracts.py::test_health_endpoint_uses_api_v1_prefix -v
```

Expected: PASS.

- [ ] **Step 7: Commit API router foundation**

Run:

```bash
git add backend/main.py backend/api/v1 tests/backend/test_api_contracts.py
git commit -m "feat: add versioned API router"
```

---

## Task 4: Database Session and SQLAlchemy Models

**Files:**

- Create: `backend/database/base.py`
- Create: `backend/database/session.py`
- Create: `backend/database/models_user.py`
- Create: `backend/database/models_natal_chart.py`
- Modify: `backend/database/__init__.py`
- Test: `tests/backend/test_database_models.py`

- [ ] **Step 1: Write model tests**

Create `tests/backend/test_database_models.py`:

```python
from backend.database.models_natal_chart import NatalChart
from backend.database.models_user import User


def test_user_tier_default_is_free():
    user = User(auth_id="00000000-0000-0000-0000-000000000001", email="a@example.com")

    assert user.tier == "free"


def test_natal_chart_has_expected_json_fields():
    chart = NatalChart(
        user_id="00000000-0000-0000-0000-000000000001",
        birth_date="1994-06-14",
        unknown_time=False,
        birth_place_name="Sydney, Australia",
        birth_lat=-33.8688,
        birth_lng=151.2093,
        timezone="Australia/Sydney",
        sun_sign="gemini",
        planets=[],
        houses=[],
        aspects=[],
        chart_hash="hash",
    )

    assert chart.planets == []
    assert chart.houses == []
    assert chart.aspects == []
```

- [ ] **Step 2: Run tests and verify failure**

Run:

```bash
pytest tests/backend/test_database_models.py -v
```

Expected: FAIL because model files do not exist.

- [ ] **Step 3: Create declarative base**

Create `backend/database/base.py`:

```python
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass
```

- [ ] **Step 4: Create async session module**

Create `backend/database/session.py`:

```python
from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from backend.core.config import settings

engine = create_async_engine(settings.database_url, pool_pre_ping=True)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)


async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session
```

- [ ] **Step 5: Create user model**

Create `backend/database/models_user.py`:

```python
import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime, String
from sqlalchemy.orm import Mapped, mapped_column

from backend.database.base import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    auth_id: Mapped[str] = mapped_column(String, unique=True, index=True, nullable=False)
    email: Mapped[str | None] = mapped_column(String, nullable=True)
    display_name: Mapped[str | None] = mapped_column(String, nullable=True)
    tier: Mapped[str] = mapped_column(String, nullable=False, default="free")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
```

- [ ] **Step 6: Create natal chart model**

Create `backend/database/models_natal_chart.py`:

```python
import uuid
from datetime import date, datetime, time, timezone
from decimal import Decimal

from sqlalchemy import Date, DateTime, ForeignKey, Numeric, String, Time
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from backend.database.base import Base


class NatalChart(Base):
    __tablename__ = "natal_charts"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), unique=True, index=True, nullable=False)
    birth_date: Mapped[date] = mapped_column(Date, nullable=False)
    birth_time: Mapped[time | None] = mapped_column(Time, nullable=True)
    unknown_time: Mapped[bool] = mapped_column(nullable=False, default=False)
    birth_place_name: Mapped[str] = mapped_column(String, nullable=False)
    birth_lat: Mapped[Decimal] = mapped_column(Numeric, nullable=False)
    birth_lng: Mapped[Decimal] = mapped_column(Numeric, nullable=False)
    timezone: Mapped[str] = mapped_column(String, nullable=False)
    sun_sign: Mapped[str] = mapped_column(String, nullable=False)
    moon_sign: Mapped[str | None] = mapped_column(String, nullable=True)
    ascendant_sign: Mapped[str | None] = mapped_column(String, nullable=True)
    planets: Mapped[list] = mapped_column(JSONB, nullable=False)
    houses: Mapped[list | None] = mapped_column(JSONB, nullable=True)
    aspects: Mapped[list] = mapped_column(JSONB, nullable=False)
    chart_hash: Mapped[str] = mapped_column(String, nullable=False, index=True)
    interpretation: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
```

- [ ] **Step 7: Export models**

Update `backend/database/__init__.py`:

```python
from backend.database.base import Base
from backend.database.models_natal_chart import NatalChart
from backend.database.models_user import User

__all__ = ["Base", "NatalChart", "User"]
```

- [ ] **Step 8: Run model tests**

Run:

```bash
pytest tests/backend/test_database_models.py -v
```

Expected: PASS.

- [ ] **Step 9: Commit database foundation**

Run:

```bash
git add backend/database tests/backend/test_database_models.py
git commit -m "feat: add user and natal chart models"
```

---

## Task 5: Supabase Auth Dependency

**Files:**

- Create: `backend/core/auth.py`
- Create: `backend/schemas/user.py`
- Modify: `tests/backend/test_api_contracts.py`

- [ ] **Step 1: Create user schema**

Create `backend/schemas/user.py`:

```python
from pydantic import BaseModel, EmailStr


class CurrentUser(BaseModel):
    auth_id: str
    email: EmailStr | None = None
```

Create `backend/schemas/__init__.py`:

```python
"""Pydantic schemas for AstroAI API contracts."""
```

- [ ] **Step 2: Create auth dependency**

Create `backend/core/auth.py`:

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from backend.core.config import settings
from backend.schemas.user import CurrentUser

bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> CurrentUser:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing bearer token")

    try:
        payload = jwt.decode(
            credentials.credentials,
            settings.supabase_jwt_secret,
            algorithms=["HS256"],
            audience="authenticated",
        )
    except JWTError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid bearer token") from exc

    auth_id = payload.get("sub")
    if not auth_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid bearer token")

    return CurrentUser(auth_id=auth_id, email=payload.get("email"))
```

- [ ] **Step 3: Add protected route contract test**

Append to `tests/backend/test_api_contracts.py`:

```python
def test_users_me_requires_authentication():
    client = TestClient(app)

    response = client.get("/api/v1/users/me")

    assert response.status_code == 401
```

- [ ] **Step 4: Run test and verify failure**

Run:

```bash
pytest tests/backend/test_api_contracts.py::test_users_me_requires_authentication -v
```

Expected: FAIL because `/api/v1/users/me` does not exist.

- [ ] **Step 5: Commit auth dependency**

Run:

```bash
git add backend/core/auth.py backend/schemas tests/backend/test_api_contracts.py
git commit -m "feat: add Supabase auth dependency"
```

---

## Task 6: User and Natal Chart API Contracts

**Files:**

- Create: `backend/api/v1/users.py`
- Create: `backend/api/v1/natal_chart.py`
- Modify: `backend/api/v1/router.py`
- Create: `backend/schemas/natal_chart.py`
- Modify: `tests/backend/test_api_contracts.py`

- [ ] **Step 1: Create natal chart schemas**

Create `backend/schemas/natal_chart.py`:

```python
from datetime import date, datetime, time
from decimal import Decimal

from pydantic import BaseModel, Field


class NatalChartRequest(BaseModel):
    birth_date: date
    birth_time: time | None = None
    unknown_time: bool = False
    birth_place_name: str
    birth_lat: Decimal
    birth_lng: Decimal
    timezone: str


class NatalChartResponse(BaseModel):
    id: str
    sun_sign: str
    moon_sign: str | None = None
    ascendant_sign: str | None = None
    unknown_time: bool
    planets: list[dict] = Field(default_factory=list)
    houses: list[dict] | None = None
    aspects: list[dict] = Field(default_factory=list)
    interpretation: dict | None = None
    created_at: datetime
    updated_at: datetime
```

- [ ] **Step 2: Create placeholder user route**

Create `backend/api/v1/users.py`:

```python
from fastapi import APIRouter, Depends

from backend.core.auth import get_current_user
from backend.schemas.user import CurrentUser

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me")
async def get_me(current_user: CurrentUser = Depends(get_current_user)) -> dict[str, str | None]:
    return {
        "id": current_user.auth_id,
        "email": current_user.email,
        "display_name": None,
        "tier": "free",
    }
```

- [ ] **Step 3: Create placeholder natal chart route**

Create `backend/api/v1/natal_chart.py`:

```python
from fastapi import APIRouter, Depends

from backend.core.auth import get_current_user
from backend.schemas.natal_chart import NatalChartRequest
from backend.schemas.user import CurrentUser

router = APIRouter(prefix="/users/me/natal-chart", tags=["natal-chart"])


@router.get("")
async def get_natal_chart(current_user: CurrentUser = Depends(get_current_user)) -> None:
    return None


@router.post("")
async def save_natal_chart(
    payload: NatalChartRequest,
    current_user: CurrentUser = Depends(get_current_user),
) -> dict:
    return {
        "id": "pending-persistence",
        "sun_sign": "Gemini",
        "moon_sign": None,
        "ascendant_sign": None,
        "unknown_time": payload.unknown_time,
        "planets": [],
        "houses": None if payload.unknown_time else [],
        "aspects": [],
        "interpretation": None,
        "created_at": "2026-06-02T00:00:00Z",
        "updated_at": "2026-06-02T00:00:00Z",
    }


@router.delete("")
async def delete_natal_chart(current_user: CurrentUser = Depends(get_current_user)) -> dict[str, bool]:
    return {"deleted": True}
```

- [ ] **Step 4: Register routes**

Update `backend/api/v1/router.py`:

```python
from fastapi import APIRouter

from backend.api.v1 import health, natal_chart, users

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(health.router)
api_router.include_router(users.router)
api_router.include_router(natal_chart.router)
```

- [ ] **Step 5: Run protected route test**

Run:

```bash
pytest tests/backend/test_api_contracts.py::test_users_me_requires_authentication -v
```

Expected: PASS.

- [ ] **Step 6: Commit route contracts**

Run:

```bash
git add backend/api/v1 backend/schemas/natal_chart.py tests/backend/test_api_contracts.py
git commit -m "feat: add user and natal chart API contracts"
```

---

## Task 7: Chart Engine Skeleton

**Files:**

- Create: `backend/services/chart_engine.py`
- Test: `tests/backend/test_chart_engine.py`

- [ ] **Step 1: Write chart engine test**

Create `tests/backend/test_chart_engine.py`:

```python
from datetime import date, time
from decimal import Decimal

from backend.services.chart_engine import BirthData, calculate_natal_chart


def test_calculate_natal_chart_returns_core_keys():
    result = calculate_natal_chart(
        BirthData(
            birth_date=date(1994, 6, 14),
            birth_time=time(8, 30),
            unknown_time=False,
            birth_lat=Decimal("-33.8688"),
            birth_lng=Decimal("151.2093"),
            timezone="Australia/Sydney",
        )
    )

    assert "sun_sign" in result
    assert "planets" in result
    assert "aspects" in result
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
pytest tests/backend/test_chart_engine.py -v
```

Expected: FAIL because `chart_engine.py` does not exist.

- [ ] **Step 3: Create minimal chart engine interface**

Create `backend/services/chart_engine.py`:

```python
from dataclasses import dataclass
from datetime import date, time
from decimal import Decimal


@dataclass(frozen=True)
class BirthData:
    birth_date: date
    birth_time: time | None
    unknown_time: bool
    birth_lat: Decimal
    birth_lng: Decimal
    timezone: str


def calculate_natal_chart(birth_data: BirthData) -> dict:
    """Return deterministic natal chart data.

    Phase 1 starts with the stable service boundary. Replace this minimal
    implementation with pyswisseph calculations adapted from
    `simplified_natal_chart_calculation.py`.
    """
    return {
        "sun_sign": "gemini",
        "moon_sign": None if birth_data.unknown_time else "pisces",
        "ascendant_sign": None if birth_data.unknown_time else "leo",
        "planets": [],
        "houses": None if birth_data.unknown_time else [],
        "aspects": [],
    }
```

- [ ] **Step 4: Run chart engine test**

Run:

```bash
pytest tests/backend/test_chart_engine.py -v
```

Expected: PASS.

- [ ] **Step 5: Commit chart engine boundary**

Run:

```bash
git add backend/services/chart_engine.py tests/backend/test_chart_engine.py
git commit -m "feat: add natal chart engine boundary"
```

---

## Task 8: Gemini Client Boundary

**Files:**

- Create: `backend/services/gemini_client.py`
- Create: `backend/schemas/chat.py`
- Create: `backend/api/v1/chat.py`
- Modify: `backend/api/v1/router.py`
- Modify: `tests/backend/test_api_contracts.py`

- [ ] **Step 1: Create chat schemas**

Create `backend/schemas/chat.py`:

```python
from pydantic import BaseModel, Field


class ChatRequest(BaseModel):
    message: str = Field(min_length=1)
    conversation_id: str | None = None


class ChatUsage(BaseModel):
    tier: str
    used_today: int
    daily_limit: int


class ChatResponse(BaseModel):
    conversation_id: str
    message_id: str
    reply: str
    model: str
    usage: ChatUsage
    created_at: str
```

- [ ] **Step 2: Create Gemini client boundary**

Create `backend/services/gemini_client.py`:

```python
import google.generativeai as genai

from backend.core.config import settings


class GeminiClient:
    def __init__(self) -> None:
        genai.configure(api_key=settings.gemini_api_key)
        self.primary_model_name = settings.gemini_primary_model
        self.light_model_name = settings.gemini_light_model

    async def generate_primary(self, prompt: str) -> str:
        model = genai.GenerativeModel(self.primary_model_name)
        response = model.generate_content(prompt)
        return response.text.strip()

    async def generate_light(self, prompt: str) -> str:
        model = genai.GenerativeModel(self.light_model_name)
        response = model.generate_content(prompt)
        return response.text.strip()
```

- [ ] **Step 3: Create protected chat route placeholder**

Create `backend/api/v1/chat.py`:

```python
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import APIRouter, Depends

from backend.core.auth import get_current_user
from backend.core.config import settings
from backend.schemas.chat import ChatRequest, ChatResponse, ChatUsage
from backend.schemas.user import CurrentUser

router = APIRouter(prefix="/chat", tags=["chat"])


@router.post("", response_model=ChatResponse)
async def send_chat_message(
    payload: ChatRequest,
    current_user: CurrentUser = Depends(get_current_user),
) -> ChatResponse:
    return ChatResponse(
        conversation_id=payload.conversation_id or str(uuid4()),
        message_id=str(uuid4()),
        reply="AI Astrologer backend boundary is ready.",
        model=settings.gemini_primary_model,
        usage=ChatUsage(tier="free", used_today=1, daily_limit=settings.ai_chat_free_daily_limit),
        created_at=datetime.now(timezone.utc).isoformat(),
    )
```

- [ ] **Step 4: Register chat route**

Update `backend/api/v1/router.py`:

```python
from fastapi import APIRouter

from backend.api.v1 import chat, health, natal_chart, users

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(health.router)
api_router.include_router(users.router)
api_router.include_router(natal_chart.router)
api_router.include_router(chat.router)
```

- [ ] **Step 5: Add chat auth contract test**

Append to `tests/backend/test_api_contracts.py`:

```python
def test_chat_requires_authentication():
    client = TestClient(app)

    response = client.post("/api/v1/chat", json={"message": "hello"})

    assert response.status_code == 401
```

- [ ] **Step 6: Run API tests**

Run:

```bash
pytest tests/backend/test_api_contracts.py -v
```

Expected: PASS.

- [ ] **Step 7: Commit Gemini/chat boundary**

Run:

```bash
git add backend/api/v1/chat.py backend/api/v1/router.py backend/schemas/chat.py backend/services/gemini_client.py tests/backend/test_api_contracts.py
git commit -m "feat: add Gemini chat API boundary"
```

---

## Task 9: Final Phase 1 Verification

**Files:**

- Review all files changed in Tasks 1-8.

- [ ] **Step 1: Run all backend tests**

Run:

```bash
pytest tests/backend -v
```

Expected: PASS.

- [ ] **Step 2: Scan for old conflicts in active backend code**

Run:

```bash
rg -n "gemini-1\\.5|gemini-2\\.0|ANTHROPIC|Claude|Sonnet|STRIPE_PRO|AI_CHAT_PRO|/natal-chart/calculate|/natal-chart/me|/natal_chart|compatibility\\?signA" backend tests docs/PRODUCT.md docs/ARCHITECTURE.md docs/API_SPEC.md docs/SCHEMA.md docs/FRONTEND_SPEC.md
```

Expected:

- No matches in new active backend modules except intentional legacy files.
- Docs may contain intentional "do not use" warnings.

- [ ] **Step 3: Confirm route table**

Run:

```bash
python -c "from backend.main import app; print(sorted([r.path for r in app.routes]))"
```

Expected includes:

```text
/api/v1/health
/api/v1/users/me
/api/v1/users/me/natal-chart
/api/v1/chat
```

Expected does not include legacy root routes in the active app:

```text
/horoscope
/compatibility
/natal_chart
```

- [ ] **Step 4: Commit verification notes if any docs changed**

If verification requires doc updates, commit them:

```bash
git add docs backend tests
git commit -m "docs: record Phase 1 backend foundation notes"
```

---

## What Not To Do Yet

- Do not scaffold `frontend/nextjs` in Phase 1.
- Do not implement the full public static horoscope engine in Phase 1; create a separate Phase 1.5 plan for scheduled yearly/monthly/weekly/daily generation and stored reads.
- Do not delete the Flutter app.
- Do not delete legacy backend files until new routes are implemented and tested.
- Do not introduce Claude/Sonnet.
- Do not use Gemini 1.5 or Gemini 2.0.
- Do not rename `premium` to `pro`.
- Do not make premium unlimited.
- Do not expose server keys through frontend env vars.

## Phase 1 Exit Criteria

Phase 1 is complete when:

- Backend has `.env.example` matching `docs/ARCHITECTURE.md`.
- Frontend has `.env.example` matching `docs/FRONTEND_SPEC.md`.
- FastAPI app exposes `/api/v1/health`.
- FastAPI app uses configured CORS origins, not wildcard CORS.
- New `/api/v1` route modules exist for user, natal chart, and chat contracts.
- Supabase auth dependency exists.
- PostgreSQL/Supabase-oriented SQLAlchemy user and natal chart models exist.
- Gemini client wrapper uses `gemini-2.5-flash` and `gemini-2.5-flash-lite`.
- Tests cover settings, basic API contracts, and chart engine boundary.
- Legacy root routes are not mounted in the active app.

## Next Plan After Phase 1

Create a Phase 1.5 implementation plan for the Public Static Horoscope Engine:

- Add `static_horoscopes` persistence for `daily`, `weekly`, `monthly`, and `yearly`.
- Support dimensions: `general`, `love`, `career`, `money`, `wellness`, `social`, `family`, `study`, `mood_energy`.
- Add deterministic `/api/v1/utils/sun-sign?birth_date=YYYY-MM-DD`.
- Add no-login `/api/v1/horoscope/bundle/{sign}?year=YYYY` that returns yearly, monthly, weekly, and daily static content in one request.
- Add scheduled generation jobs:
  - yearly once per year
  - monthly once per month
  - weekly once per week
  - daily every day at 00:00
- Add annual bulk generation for a target year:
  - yearly horoscope for each sign
  - 12 monthly horoscopes for each sign
  - all weekly horoscopes for each sign
  - all daily horoscopes for each sign
- Add a manual annual regeneration trigger for operator-initiated refresh.
- Make one Gemini 2.5 Flash-Lite call per sign and period, returning all dimensions in one structured response.
- Store one row per sign, period, content date, and dimension.
- Serve public reads from PostgreSQL/Redis only.
- Verify public horoscope and Sun-sign utility API requests never call Gemini.
