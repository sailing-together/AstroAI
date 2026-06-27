from dataclasses import dataclass


class AiSpendLimitExceeded(RuntimeError):
    """Raised when an AI provider call is blocked by FinOps policy."""


@dataclass(frozen=True)
class AiUsageSnapshot:
    feature: str
    tier: str
    model: str
    input_tokens: int
    output_tokens: int
    input_cost_per_million_usd: float
    output_cost_per_million_usd: float
    usd_to_aud: float

    @property
    def estimated_cost_usd(self) -> float:
        input_cost = (self.input_tokens / 1_000_000) * self.input_cost_per_million_usd
        output_cost = (self.output_tokens / 1_000_000) * self.output_cost_per_million_usd
        return input_cost + output_cost

    @property
    def estimated_cost_aud(self) -> float:
        return self.estimated_cost_usd * self.usd_to_aud


def assert_ai_call_allowed(
    *,
    feature: str,
    is_public: bool,
    ai_calls_enabled: bool,
    public_ai_calls_enabled: bool,
    static_generation_ai_enabled: bool,
    spend_limit_aud: float,
    current_spend_aud: float,
    is_static_generation: bool = False,
) -> None:
    if is_public and not public_ai_calls_enabled:
        raise AiSpendLimitExceeded(f"public_ai_disabled:{feature}")

    if is_static_generation and not static_generation_ai_enabled:
        raise AiSpendLimitExceeded(f"static_generation_ai_disabled:{feature}")

    if not is_static_generation and not ai_calls_enabled:
        raise AiSpendLimitExceeded(f"ai_disabled:{feature}")

    if current_spend_aud >= spend_limit_aud:
        raise AiSpendLimitExceeded(f"spend_limit_reached:{feature}")
