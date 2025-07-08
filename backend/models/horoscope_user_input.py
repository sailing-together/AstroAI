from pydantic import BaseModel, Field   
from datetime import date
from typing import Optional
from backend.services.date_to_sign import date_to_zodiac




class InputClass(BaseModel):
    sign: Optional[str] = Field(default=None, description="The zodiac sign.")
    birthdate: date = Field(description="The birthdate for which to generate the horoscope.")
    
    def __init__(self, **data):
        super().__init__(**data)
        if self.sign is None and self.birthdate is not None:
            self.sign = date_to_zodiac(self.birthdate)



