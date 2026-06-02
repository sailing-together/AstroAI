from fastapi import APIRouter

from backend.api.v1 import chat, health, natal_chart, users, utils

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(health.router)
api_router.include_router(users.router)
api_router.include_router(natal_chart.router)
api_router.include_router(chat.router)
api_router.include_router(utils.router)
