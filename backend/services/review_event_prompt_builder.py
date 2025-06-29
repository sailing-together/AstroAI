from backend.models.review_event_user_input import UserInput

def build_prompt(user_input: UserInput, cookie_info: dict):
    date = str(user_input.event_date)
    event = user_input.event
    outcome = user_input.outcome
    birthdate = cookie_info['birthday'] #information from cookie
    location = cookie_info['location']

    if outcome != None:
        return f""""You are a astrology expert, 
    provide an astrological explanation for a {event} on {date} that had happened, 
    which the result is {outcome},
    based on that day's astrological signs and planetary positions.
    take on a credible tone. reponse can be like 
    'your failure in emotion on that day is because of the clashing signs etc'
    My birthday is {birthdate} and I'm at {location}."""
    else:
        return f"""You are a astrology expert, 
    predict using astrology the outcome of {event} on {date} that is in the future
    based on that day's astrological signs and planetary positions. 
    be ambiguous and creative in your response, do not use the word 'outcome' in your response.
    My birthday is {birthdate} and I'm at {location}."""