from fastapi import APIRouter, HTTPException, Depends
from backend.database.crud import insert_all_data, clear_past_entries, get_todays_events
from backend.database.models import LunarEvent, PlanetaryRetrograde, PlanetaryIngress
from fastapi.responses import JSONResponse


router = APIRouter()



@router.post("/update-database/")
async def update_database():
    try:
        insert_all_data()
        return {"status": "success", "message": "Database updated successfully"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/admin/clear-past-events/")
async def clear_events():
    try:
        clear_past_entries()
        return {"status": "success", "message": "Past events cleared successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/events-today")
async def get_events_today():
    try:
        events = get_todays_events()
        return JSONResponse(content=events)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
