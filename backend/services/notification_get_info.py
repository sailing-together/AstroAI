import os
from skyfield.api import load, N, W
from skyfield import almanac
from datetime import timedelta, datetime
import numpy as np

# Load ephemeris and timescale
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
EPH_PATH = os.path.join(BASE_DIR, '..', 'database', 'de421.bsp')
eph = load(EPH_PATH)
ts = load.timescale()

# Time range for the analysis
start_date = ts.utc(datetime.now().date())
end_date = ts.utc(datetime.now().date()+timedelta(days=30))

earth = eph['earth']

# Helper function to generate list of hourly times between start and end
def generate_hourly_times(start_dt, end_dt):
    times = []
    current = start_dt
    while current <= end_dt:
        times.append(current)
        current += timedelta(hours=1)
    return ts.utc(times)

# Planet mapping (including Chiron)
PLANET_MAP = {
    'Sun': 'sun',
    'Moon': 'moon',
    'Mercury': 'mercury barycenter',
    'Venus': 'venus barycenter',
    'Mars': 'mars barycenter',
    'Jupiter': 'jupiter barycenter',
    'Saturn': 'saturn barycenter',
    'Uranus': 'uranus barycenter',
    'Neptune': 'neptune barycenter',
    'Pluto': 'pluto barycenter',
    # Chiron is not in de421, so this would require a more detailed ephemeris like de440 or from another source if needed
}

ZODIAC_SIGNS = ['Aries', 'Taurus', 'Gemini', 'Cancer', 
                'Leo', 'Virgo', 'Libra', 'Scorpio',
                'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces']

def get_planet(name):
    return eph[PLANET_MAP[name]]

def get_planet_longitude(name, t):
    obj = get_planet(name)
    # Compute geocentric ecliptic longitude in degrees
    ecl = earth.at(t).observe(obj).ecliptic_latlon()
    lon_deg = ecl[1].degrees  # ecliptic longitude is second element
    # Normalize longitude to 0-360
    return lon_deg % 360

def get_lunar_events():
    t, phase = almanac.find_discrete(start_date, end_date, almanac.moon_phases(eph))
    moon_phase_names = ['New Moon', 'First Quarter', 'Full Moon', 'Last Quarter']
    events = []

    for i in range(len(t)):
        phase_name = moon_phase_names[phase[i]]
        start_time = t[i]
        end_time = t[i + 1] if i + 1 < len(t) else None

        # Check range validity
        is_start_in_range = start_date.tt <= start_time.tt <= end_date.tt
        is_end_in_range = end_time is not None and (start_date.tt <= end_time.tt <= end_date.tt)


        # Convert to datetime object if within range, else None
        start_iso = start_time.utc_datetime().date() if is_start_in_range else None
        end_iso = end_time.utc_datetime().date() if is_end_in_range else None

        # Compute duration only if both start and end are valid
        if is_start_in_range and is_end_in_range:
            duration_days = (end_time.utc_datetime() - start_time.utc_datetime()).total_seconds() / 86400.0
        else:
            duration_days = None

        events.append({
            'event': phase_name,
            'start': str(start_iso),
            'end': str(end_iso),
            'duration_days': round(duration_days, 2) if duration_days is not None else None
        })

    return events


def get_planetary_retrogrades():
    retrogrades = []
    planets_to_check = ['Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto']

    # Use a single, wide window to find all retrogrades
    start_date_wide = ts.utc(datetime.now().date() - timedelta(days=180))
    end_date_wide = ts.utc(datetime.now().date() + timedelta(days=180))

    for planet_name in planets_to_check:
        t = ts.linspace(start_date_wide, end_date_wide, 4000) # Increased resolution
        longitudes = get_planet_longitude(planet_name, t)
        diff = np.diff(longitudes)
        diff[diff > 180] -= 360
        diff[diff < -180] += 360
        is_retro = diff < 0

        retro_start_indices = np.where(is_retro & ~np.roll(is_retro, 1))[0]
        retro_end_indices = np.where(~is_retro & np.roll(is_retro, 1))[0]

        if is_retro[0]:
            retro_start_indices = np.insert(retro_start_indices, 0, 0)

        if len(retro_end_indices) < len(retro_start_indices):
             retro_end_indices = np.append(retro_end_indices, len(is_retro) - 1)

        for start_index, end_index in zip(retro_start_indices, retro_end_indices):
            start_of_retro = t[start_index]
            end_of_retro = t[end_index]

            # Filter for retrogrades active in the original 30-day window
            if start_of_retro.tt < end_date.tt and end_of_retro.tt > start_date.tt:

                start_date_display = str(start_of_retro.utc_datetime().date()) if start_of_retro.tt >= start_date.tt else None
                end_date_display = str(end_of_retro.utc_datetime().date()) if end_of_retro.tt <= end_date.tt else None

                # Only include retrogrades that start or end within the window
                if start_date_display or end_date_display:
                    duration_display = None
                    if start_date_display and end_date_display:
                        duration_display = round(float(end_of_retro.tt - start_of_retro.tt), 2)

                    retrogrades.append({
                        'planet': planet_name,
                        'start': start_date_display,
                        'end': end_date_display,
                        'duration_days': duration_display
                    })

    return retrogrades





def get_planetary_ingresses():
    ingresses = []
    step_days = 0.25  # 6-hour intervals

    for planet in PLANET_MAP.keys():
        if planet == 'Sun':  # Skip Sun if handled separately
            continue

        def sign_func(t):
            lon = get_planet_longitude(planet, t)
            if hasattr(lon, '__len__'):
                return np.floor_divide(lon, 30).astype(int)
            else:
                return int(lon // 30)

        sign_func.step_days = step_days

        times, signs = almanac.find_discrete(start_date, end_date, sign_func)

        for t, sign_index in zip(times, signs):
            ingresses.append({
                'planet': planet,
                'time': t.utc_datetime().strftime("%Y-%m-%d %H:%M:%S"),
                'sign': ZODIAC_SIGNS[sign_index],
                'sign_number': int(sign_index)
            })

    return ingresses



if __name__ == '__main__':
    print("=== Lunar Events ===")
    print(get_lunar_events())

    print("\n=== Planetary Retrogrades ===")
    print(get_planetary_retrogrades())

    print("\n=== Planetary Ingresses ===")
    print(get_planetary_ingresses())

