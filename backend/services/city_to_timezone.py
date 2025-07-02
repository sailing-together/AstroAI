from geopy.geocoders import Nominatim
from timezonefinder import TimezoneFinder
from datetime import datetime
import pytz

def get_timezone_from_location(city_name: str):
    geolocator = Nominatim(user_agent="astro-app", timeout=10)
    location = geolocator.geocode(city_name)

    if location is None:
        raise ValueError(f"Could not find location for '{city_name}'")

    lat, lng = location.latitude, location.longitude

    tf = TimezoneFinder()
    timezone = tf.timezone_at(lat=lat, lng=lng)

    if timezone is None:
        raise ValueError("Could not determine timezone")

    # Get the timezone object
    tz = pytz.timezone(timezone)
    
    # Get the current UTC offset for the timezone (accounts for DST if applicable)
    now = datetime.now(tz)
    offset_seconds = now.utcoffset().total_seconds()
    
    # Convert seconds to hours and minutes
    offset_hours = int(offset_seconds // 3600)
    offset_minutes = int((offset_seconds % 3600) // 60)
    
    # Format as "+HH:MM" or "-HH:MM"
    offset_str = f"{'+' if offset_hours >= 0 else '-'}{abs(offset_hours):02d}:{offset_minutes:02d}"

    return {
        "city": city_name,
        "latitude": lat,
        "longitude": lng,
        "timezone": timezone,
        "utc_offset": offset_str
    }
