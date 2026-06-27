import pytest

from backend.core.finops import AiSpendLimitExceeded, AiUsageSnapshot, assert_ai_call_allowed


def test_public_ai_calls_are_blocked_even_when_ai_is_enabled():
    with pytest.raises(AiSpendLimitExceeded, match="public_ai_disabled"):
        assert_ai_call_allowed(
            feature="public_horoscope",
            is_public=True,
            ai_calls_enabled=True,
            public_ai_calls_enabled=False,
            static_generation_ai_enabled=False,
            spend_limit_aud=100,
            current_spend_aud=0,
        )


def test_live_ai_calls_are_blocked_when_global_switch_is_off():
    with pytest.raises(AiSpendLimitExceeded, match="ai_disabled"):
        assert_ai_call_allowed(
            feature="chat",
            is_public=False,
            ai_calls_enabled=False,
            public_ai_calls_enabled=False,
            static_generation_ai_enabled=False,
            spend_limit_aud=100,
            current_spend_aud=0,
        )


def test_live_ai_calls_are_blocked_at_spend_limit():
    with pytest.raises(AiSpendLimitExceeded, match="spend_limit_reached"):
        assert_ai_call_allowed(
            feature="chat",
            is_public=False,
            ai_calls_enabled=True,
            public_ai_calls_enabled=False,
            static_generation_ai_enabled=False,
            spend_limit_aud=100,
            current_spend_aud=100,
        )


def test_operator_static_generation_uses_separate_switch():
    with pytest.raises(AiSpendLimitExceeded, match="static_generation_ai_disabled"):
        assert_ai_call_allowed(
            feature="static_generation",
            is_public=False,
            is_static_generation=True,
            ai_calls_enabled=True,
            public_ai_calls_enabled=False,
            static_generation_ai_enabled=False,
            spend_limit_aud=100,
            current_spend_aud=0,
        )


def test_usage_snapshot_estimates_cost_in_aud():
    usage = AiUsageSnapshot(
        feature="chat",
        tier="free",
        model="gemini-2.5-flash",
        input_tokens=1_000,
        output_tokens=500,
        input_cost_per_million_usd=0.30,
        output_cost_per_million_usd=2.50,
        usd_to_aud=1.5,
    )

    assert usage.estimated_cost_usd == pytest.approx(0.00155)
    assert usage.estimated_cost_aud == pytest.approx(0.002325)
