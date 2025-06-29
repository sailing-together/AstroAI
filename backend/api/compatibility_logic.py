from fastapi import APIRouter, HTTPException
from backend.services import compatibility_gemini
from fastapi.responses import JSONResponse
from backend.models import compatibility_user_input

router = APIRouter()

@router.post("/compatibility")
async def compatibility(some_input: compatibility_user_input.UserInput):
    try:
        # Get the compatibility result from the Gemini API
        compatibility_result = compatibility_gemini.get_compatibility(some_input)
        
        # Return the compatibility result
        return JSONResponse(content={"compatibility": compatibility_result})

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))