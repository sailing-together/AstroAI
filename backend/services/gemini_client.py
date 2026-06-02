from backend.core.config import settings


class GeminiClient:
    """Thin Gemini wrapper so route code does not depend on provider details."""

    def __init__(self) -> None:
        self.primary_model_name = settings.gemini_primary_model
        self.light_model_name = settings.gemini_light_model

    def _model(self, model_name: str):
        import google.generativeai as genai

        genai.configure(api_key=settings.gemini_api_key)
        return genai.GenerativeModel(model_name)

    async def generate_primary(self, prompt: str) -> str:
        response = self._model(self.primary_model_name).generate_content(prompt)
        return response.text.strip()

    async def generate_light(self, prompt: str) -> str:
        response = self._model(self.light_model_name).generate_content(prompt)
        return response.text.strip()
