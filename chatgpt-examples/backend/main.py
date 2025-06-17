from fastapi import FastAPI
from pydantic import BaseModel
from claude_api import call_claude
from prompt_builder import build_prompt

app = FastAPI()

class UserInput(BaseModel):
    name: str
    birthdate: str

@app.post("/horoscope")
def get_horoscope(user_input: UserInput):
    prompt = build_prompt(user_input.name, user_input.birthdate)
    ai_response = call_claude(prompt)
    return {"result": ai_response}
