from backend.services.review_event_gemini import get_response
from backend.models.review_event_user_input import UserInput
from fastapi import HTTPException, APIRouter, Depends
from fastapi.responses import JSONResponse
from backend.services.review_event_prompt_builder import build_prompt
from backend.api.cookies import get_user_info_cookie


router = APIRouter()

@router.post("/review_event")
async def review_event(user_input: UserInput, 
                       cookie_info: dict = Depends(get_user_info_cookie)):
    
    #print("Received cookie info:", cookie_info)


    try:
        # Build the prompt based on user input
        prompt = build_prompt(user_input, cookie_info)
        
        # Get the response from Gemini API
        response_text = get_response(prompt)
        
        return JSONResponse(content={"response": response_text})
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))