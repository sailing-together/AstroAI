from pydantic import BaseModel, Field
from typing import Optional
from datetime import date
from backend.services.date_to_sign import date_to_zodiac

class UserInput(BaseModel):
    birthdate: date = Field(..., description="Birthdate of the user.")
    sign: Optional[str] = Field(default=None, description="The zodiac sign.")
    celebrity_name: Optional[str] = Field(
        default=None,
        description="Name of the celebrity to be used in the prompt. If not provided, a random celebrity will be selected."
    )

    
    def __init__(self, **data):
        super().__init__(**data)
        if self.sign is None and self.birthdate is not None:
            self.sign = date_to_zodiac(self.birthdate)



    

