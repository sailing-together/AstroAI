
import google.generativeai as genai
from datetime import datetime
import random
from core.config import settings

# Setup Gemini API
genai.configure(api_key=settings.gemini_api_key)

# Get current date
current_date = datetime.now().date()

# Initialize the Gemini model
model = genai.GenerativeModel('gemini-1.5-flash')

# generating daily horoscope for a specific sign
def get_daily_horoscope(sign: str, some_prompt: dict):
    # Generate content
    return_value={}
    for key in some_prompt:
        if key == "info":
            continue
        else:
            try:
                response = model.generate_content(
                    contents = some_prompt["info"]+some_prompt[key],
                    generation_config={
                        "max_output_tokens": 70,
                        "temperature": random.uniform(0.5, 0.85),
                        "top_k": 40,
                        "top_p": 0.9,
                    }
                )
                return_value[key] = response.text.strip()
            except Exception as e:
                return f"Error generating content: {str(e)}"
    return return_value

    