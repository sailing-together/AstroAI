from fastapi import APIRouter, Depends

from backend.core.auth import get_current_user
from backend.schemas.user import CurrentUser

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me")
async def get_me(current_user: CurrentUser = Depends(get_current_user)) -> dict[str, str | None]:
    return {
        "id": current_user.auth_id,
        "email": current_user.email,
        "display_name": None,
        "tier": "free",
    }
