# backend/database/models.py

from sqlalchemy import Column, Integer, String, Float, UniqueConstraint
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class LunarEvent(Base):
    __tablename__ = "lunar_events"
    __table_args__ = (
    UniqueConstraint('event', 'start', 'end', name='uix_lunar_event'),
    )
    id = Column(Integer, primary_key=True, index=True)
    event = Column(String, nullable = False)
    start = Column(String)
    end = Column(String)
    duration_days = Column(Float)

class PlanetaryRetrograde(Base):
    __tablename__ = "planetary_retrogrades"
    __table_args__ = (
    UniqueConstraint('planet', 'start', 'end', name='uix_planetary_retrograde'),
    )
    id = Column(Integer, primary_key=True, index=True)
    planet = Column(String, nullable = False)
    start = Column(String)
    end = Column(String)
    duration_days = Column(Float)

class PlanetaryIngress(Base):
    __tablename__ = "planetary_ingresses"
    __table_args__ = (
    UniqueConstraint('planet', 'time', 'sign', name='uix_planetary_ingress'),
    )
    id = Column(Integer, primary_key=True, index=True)
    planet = Column(String, nullable = False)
    time = Column(String, nullable = False)
    sign = Column(String, nullable = False)
    sign_number = Column(Integer, nullable = False)
