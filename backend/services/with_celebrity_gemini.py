import google.generativeai as genai

#can be set as an environment variable for security later on
APIkey="AIzaSyDjy5BEaq3hpJjaxc5HrD4Nufikr6Nvjfo"

# Setup Gemini API
genai.configure(api_key=APIkey)

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
        return f"Error generating content: {str(e)}"