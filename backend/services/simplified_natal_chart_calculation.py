import json
import os
from flatlib.chart import Chart
from flatlib.datetime import Datetime
from flatlib.geopos import GeoPos
from flatlib import const
from flatlib.aspects import getAspect
import flatlib
import swisseph as swe
from datetime import date, time
from backend.models.natal_chart_user_input import UserInput

# Define major classical planets
MAJOR_PLANETS = [
    const.SUN, const.MOON, const.MERCURY, const.VENUS,
    const.MARS, const.JUPITER, const.SATURN,
    const.URANUS, const.NEPTUNE, const.PLUTO
]

# Planet symbols
PLANET_SYMBOLS = {
    'Sun': '☉', 'Moon': '☽', 'Mercury': '☿', 'Venus': '♀',
    'Mars': '♂', 'Jupiter': '♃', 'Saturn': '♄',
    'Uranus': '♅', 'Neptune': '♆', 'Pluto': '♇',
}

# Set ephemeris path explicitly
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
EPHEM_PATH = os.path.join(BASE_DIR, '..', 'database', 'de421.bsp')
swe.set_ephe_path(EPHEM_PATH)

def get_natal_chart_data(input: UserInput):
    birthdate = input.birth_date
    birthtime =  input.birth_time
    timezone = input.birth_timezone
    latitude = input.birth_latitude
    longitude = input.birth_longitude

    date_str = birthdate.strftime("%Y/%m/%d")
    time_str = birthtime.strftime("%H:%M")
    print(f"Date: {date_str}, Time: {time_str}, Timezone: {timezone}, Latitude: {latitude}, Longitude: {longitude}")
    dt = Datetime(date_str, time_str, timezone)
    pos = GeoPos(latitude, longitude)

    # No need to pass ephem to Chart constructor after setting path globally
    chart = Chart(dt, pos, IDs=MAJOR_PLANETS, hsys=const.HOUSES_PLACIDUS)

    asc_deg = round(chart.get(const.ASC).lon, 2)

    houses = [
        {
            "house_number": i,
            "start_degree": round(chart.get(getattr(const, f'HOUSE{i}')).lon, 2)
        }
        for i in range(1, 13)
    ]

    planets = []
    for name in MAJOR_PLANETS:
        obj = chart.get(name)
        if not obj:
            continue
        house = chart.houses.getObjectHouse(obj)
        planets.append({
            "name": obj.id,
            "symbol": PLANET_SYMBOLS.get(obj.id, "?"),
            "degree": round(obj.lon, 2),
            "zodiac_sign": obj.sign,
            "house_number": int(house.id.replace('House', '')),
            "house_sign": house.sign,
            "house_degree": round(house.lon, 2)
        })

    aspects = []
    for i in range(len(MAJOR_PLANETS)):
        for j in range(i + 1, len(MAJOR_PLANETS)):
            # No need to pass ephem to chart.get calls after setting path globally
            p1 = chart.get(MAJOR_PLANETS[i])
            p2 = chart.get(MAJOR_PLANETS[j])
            if not p1 or not p2:
                continue
            aspect = getAspect(p1, p2, const.MAJOR_ASPECTS)
            if aspect:
                aspects.append({
                    "planet1": p1.id,
                    "planet2": p2.id,
                    "angle": round(aspect.orb, 1),
                    "aspect_type": aspect.type
                })

    return {
        "ascendant_degree": asc_deg,
        "houses": houses,
        "planets": planets,
        "aspects": aspects
    }
