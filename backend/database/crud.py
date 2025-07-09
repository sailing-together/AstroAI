from backend.services import notification_get_info
from sqlalchemy import or_, func
from backend.database import config
from backend.database.models import LunarEvent, PlanetaryIngress, PlanetaryRetrograde
from datetime import date, datetime


def insert_all_data():
    db = config.SessionLocal()

    # getting info
    lunar_info = notification_get_info.get_lunar_events()
    retrograde_info = notification_get_info.get_planetary_retrogrades()
    ingress_info = notification_get_info.get_planetary_ingresses()

    # Insert Lunar Events
    for i in lunar_info:
        event_start = i['start']
        event_end = i['end']
        with db.no_autoflush:
            existing = db.query(LunarEvent).filter_by(
                event=i['event'],
                start=event_start,
                end=event_end
            ).first()
        if not existing:
            db.add(LunarEvent(
                event=i['event'],
                start=event_start,
                end=event_end,
                duration_days=i['duration_days']
            ))

    # Insert Planetary Retrogrades
    for i in retrograde_info:
        event_start = i['start']
        event_end = i['end']
        with db.no_autoflush:
            existing = db.query(PlanetaryRetrograde).filter_by(
                planet=i['planet'],
                start=event_start,
                end=event_end
            ).first()
        if not existing:
            db.add(PlanetaryRetrograde(
                planet=i['planet'],
                start=event_start,
                end=event_end,
                duration_days=i['duration_days']
            ))

    # Insert Planetary Ingresses
    for i in ingress_info:
        event_time = i['time']

        with db.no_autoflush:
            existing = db.query(PlanetaryIngress).filter_by(
                planet=i['planet'],
                time=event_time,
                sign=i['sign']
            ).first()
        if not existing:
            db.add(PlanetaryIngress(
                planet=i['planet'],
                time=event_time,
                sign=i['sign'],
                sign_number=i['sign_number']
            ))

    db.commit()
    db.close()
    print("✅ Data inserted into SQLite database.")



def clear_past_entries():
    db = config.SessionLocal()
    today_str = date.today().isoformat()  # YYYY-MM-DD

    try:
        # Delete past LunarEvents where the end date is in the past
        db.query(LunarEvent).filter(
            LunarEvent.end != None,
            LunarEvent.end < today_str
        ).delete(synchronize_session=False)

        # Delete past PlanetaryRetrogrades where the end date is in the past
        db.query(PlanetaryRetrograde).filter(
            PlanetaryRetrograde.end != None,
            PlanetaryRetrograde.end < today_str
        ).delete(synchronize_session=False)

        # Delete past PlanetaryIngresses where the event time is in the past
        db.query(PlanetaryIngress).filter(
            func.substr(PlanetaryIngress.time, 1, 10) < today_str
        ).delete(synchronize_session=False)

        db.commit()
        print("✅ Past entries cleared from the database.")
    except Exception as e:
        db.rollback()
        print(f"Error clearing past entries: {e}")
    finally:
        db.close()



def get_todays_events():
    today = str(date.today())
    db = config.SessionLocal()
    
    # For Lunar Events
    lunar_events = db.query(LunarEvent).filter(
        or_(
            LunarEvent.start == today,
            LunarEvent.end == today
        )
    ).all()
        
    # For Planetary Retrogrades
    retrogrades = db.query(PlanetaryRetrograde).filter(
        or_(
            PlanetaryRetrograde.start == today,
            PlanetaryRetrograde.end == today
        )
    ).all()
    
    # For Planetary Ingresses
    ingresses = db.query(PlanetaryIngress).filter(
    func.substring(PlanetaryIngress.time, 1, 10) == today
    ).all()
    return {
        "date": today,
        "lunar_events": lunar_events,
        "retrogrades": retrogrades,
        "ingresses": ingresses
    }

#print(get_todays_events())