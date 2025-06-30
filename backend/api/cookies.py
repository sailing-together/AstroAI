from fastapi import APIRouter, Request, Response, HTTPException
import json
from datetime import datetime

router = APIRouter()

# Endpoint to save data as a cookie
@router.post("/save-data")
async def save_data(request: Request, response: Response):
    form_data = await request.form()

    # Create structured data
    cookie_info = {
        "birthday": form_data["birthday"],
        "location": form_data["location"]
    }
    
    # Convert to JSON string for cookie storage
    cookie_info_json = json.dumps(cookie_info)

    # Set a plain-text cookie (no encryption)
    response.set_cookie(
        key="user_data_cookie",          # Cookie name
        value=cookie_info_json,         # Store user input directly
        max_age=3600,             # Expires in 1 hour (set to `None` for session cookie)
        httponly=True,            # Prevent JavaScript access (mild security)
    )
    return {"status": "Data saved in cookie!"}

# shared dependency to read cookie
async def get_user_info_cookie(request: Request):

    cookie_info = request.cookies.get("user_data_cookie")
    if not cookie_info:
        raise HTTPException(
            status_code=400,
            detail="User info cookie not found. Please complete /save-data form first."
        )
    try:
        return json.loads(cookie_info)  # Returns dict with birthday/location
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid cookie data")