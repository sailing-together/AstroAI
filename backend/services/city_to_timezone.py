from geopy.geocoders import Nominatim
from timezonefinder import TimezoneFinder
from datetime import datetime, date, time
from zoneinfo import ZoneInfo

def get_timezone_from_location(city_name: str, birth_date: date, birth_time: time):
    geolocator = Nominatim(user_agent="astro-app", timeout=10)
    location = geolocator.geocode(city_name)

    if location is None:
        raise ValueError(f"Could not find location for '{city_name}'")

    lat, lng = location.latitude, location.longitude

    tf = TimezoneFinder()
    timezone_str = tf.timezone_at(lat=lat, lng=lng)

    if timezone_str is None:
        raise ValueError("Could not determine timezone")

    # Get the timezone object
    tz = ZoneInfo(timezone_str)
    
    # Create a datetime object for the birth moment in the determined timezone
    birth_datetime_aware = datetime.combine(birth_date, birth_time).replace(tzinfo=tz)

    # Get the UTC offset for the birth moment
    offset_seconds = birth_datetime_aware.utcoffset().total_seconds()
    
    # Convert seconds to hours and minutes
    offset_hours = int(offset_seconds // 3600)
    offset_minutes = int((abs(offset_seconds) % 3600) // 60) # Use abs for minutes to handle negative offsets correctly
    
    # Format as "+HH:MM" or "-HH:MM"
    offset_str = f"{'+' if offset_hours >= 0 else '-'}{abs(offset_hours):02d}:{offset_minutes:02d}"

    return {
        "city": city_name,
        "latitude": lat,
        "longitude": lng,
        "timezone": timezone_str,
        "utc_offset": offset_str
    }