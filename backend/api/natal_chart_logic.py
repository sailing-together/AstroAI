from fastapi import APIRouter, HTTPException
from backend.services.simplified_natal_chart_calculation import get_natal_chart_data
from backend.models.natal_chart_user_input import UserInput
from fastapi.responses import JSONResponse

router = APIRouter()

@router.post("/natal_chart")
async def get_natal_chart(input_data: UserInput):
    try:

        info = get_natal_chart_data(input_data)
        
        # Return the horoscope along with the sign
        return JSONResponse(content=info)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))