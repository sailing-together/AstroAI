from UserInput import UserInput

def build_prompt(user_input: UserInput):
    sign_1 = user_input.sign_1
    sign_2 = user_input.sign_2

    prompt = f"""You are an expert astrologer. Analyze the compatibility between {sign_1} and {sign_2}.
    Provide insights about:
    - Romantic compatibility
    - Friendship potential
    - Work relationship
    - Potential challenges
    - Overall compatibility score (1-10)
    
    Keep the response concise (under 200 words).
    return a short paragraph with no headings or bullet points."""
    
    
    return prompt