import uuid
from datetime import date, datetime, timezone

from sqlalchemy import Date, DateTime, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import Mapped, mapped_column

from backend.database.base import Base


class StaticHoroscope(Base):
    __tablename__ = "static_horoscopes"
    __table_args__ = (
        UniqueConstraint("sign", "period", "focus", "content_date", name="uq_static_horoscope_identity"),
    )

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    sign: Mapped[str] = mapped_column(String, nullable=False, index=True)
    period: Mapped[str] = mapped_column(String, nullable=False, index=True)
    focus: Mapped[str] = mapped_column(String, nullable=False, index=True)
    content_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    summary: Mapped[str] = mapped_column(String, nullable=False)
    body: Mapped[str] = mapped_column(String, nullable=False)
    lucky_numbers: Mapped[list[int] | None] = mapped_column(ARRAY(Integer), nullable=True)
    lucky_color: Mapped[str | None] = mapped_column(String, nullable=True)
    generation_model: Mapped[str] = mapped_column(String, nullable=False)
    generated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
