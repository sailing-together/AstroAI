import google.generativeai as genai
from core.config import settings

# Setup Gemini API
genai.configure(api_key=settings.gemini_api_key)

model = genai.GenerativeModel('gemini-1.5-flash')

def get_response(some_prompt: str):
    prompt = some_prompt

    try:
        response = model.generate_content(
            contents=prompt,
            generation_config={
                #"max_output_tokens": 300,
                "temperature": 0.6,
                "top_k": 40,
                "top_p": 0.9,
            }
        )

        return response.text.strip()
    except Exception as e:
        error_msg = str(e)
        if "429" in error_msg or "quota" in error_msg.lower():
            return "API quota exceeded. Please try again later or contact support to upgrade the API plan."
        elif "API" in error_msg:
            return "API service temporarily unavailable. Please try again later."
        else:
            return f"Service temporarily unavailable: {error_msg}"