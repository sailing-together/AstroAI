from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from backend.services.horoscope_gemini import get_daily_horoscope
from backend.models.horoscope_user_input import InputClass
from backend.services.horoscope_prompt_builder import build_prompt
from datetime import datetime

router = APIRouter()


#Generate a horoscope based on the user's zodiac sign or birthdate.
# change response_model to JSON later
@router.post("/horoscope")
async def get_horoscope(input_data: InputClass):
    try:
        # Build the prompt using the input data
        prompt = build_prompt(input_data)

        # Get the horoscope from the Gemini API
        horoscope = get_daily_horoscope(input_data.sign, prompt)
        
        # Return the horoscope
        return JSONResponse(content=horoscope)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
