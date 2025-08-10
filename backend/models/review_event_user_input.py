from pydantic import BaseModel, Field, model_validator
from datetime import datetime, date
from typing import Optional

class UserInput(BaseModel):
    event: str = Field(..., description="What event is being reviewed")
    event_date: date = Field(..., description="What date the event occurred")
    birthdate: date = Field(..., description="The user's birthdate.")
    location: str = Field(..., description="The user's location.")
    outcome: Optional[str] = Field(
        None,
        description="Required if event date is in past. What was the outcome?"
    )

    @model_validator(mode='after')
    def validate_outcome_required_for_past_events(self):
        if self.event_date < datetime.now().date():
            if self.outcome is None:
                #this somehow doesn't work, does not return error
                raise ValueError("Outcome is required for past events")
        else:
            # Clear outcome if it was provided for future event
            self.outcome = None
        return self

    class Config:
        extra = "forbid"  # Prevent extra fields from being provided