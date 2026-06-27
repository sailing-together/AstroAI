from backend.core.config import settings
from backend.core.finops import assert_ai_call_allowed


class GeminiClient:
    """Thin Gemini wrapper so route code does not depend on provider details."""

    def __init__(self, current_spend_aud=None) -> None:
        self.primary_model_name = settings.gemini_primary_model
        self.light_model_name = settings.gemini_light_model
        self._current_spend_aud = current_spend_aud or (lambda: 0)

    def _model(self, model_name: str):
        import google.generativeai as genai

        genai.configure(api_key=settings.gemini_api_key)
        return genai.GenerativeModel(model_name)

    def _assert_allowed(
        self,
        *,
        feature: str,
        is_public: bool,
        is_static_generation: bool,
    ) -> None:
        assert_ai_call_allowed(
            feature=feature,
            is_public=is_public,
            is_static_generation=is_static_generation,
            ai_calls_enabled=settings.ai_calls_enabled,
            public_ai_calls_enabled=settings.public_ai_calls_enabled,
            static_generation_ai_enabled=settings.static_generation_ai_enabled,
            spend_limit_aud=settings.ai_spend_limit_aud,
            current_spend_aud=self._current_spend_aud(),
        )

    async def generate_primary(
        self,
        prompt: str,
        *,
        feature: str = "gemini_primary",
        is_public: bool = False,
    ) -> str:
        self._assert_allowed(
            feature=feature,
            is_public=is_public,
            is_static_generation=False,
        )
        response = self._model(self.primary_model_name).generate_content(prompt)
        return response.text.strip()

    async def generate_light(
        self,
        prompt: str,
        *,
        feature: str = "gemini_light",
        is_public: bool = False,
        is_static_generation: bool = False,
    ) -> str:
        self._assert_allowed(
            feature=feature,
            is_public=is_public,
            is_static_generation=is_static_generation,
        )
        response = self._model(self.light_model_name).generate_content(prompt)
        return response.text.strip()
