from fastapi import FastAPI
from backend.api import compatibility_logic
from backend.api import horoscope_logic
from backend.api import review_logic
from backend.api import with_celebrity_logic
from backend.api import natal_chart_logic
from backend.api import notification_logic
from backend.api import cookies

from contextlib import asynccontextmanager
from backend.services.scheduler_service import start_scheduler, shutdown_scheduler

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup event
    print("Starting scheduler...")
    start_scheduler()
    yield
    # Shutdown event
    print("Shutting down scheduler...")
    shutdown_scheduler()

app = FastAPI(lifespan=lifespan)

## Include the cookies router
app.include_router(cookies.router)  

# Mount feature routers
app.include_router(compatibility_logic.router)
app.include_router(horoscope_logic.router)
app.include_router(review_logic.router)
app.include_router(with_celebrity_logic.router)
app.include_router(natal_chart_logic.router)
app.include_router(notification_logic.router)