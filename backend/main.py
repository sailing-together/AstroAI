from fastapi import FastAPI
from backend.api import compatibility_logic  # import routers
from backend.api import horoscope_logic  # import routers
from backend.api import review_logic  # import routers
from backend.api import with_celebrity_logic  # import routers
from backend.api import cookies  # shared dependency

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 或指定你的前端地址如 "http://localhost:8080"
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

## Include the cookies router
app.include_router(cookies.router)  

# Mount feature routers
app.include_router(compatibility_logic.router)
app.include_router(horoscope_logic.router)
app.include_router(review_logic.router)
app.include_router(with_celebrity_logic.router)
