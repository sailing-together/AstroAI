from datetime import datetime, timezone
from uuid import uuid4

from fastapi import APIRouter, Depends

from backend.core.auth import get_current_user
from backend.core.config import settings
from backend.schemas.chat import ChatRequest, ChatResponse, ChatUsage
from backend.schemas.user import CurrentUser

router = APIRouter(prefix="/chat", tags=["chat"])


@router.post("", response_model=ChatResponse)
async def send_chat_message(
    payload: ChatRequest,
    current_user: CurrentUser = Depends(get_current_user),
) -> ChatResponse:
    return ChatResponse(
        conversation_id=payload.conversation_id or str(uuid4()),
        message_id=str(uuid4()),
        reply="AI Astrologer backend boundary is ready.",
        model=settings.gemini_primary_model,
        usage=ChatUsage(
            tier="free",
            used_today=1,
            daily_limit=settings.ai_chat_free_daily_limit,
        ),
        created_at=datetime.now(timezone.utc).isoformat(),
    )
