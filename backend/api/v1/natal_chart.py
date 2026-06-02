from fastapi import APIRouter, Depends

from backend.core.auth import get_current_user
from backend.schemas.natal_chart import NatalChartRequest
from backend.schemas.user import CurrentUser

router = APIRouter(prefix="/users/me/natal-chart", tags=["natal-chart"])


@router.get("")
async def get_natal_chart(current_user: CurrentUser = Depends(get_current_user)) -> None:
    return None


@router.post("")
async def save_natal_chart(
    payload: NatalChartRequest,
    current_user: CurrentUser = Depends(get_current_user),
) -> dict:
    return {
        "id": "pending-persistence",
        "sun_sign": "Gemini",
        "moon_sign": None,
        "ascendant_sign": None,
        "unknown_time": payload.unknown_time,
        "planets": [],
        "houses": None if payload.unknown_time else [],
        "aspects": [],
        "interpretation": None,
        "created_at": "2026-06-02T00:00:00Z",
        "updated_at": "2026-06-02T00:00:00Z",
    }


@router.delete("")
async def delete_natal_chart(current_user: CurrentUser = Depends(get_current_user)) -> dict[str, bool]:
    return {"deleted": True}
