from backend.models.with_celebrity_user_input import UserInput

def build_prompt(user_input: UserInput):
    celebrity_name = user_input.celebrity_name
    birthdate = str(user_input.birthdate)
    sign = user_input.sign

    #if celebrity_name not provided
    if not celebrity_name:
        prompt = f"""
You are a professional astrologer. Based solely on my birthdate {birthdate} and sign {sign}, 
tell me three well-known celebrities who have high astrological compatibility with me
based on publicly known zodiac signs and birthdates, just for entertainment purposes. 
Base your suggestions on typical compatibility patterns (e.g., sun signs, moon signs, elements, modalities). 
Use a credible tone and provide a brief explanation for each choice. 
SEPARATE EACH CELEBRITY WITH A '|' sign

For each celebrity, briefly describe and explain your choice:
- How we might connect romantically
- Our friendship potential
- Our ability to work together
- Any likely challenges
- A compatibility score from 1 to 10

SEPARATE EACH CELEBRITY WITH A '|' sign
Do no add spaces before or after the '|' sign
Please keep your answer concise (each celebrity under 200 words). 
Do not repeat my birthdate or sign, 
Directly start talking about the celebrities, do not include any introduction, write in a full paragraph
SEPARATE EACH CELEBRITY WITH A '|' sign
Do no use colloquial language or emojis.
"""

    else:
        prompt = f"""You are an expert astrologer, do you know {celebrity_name}'s birthday and sign?
    Analyze the compatibility between me and {celebrity_name}, my birthday is {birthdate}.
    This is just for entertainment purposes.
    Provide insights about and explain your choices:
    - Romantic compatibility
    - Friendship potential
    - Work relationship
    - Potential challenges
    - Overall compatibility score (1-10)
    
    Keep the response concise (under 300 words).
    return a short paragraph with no headings or bullet points."""
    
    return prompt