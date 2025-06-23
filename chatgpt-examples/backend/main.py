from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import geminiAPI
from UserInput import InputClass
from PromptBuilder import build_prompt
from datetime import datetime

app = FastAPI()

# Save horoscope data to a JSON file with a timestamped filename
def save_horoscope(data: dict):
    filename = f"horoscope_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    return filename

#Generate a horoscope based on the user's zodiac sign or birthdate.
# change response_model to JSON later
@app.post("/horoscope")
async def get_horoscope(input_data: InputClass):
    try:
        # Build the prompt using the input data
        prompt = build_prompt(input_data)

        # Get the horoscope from the Gemini API
        horoscope = geminiAPI.get_daily_horoscope(input_data.sign, prompt)
        
        # Return the horoscope
        return JSONResponse(content=horoscope)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
