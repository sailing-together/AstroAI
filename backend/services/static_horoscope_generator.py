from dataclasses import dataclass

from backend.core.config import settings
from backend.schemas.horoscope import SUPPORTED_HOROSCOPE_FOCUSES


@dataclass(frozen=True)
class HoroscopeGenerationRequest:
    sign: str
    period: str
    year: int


@dataclass(frozen=True)
class HoroscopeGenerationPayload:
    sign: str
    period: str
    year: int
    focus: str
    model_name: str
    prompt: str


class StaticHoroscopeGenerator:
    def __init__(self) -> None:
        self.model_name = settings.gemini_light_model

    def build_generation_payloads(
        self,
        request: HoroscopeGenerationRequest,
    ) -> list[HoroscopeGenerationPayload]:
        return [
            HoroscopeGenerationPayload(
                sign=request.sign,
                period=request.period,
                year=request.year,
                focus=focus,
                model_name=self.model_name,
                prompt=_build_prompt(request.sign, request.period, request.year, focus),
            )
            for focus in SUPPORTED_HOROSCOPE_FOCUSES
        ]


def _build_prompt(sign: str, period: str, year: int, focus: str) -> str:
    return (
        f"Generate stored public {period} horoscope copy for {sign} in {year}. "
        f"Focus: {focus}. Return title, summary, body, lucky_numbers, and lucky_color."
    )
