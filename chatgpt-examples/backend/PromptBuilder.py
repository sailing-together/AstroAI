from datetime import date
from UserInput import InputClass

def build_prompt(SomeInput: InputClass):
    birthdate = str(SomeInput.birthdate)
    zodiac = SomeInput.sign
    today = date.today()

    prompt = {"info": f"You are a astrology expert, today's date is, {today} my birthday is {birthdate} and the zodiac sign of my birthday is {zodiac}. Avoid using repetition (such as embrace) in each response.", 
              "overall_horoscope": "Please provide today's overall horoscope for the given information. Do not repeat the given information in the response",
              "love_advice": "Please provide love advice for the given information. Do not repeat the given information in the response",
              "career_advice": "Please provide career advice for the given information. Do not repeat the given information in the response",
              "wealth_advice": "Please provide wealth advice for the given information. Do not repeat the given information in the response",
              "personal_growth_suggestion": "Please provide a personal growth suggestion for the given information. Do not repeat the given information in the response",
              "daily_encouragement_message": "Please provide a daily encouragement message for the given information. Do not repeat the given information in the response"

    }
    return prompt
