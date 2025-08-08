from pydantic import BaseModel, Field, field_validator
from datetime import date, time
from typing import Optional
from backend.services.city_to_timezone import get_timezone_from_location

class UserInput(BaseModel):
    #birth_date and location could be removed when incorporating cookie
    birth_date: date = Field(..., description="User's birth date in YYYY-MM-DD format")
    birth_time: time = Field(None, description="User's birth time in HH:MM format. Do not adjust for timezone")
    birth_location: str = Field(None, description="User's birth location (city, country)")
    birth_timezone: Optional[str] = Field(default=None, description="User's birth timezone. it will be automatically determined from the birth location")
    birth_longitude: Optional[str] = Field(default=None, description="User's birth longitutde, calculated autometically")
    birth_latitude: Optional[str] = Field(default=None, description="User's birth latitude, calculated autometically")

    def model_post_init(self, __context=None):
        info = get_timezone_from_location(self.birth_location, self.birth_date, self.birth_time)

        if self.birth_timezone is None:
            self.birth_timezone = info['utc_offset']
        if self.birth_longitude is None:
            self.birth_longitude = info['longitude']
        if self.birth_latitude is None:
            self.birth_latitude = info['latitude']



