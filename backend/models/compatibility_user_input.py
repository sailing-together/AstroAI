from pydantic import BaseModel, Field  

class UserInput(BaseModel):
    sign_1: str = Field(..., description="The input sign used for compability.")
    sign_2: str = Field(..., description="The input sign used for compability.")