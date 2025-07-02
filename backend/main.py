from fastapi import FastAPI
from backend.api import compatibility_logic  # import routers
from backend.api import horoscope_logic  # import routers
from backend.api import review_logic  # import routers
from backend.api import with_celebrity_logic  # import routers
from backend.api import natal_chart_logic
from backend.api import cookies  # shared dependency

app = FastAPI()

## Include the cookies router
app.include_router(cookies.router)  

# Mount feature routers
app.include_router(compatibility_logic.router)
app.include_router(horoscope_logic.router)
app.include_router(review_logic.router)
app.include_router(with_celebrity_logic.router)
app.include_router(natal_chart_logic.router)