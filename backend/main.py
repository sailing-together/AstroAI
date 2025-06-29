from fastapi import FastAPI
#from fastapi.middleware.cors import CORSMiddleware
from backend.api import compatibility_logic  # import routers
from backend.api import horoscope_logic  # import routers
from backend.api import review_logic  # import routers
from backend.api import cookies  # shared dependency

app = FastAPI()

## Include the cookies router
app.include_router(cookies.router)  

# Mount feature routers
app.include_router(compatibility_logic.router)
app.include_router(horoscope_logic.router)
app.include_router(review_logic.router)