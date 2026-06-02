from datetime import date

from fastapi import APIRouter

from backend.services.zodiac import canonical_sun_sign, sign_label

router = APIRouter(prefix="/utils", tags=["utils"])


@router.get("/sun-sign")
async def get_sun_sign(birth_date: date) -> dict[str, str]:
    sign = canonical_sun_sign(birth_date)
    return {
        "birth_date": birth_date.isoformat(),
        "sun_sign": sign_label(sign),
    }
