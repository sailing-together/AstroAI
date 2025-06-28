from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import geminiAPI
from UserInput import InputClass
from PromptBuilder import build_prompt
from datetime import datetime

app = FastAPI()


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
