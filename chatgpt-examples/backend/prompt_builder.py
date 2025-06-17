import datetime

def get_zodiac(month: int, day: int) -> str:
    zodiac_signs = [
        ("Capricorn", (1, 19)), ("Aquarius", (2, 18)), ("Pisces", (3, 20)),
        ("Aries", (4, 19)), ("Taurus", (5, 20)), ("Gemini", (6, 20)),
        ("Cancer", (7, 22)), ("Leo", (8, 22)), ("Virgo", (9, 22)),
        ("Libra", (10, 22)), ("Scorpio", (11, 21)), ("Sagittarius", (12, 21)),
        ("Capricorn", (12, 31))
    ]

    for sign, (sign_month, sign_day) in zodiac_signs:
        if (month, day) <= (sign_month, sign_day):
            return sign
    return "Capricorn"

def build_prompt(name: str, birthdate: str):
    year, month, day = map(int, birthdate.split("-"))
    zodiac = get_zodiac(month, day)
    today = datetime.date.today().strftime("%B %d, %Y")

    return f"""
You are an expert astrology AI assistant.

Date: {today}
User: {name}
Birthday: {birthdate}
Zodiac Sign: {zodiac}

Tasks:
1. Provide today's overall horoscope (5-6 lines).
2. Love advice.
3. Career advice.
4. Wealth advice.
5. Personal growth suggestion.
6. Daily encouragement message.

Output should be friendly, clear, and very positive.
"""
