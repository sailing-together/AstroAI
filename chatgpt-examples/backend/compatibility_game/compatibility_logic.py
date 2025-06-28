from fastapi import FastAPI, HTTPException
import Gemini_response
from fastapi.responses import JSONResponse
from UserInput import UserInput

app = FastAPI()

@app.post("/compatibility")
async def compatibility(some_input: UserInput):
    try:
        # Get the compatibility result from the Gemini API
        compatibility_result = Gemini_response.get_compatibility(some_input)
        
        # Return the compatibility result
        return JSONResponse(content={"compatibility": compatibility_result})

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))