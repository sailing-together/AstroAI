from backend.services.review_event_gemini import get_response
from backend.models.review_event_user_input import UserInput
from fastapi import HTTPException, APIRouter
from fastapi.responses import JSONResponse
from backend.services.review_event_prompt_builder import build_prompt

router = APIRouter()

@router.post("/review_event")
async def review_event(user_input: UserInput):
    try:
        # Build the prompt based on user input
        prompt = build_prompt(user_input)
        
        # Get the response from Gemini API
        response_text = get_response(prompt)
        
        return JSONResponse(content={"response": response_text})
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))