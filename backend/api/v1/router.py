from fastapi import APIRouter

from backend.api.v1 import health, natal_chart, users

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(health.router)
api_router.include_router(users.router)
api_router.include_router(natal_chart.router)
