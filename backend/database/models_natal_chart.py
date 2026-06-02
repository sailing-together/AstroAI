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
