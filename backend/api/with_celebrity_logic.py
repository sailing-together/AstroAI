from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from backend.services.with_celebrity_prompt_builder import build_prompt
from backend.services.with_celebrity_gemini import get_response
from backend.models.with_celebrity_user_input import UserInput

router = APIRouter()

@router.post("/with_celebrity")
async def with_celebrity(user_input: UserInput):

    try:
        # Build the prompt based on user input
        prompt = build_prompt(user_input)
        
        # Get the response from the Gemini API
        raw_response = get_response(prompt)
        response = {}
        celebrity_count=1
        for i in raw_response.split("|"):

            response[f"Celebrity {celebrity_count}"] = i
            celebrity_count+=1

        # Return the response
        return JSONResponse(response)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))