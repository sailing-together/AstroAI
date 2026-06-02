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
                "max_output_tokens": 200,
                "temperature": 0.7,
                "top_k": 40,
                "top_p": 0.9,
            }
        )

        return response.text.strip()
    except Exception as e:
        return f"Error generating content: {str(e)}"