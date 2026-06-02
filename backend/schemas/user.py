from pydantic import BaseModel


class CurrentUser(BaseModel):
    auth_id: str
    email: str | None = None
