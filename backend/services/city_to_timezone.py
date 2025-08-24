from geopy.geocoders import Nominatim
from geopy.exc import GeocoderUnavailable, GeocoderTimedOut
from timezonefinder import TimezoneFinder
from datetime import datetime, date, time
from zoneinfo import ZoneInfo

# Common location fallbacks for major cities
LOCATION_FALLBACKS = {
    "london, uk": {"lat": 51.5074, "lng": -0.1278, "timezone": "Europe/London"},
    "london": {"lat": 51.5074, "lng": -0.1278, "timezone": "Europe/London"},
    "new york, ny": {"lat": 40.7128, "lng": -74.0060, "timezone": "America/New_York"},
    "new york": {"lat": 40.7128, "lng": -74.0060, "timezone": "America/New_York"},
    "los angeles, ca": {"lat": 34.0522, "lng": -118.2437, "timezone": "America/Los_Angeles"},
    "los angeles": {"lat": 34.0522, "lng": -118.2437, "timezone": "America/Los_Angeles"},
    "paris, france": {"lat": 48.8566, "lng": 2.3522, "timezone": "Europe/Paris"},
    "paris": {"lat": 48.8566, "lng": 2.3522, "timezone": "Europe/Paris"},
    "tokyo, japan": {"lat": 35.6762, "lng": 139.6503, "timezone": "Asia/Tokyo"},
    "tokyo": {"lat": 35.6762, "lng": 139.6503, "timezone": "Asia/Tokyo"},
    "berlin, germany": {"lat": 52.5200, "lng": 13.4050, "timezone": "Europe/Berlin"},
    "berlin": {"lat": 52.5200, "lng": 13.4050, "timezone": "Europe/Berlin"},
    "sydney, australia": {"lat": -33.8688, "lng": 151.2093, "timezone": "Australia/Sydney"},
    "sydney": {"lat": -33.8688, "lng": 151.2093, "timezone": "Australia/Sydney"},
}

def get_timezone_from_location(city_name: str, birth_date: date, birth_time: time):
    # Normalize city name for fallback lookup
    city_normalized = city_name.lower().strip()
    
    # Check fallback first for common cities
    if city_normalized in LOCATION_FALLBACKS:
        fallback = LOCATION_FALLBACKS[city_normalized]
        lat, lng = fallback["lat"], fallback["lng"]
        timezone_str = fallback["timezone"]
        print(f"Using fallback data for {city_name}")
    else:
        # Try geocoding service with error handling
        try:
            geolocator = Nominatim(user_agent="astro-app", timeout=5)
            location = geolocator.geocode(city_name)
            
            if location is None:
                raise ValueError(f"Could not find location for '{city_name}'. Try using a more specific location like 'London, UK' or 'New York, NY'")
            
            lat, lng = location.latitude, location.longitude
            
            tf = TimezoneFinder()
            timezone_str = tf.timezone_at(lat=lat, lng=lng)
            
            if timezone_str is None:
                raise ValueError("Could not determine timezone")
                
        except (GeocoderUnavailable, GeocoderTimedOut, ConnectionError) as e:
            # Network issues - provide helpful error message
            raise ValueError(f"Unable to connect to location service. Please try again later, or use a specific format like 'London, UK' or 'New York, NY'. Error: {str(e)}")
        except Exception as e:
            raise ValueError(f"Error processing location '{city_name}': {str(e)}")

    # Get the timezone object
    try:
        tz = ZoneInfo(timezone_str)
    except Exception as e:
        raise ValueError(f"Invalid timezone '{timezone_str}': {str(e)}")
    
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