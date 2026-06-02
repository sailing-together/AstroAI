# AstroAI — Prompt Architecture Specification

> **Last updated:** June 2026
> **Author:** AI Engineering
> **Status:** Authoritative engineering spec for all AI prompt design, routing, and response schemas.

---

## Table of Contents

1. [Prompt Registry Structure](#1-prompt-registry-structure)
2. [AI Astrologer System Prompt](#2-ai-astrologer-system-prompt)
3. [Context Loading Strategy](#3-context-loading-strategy)
4. [Memory Retrieval](#4-memory-retrieval)
5. [Pydantic Response Schemas](#5-pydantic-response-schemas)
6. [Model Routing Table](#6-model-routing-table)
7. [Prompt Versioning and A/B Testing](#7-prompt-versioning-and-ab-testing)

---

## 1. Prompt Registry Structure

All prompts live under `backend/prompts/`. No prompt strings are scattered across service files. This is the single source of truth for every AI call in the system.

### Directory Layout

```
backend/
  prompts/
    __init__.py                  # PromptRegistry class — loads and validates all prompts
    registry.py                  # Central registry: maps task keys to PromptDefinition objects
    base.py                      # Base classes: PromptDefinition, PromptVersion, ModelTarget
    #
    # One file per prompt type, named {task}_{vN}.py
    # Active version is registered in registry.py
    #
    assistant_v1.py              # AI Astrologer system prompt + turn structure
    horoscope_v1.py              # Daily horoscope (batch, sign + focus area)
    natal_chart_v1.py            # Full natal chart interpretation (one-time per user)
    tarot_fusion_v1.py           # Tarot + Astrology fusion reading
    compatibility_v1.py          # Compatibility report (sign-pair or two natal charts)
    mood_insight_v1.py           # Weekly mood correlation insight
```

### `base.py` — Core Abstractions

```python
# backend/prompts/base.py

from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum
from typing import Type, Optional
from pydantic import BaseModel


class ModelTarget(str, Enum):
    GEMINI_FLASH = "gemini-2.0-flash"
    CLAUDE_SONNET = "claude-sonnet-4-5"


class PromptType(str, Enum):
    BATCH      = "batch"       # Pre-generated nightly; no user context required
    ON_DEMAND  = "on_demand"   # User-triggered; requires user context at runtime


@dataclass
class PromptDefinition:
    """
    A single versioned prompt. Every AI call in the system has exactly one
    PromptDefinition registered in the PromptRegistry.
    """
    key: str                          # Unique identifier: "assistant", "horoscope", etc.
    version: int                      # Monotonically increasing integer
    prompt_type: PromptType
    model_target: ModelTarget
    response_schema: Type[BaseModel]  # Pydantic model — enforces structured JSON output
    system_prompt: str                # Full system prompt text (for Sonnet) or None
    user_prompt_template: str         # Jinja2 template for the user-turn prompt
    max_output_tokens: int
    temperature: float
    cache_ttl_seconds: Optional[int]  # None = do not cache (on-demand personalized calls)
    description: str = ""             # Human-readable description for the registry UI

    @property
    def full_key(self) -> str:
        return f"{self.key}_v{self.version}"
```

### `registry.py` — Central Registry

```python
# backend/prompts/registry.py

from backend.prompts.base import PromptDefinition, ModelTarget, PromptType
from backend.prompts import (
    assistant_v1,
    horoscope_v1,
    natal_chart_v1,
    tarot_fusion_v1,
    compatibility_v1,
    mood_insight_v1,
)

# Maps task key → active PromptDefinition.
# To A/B test: register two definitions under different experiment keys
# and route via the PromptRouter (see Section 7).
PROMPT_REGISTRY: dict[str, PromptDefinition] = {
    "assistant":      assistant_v1.DEFINITION,
    "horoscope":      horoscope_v1.DEFINITION,
    "natal_chart":    natal_chart_v1.DEFINITION,
    "tarot_fusion":   tarot_fusion_v1.DEFINITION,
    "compatibility":  compatibility_v1.DEFINITION,
    "mood_insight":   mood_insight_v1.DEFINITION,
}


class PromptRegistry:
    """Singleton accessor. Import this, not the dict directly."""

    def __init__(self, registry: dict[str, PromptDefinition] = PROMPT_REGISTRY):
        self._registry = registry

    def get(self, key: str) -> PromptDefinition:
        if key not in self._registry:
            raise KeyError(f"No prompt registered for key '{key}'. "
                           f"Available: {list(self._registry.keys())}")
        return self._registry[key]

    def all(self) -> list[PromptDefinition]:
        return list(self._registry.values())


prompt_registry = PromptRegistry()
```

### Prompt File Convention

Each prompt file follows this structure:

```python
# backend/prompts/horoscope_v1.py

from backend.prompts.base import PromptDefinition, ModelTarget, PromptType
from backend.prompts.schemas import DailyHoroscopeResponse

SYSTEM_PROMPT = None  # Gemini Flash: system instruction goes into the user prompt block

USER_PROMPT_TEMPLATE = """
You are an expert astrologer generating a daily horoscope.
...
"""

DEFINITION = PromptDefinition(
    key="horoscope",
    version=1,
    prompt_type=PromptType.BATCH,
    model_target=ModelTarget.GEMINI_FLASH,
    response_schema=DailyHoroscopeResponse,
    system_prompt=SYSTEM_PROMPT,
    user_prompt_template=USER_PROMPT_TEMPLATE,
    max_output_tokens=512,
    temperature=0.75,
    cache_ttl_seconds=86400,  # 24h
    description="Daily horoscope by sun sign + focus area. Batch-generated nightly.",
)
```

---

## 2. AI Astrologer System Prompt

This is the core prompt for the `assistant_v1.py` prompt definition. It is the system prompt loaded into every Claude Sonnet call for the AI Astrologer feature. It is never modified at runtime — context is injected via the user-turn template (see Section 3).

### System Prompt (full text)

```
You are Lyra, the AI Astrologer for AstroAI. You are a warm, deeply knowledgeable
astrologer with the emotional attunement of a good therapist and the precision of an
astronomer. You have access to this user's complete natal chart, the current planetary
transits, and memories of important events they have shared with you in the past.

IDENTITY AND TONE
- You are specific, never generic. You know this person's full chart — Sun, Moon,
  Ascendant, every planet, every house. Never say "as a [Sun Sign]..." when you have
  their whole chart in front of you. Always anchor your response to the exact placements
  that are relevant to their question.
- You are warm and emotionally attuned. You notice the feeling underneath the question.
  If someone asks "should I take this job?", you hear "I'm anxious about this decision."
  Reflect that before you analyze.
- You speak plainly. Astrological terms are fine, but always translate them. Do not say
  "your natal Mars in Scorpio in the 8th house is sesquiquadrate your progressed Venus"
  without immediately explaining what that means in plain life terms.
- Your tone is like a trusted friend who happens to have deep astrological knowledge —
  not a fortune teller, not a therapist, not a motivational speaker. Grounded. Specific.
  Real.
- You give your actual perspective. When the chart speaks clearly, say so. When it is
  ambiguous, say that too. You do not hedge every sentence into meaninglessness.
- You never use filler phrases like "embrace your journey", "unlock your potential",
  "the stars are aligned", or "trust the universe". These are signals of generic output.
  Replace them with specific chart observations.

WHAT YOU HAVE ACCESS TO
You will always receive, as structured context in the user turn:
1. The user's full natal chart — all planets, signs, degrees, houses, and major aspects.
2. Today's active transits — what is happening in the sky today and how each transit
   aspects the user's natal positions.
3. Relevant memory entries — past events, feelings, and decisions the user has shared,
   ranked by relevance to the current question.
4. Today's date.

Use all of this. A question about a relationship should draw on Venus, 7th house ruler,
natal aspects involving Venus, AND any memories about the relationship the user has
previously shared. A question about work should draw on 10th house, Saturn, MC,
and relevant memories about career events.

MEMORY AND CONTINUITY
If a memory is loaded that is directly relevant to the question, reference it
naturally. For example: "You mentioned last month that you were feeling stuck in this
relationship — with Venus now moving through your 7th house, that feeling makes even
more astrological sense." This creates the experience of being known.

Do not invent or hallucinate memories. Only reference memories that are explicitly
provided in your context. If no relevant memories are loaded, do not pretend to remember
something.

ACCURACY AND LIMITATIONS
- Astrology is a framework for self-reflection, not prediction. Present it as such.
  Use language like "this transit often coincides with...", "astrologically, this is a
  period that tends to...", "your chart suggests a pattern of...".
- Never state an outcome as certain. "You will get the job" is always wrong. "Your
  chart for the next three weeks shows strong indicators for career momentum" is right.
- Do not diagnose, prescribe, or give medical advice. If someone asks about a physical
  symptom, health condition, or medication, warmly redirect: "I'm not the right guide
  for medical questions — I'd encourage you to speak with a doctor. What I can offer is
  what the chart says about your energy and vitality right now."
- Do not give legal or financial advice as fact. Astrology can frame timing and energy;
  it cannot replace a lawyer or financial advisor. Say so clearly and gently.
- Do not give definitive pronouncements about third parties ("your partner is
  manipulative", "your boss is a narcissist"). You have one chart in front of you —
  theirs. You can describe dynamics; you cannot diagnose other people.

EMOTIONAL SAFETY GUARDRAILS
- If a user expresses distress, crisis, self-harm ideation, or suicidal thoughts: set
  aside astrology entirely. Respond with care and direct them to appropriate support.
  Example: "What you're describing sounds really painful, and I want to make sure you
  have the right support right now. Please reach out to a crisis line [include local
  resource] or a mental health professional. I care about you and I'm here, but this is
  beyond what astrology can hold." Do not return to astrological content in that turn.
- If a user is in a spiral of self-criticism framed through astrology ("of course I'm
  like this, I'm a [sign]", "my chart is ruined", "I'm just always going to be broken"),
  gently interrupt the pattern. Astrology is a map, not a sentence.
- If a user asks you to confirm a harmful belief ("the chart proves my ex is evil",
  "astrology says I should quit my meds"), do not comply. Redirect clearly.

RESPONSE FORMAT
Responses are returned as structured JSON matching the AstrologerMessageResponse schema.
The `message` field is your primary response in plain text (no markdown headers in the
message body — just natural prose, 2–5 paragraphs for a typical reply).
The `highlighted_placements` field lists the 1–3 most relevant natal placements you drew
on, so the frontend can surface them visually.
The `active_transit_reference` field lists the 1–2 most relevant transits to the
question.
The `memory_references_used` field lists the IDs of any AIMemory entries you drew on.
The `follow_up_questions` field optionally provides 1–2 short questions that would help
you give an even better answer. Only include these if genuinely useful — do not pad.
```

### User-Turn Template (Jinja2)

```python
# backend/prompts/assistant_v1.py  (user_prompt_template portion)

USER_PROMPT_TEMPLATE = """
--- CONTEXT START ---

TODAY'S DATE: {{ today }}

NATAL CHART FOR {{ user_name }}:
Sun:       {{ natal.sun.sign }} {{ natal.sun.degree }}° | House {{ natal.sun.house }}
Moon:      {{ natal.moon.sign }} {{ natal.moon.degree }}° | House {{ natal.moon.house }}
Ascendant: {{ natal.ascendant.sign }} {{ natal.ascendant.degree }}°
Mercury:   {{ natal.mercury.sign }} {{ natal.mercury.degree }}° | House {{ natal.mercury.house }}
Venus:     {{ natal.venus.sign }} {{ natal.venus.degree }}° | House {{ natal.venus.house }}
Mars:      {{ natal.mars.sign }} {{ natal.mars.degree }}° | House {{ natal.mars.house }}
Jupiter:   {{ natal.jupiter.sign }} {{ natal.jupiter.degree }}° | House {{ natal.jupiter.house }}
Saturn:    {{ natal.saturn.sign }} {{ natal.saturn.degree }}° | House {{ natal.saturn.house }}
Uranus:    {{ natal.uranus.sign }} {{ natal.uranus.degree }}° | House {{ natal.uranus.house }}
Neptune:   {{ natal.neptune.sign }} {{ natal.neptune.degree }}° | House {{ natal.neptune.house }}
Pluto:     {{ natal.pluto.sign }} {{ natal.pluto.degree }}° | House {{ natal.pluto.house }}

MAJOR ASPECTS:
{% for aspect in natal.aspects %}
  {{ aspect.planet1 }} {{ aspect.type }} {{ aspect.planet2 }} (orb: {{ aspect.orb }}°)
{% endfor %}

ACTIVE TRANSITS TODAY (transit planet → natal planet/point):
{% for transit in active_transits %}
  {{ transit.transit_planet }} {{ transit.aspect_type }} natal {{ transit.natal_point }}
  — exact: {{ transit.exact_date }} | applying: {{ transit.is_applying }}
  — influence: {{ transit.influence_summary }}
{% endfor %}

RELEVANT MEMORY ENTRIES (ranked by relevance to the current question):
{% for memory in relevant_memories %}
[MEMORY ID: {{ memory.id }}]
Date: {{ memory.date }} | Type: {{ memory.entry_type }}
{{ memory.content }}
Planetary context at that time: {{ memory.planetary_context_summary }}
---
{% endfor %}

--- CONTEXT END ---

USER'S QUESTION: {{ user_message }}
"""
```

---

## 3. Context Loading Strategy

Context assembly happens in `backend/services/context_builder.py` before every AI Astrologer API call. The goal is to provide the richest possible context within the token budget, with graceful degradation when data is sparse or the window is tight.

### Token Budget

| Context Block | Target Tokens | Hard Cap | Notes |
|---|---|---|---|
| System prompt (Lyra) | ~700 | 800 | Fixed; do not exceed |
| Natal chart block | ~300 | 350 | All planets + aspects as structured text |
| Active transits block | ~400 | 500 | Top 8 transits by relevance; trimmed if over |
| Memory entries block | ~500 | 800 | Variable; semantic search determines count |
| User message (current turn) | ~200 | 400 | Capped by input validation |
| Conversation history | ~500 | 700 | Last 5 turns (rolling window) |
| **Total context** | **~2,600** | **3,550** | Well within Claude Sonnet's 200K window |

The Claude Sonnet context window is not a binding constraint for individual conversations. Token budgeting is primarily a cost control mechanism. The caps above are reviewed quarterly against usage data.

### Assembly Code

```python
# backend/services/context_builder.py

from __future__ import annotations
from dataclasses import dataclass
from datetime import date
from typing import Optional
from jinja2 import Template

from backend.database.crud import get_natal_chart, get_conversation_history
from backend.services.transit_calculator import get_active_transits
from backend.services.memory_retrieval import retrieve_relevant_memories
from backend.prompts.assistant_v1 import USER_PROMPT_TEMPLATE


@dataclass
class AssistantContext:
    user_id: str
    user_name: str
    natal: dict            # Full planet/house data from NatalChart record
    active_transits: list  # Scored and filtered transit list
    relevant_memories: list  # Retrieved AIMemory entries, ranked
    conversation_history: list  # Last N turns
    today: date


async def build_assistant_context(
    user_id: str,
    user_message: str,
    db,
) -> tuple[str, AssistantContext]:
    """
    Assembles all context needed for an AI Astrologer turn.
    Returns (rendered_user_prompt, context_object).
    The context object is stored for logging and memory extraction.
    """
    today = date.today()

    # 1. Load natal chart (cached in Redis: natal_chart_reading:{user_id})
    natal_chart = await get_natal_chart(user_id, db)
    if natal_chart is None:
        raise ValueError(f"No natal chart found for user {user_id}. "
                         "User must complete onboarding before using AI Astrologer.")

    # 2. Compute active transits (local pyswisseph — zero API cost)
    active_transits = get_active_transits(
        natal_positions=natal_chart.planets,
        target_date=today,
        top_n=8,           # Max 8 transits; ranked by orb tightness + slow-planet priority
    )

    # 3. Retrieve relevant memories (semantic search + recency — see Section 4)
    relevant_memories = await retrieve_relevant_memories(
        user_id=user_id,
        query_text=user_message,
        top_k=5,
        max_tokens=800,
        db=db,
    )

    # 4. Load conversation history (last 5 turns, rolling)
    conversation_history = await get_conversation_history(
        user_id=user_id,
        last_n_turns=5,
        db=db,
    )

    # 5. Render the user-turn prompt via Jinja2
    template = Template(USER_PROMPT_TEMPLATE)
    rendered_prompt = template.render(
        today=today.isoformat(),
        user_name=natal_chart.user_name or "you",
        natal=_format_natal_for_template(natal_chart),
        active_transits=active_transits,
        relevant_memories=relevant_memories,
        user_message=user_message,
    )

    ctx = AssistantContext(
        user_id=user_id,
        user_name=natal_chart.user_name or "",
        natal=natal_chart.planets,
        active_transits=active_transits,
        relevant_memories=relevant_memories,
        conversation_history=conversation_history,
        today=today,
    )
    return rendered_prompt, ctx


def _format_natal_for_template(natal_chart) -> dict:
    """
    Converts the NatalChart database model into a flat dict
    keyed by lowercase planet name for template rendering.
    """
    planets_by_name = {p["name"].lower(): p for p in natal_chart.planets}
    return {
        "sun": planets_by_name.get("sun"),
        "moon": planets_by_name.get("moon"),
        "ascendant": {
            "sign": natal_chart.ascendant,
            "degree": natal_chart.ascendant_degree,
        },
        "mercury":  planets_by_name.get("mercury"),
        "venus":    planets_by_name.get("venus"),
        "mars":     planets_by_name.get("mars"),
        "jupiter":  planets_by_name.get("jupiter"),
        "saturn":   planets_by_name.get("saturn"),
        "uranus":   planets_by_name.get("uranus"),
        "neptune":  planets_by_name.get("neptune"),
        "pluto":    planets_by_name.get("pluto"),
        "aspects":  natal_chart.aspects,
    }
```

### Transit Ranking Logic

Transits are scored before inclusion in context. The scorer lives in `backend/services/transit_calculator.py`:

```python
def score_transit(transit: Transit) -> float:
    """
    Score a transit for context inclusion priority.
    Higher score = more important = include first.
    """
    # Slow outer planets are more significant and longer-lasting
    planet_weight = {
        "Pluto": 3.0, "Neptune": 2.8, "Uranus": 2.5,
        "Saturn": 2.2, "Jupiter": 1.8, "Mars": 1.4,
        "Venus": 1.1, "Mercury": 1.0, "Sun": 1.2, "Moon": 0.7,
    }
    # Tighter orb = more powerful transit
    orb_score = max(0, 1.0 - (transit.orb_degrees / transit.max_orb))

    # Applying (approaching exact) transits are more potent than separating
    application_bonus = 0.3 if transit.is_applying else 0.0

    # Exact hits within 1 degree are flagged prominently
    exactness_bonus = 0.5 if transit.orb_degrees <= 1.0 else 0.0

    return (
        planet_weight.get(transit.transit_planet, 1.0) *
        orb_score +
        application_bonus +
        exactness_bonus
    )
```

### Context Window Overflow Handling

If the assembled prompt exceeds the hard cap (3,550 tokens), apply these degradation steps in order:

1. Trim conversation history from 5 turns to 3 turns (saves ~200 tokens).
2. Drop the lowest-scoring memory entry (repeat until within budget).
3. Drop the lowest-scoring transit (repeat until within budget).
4. If still over budget: raise a warning, log the user ID, and proceed with the truncated context. Do not silently drop the natal chart block.

The natal chart block is never truncated — it is the irreducible core of every personalized response.

---

## 4. Memory Retrieval

AIMemory entries are retrieved from PostgreSQL (Supabase) using a hybrid ranking strategy: semantic similarity via pgvector + recency weighting. The goal is to surface memories that are both *about the same topic* as the user's current question and *recent enough to be relevant*.

### Storage

Each AIMemory row includes a `embedding` column (`vector(1536)`) populated at write time:

```sql
-- In the Supabase migration for AIMemory
ALTER TABLE ai_memory ADD COLUMN embedding vector(1536);
CREATE INDEX ON ai_memory USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
```

Embeddings are generated using the `text-embedding-3-small` model (OpenAI) or Gemini's `text-embedding-004` model. The embedding is created from the `content` field of the AIMemory entry when it is first saved.

### Retrieval Implementation

```python
# backend/services/memory_retrieval.py

import math
from datetime import date
from typing import Optional
import anthropic
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text


EMBEDDING_MODEL = "text-embedding-3-small"   # 1536 dimensions, cheap, fast
RECENCY_HALF_LIFE_DAYS = 90                  # Memory older than 90 days = half relevance weight
SEMANTIC_WEIGHT = 0.7
RECENCY_WEIGHT = 0.3


async def retrieve_relevant_memories(
    user_id: str,
    query_text: str,
    top_k: int = 5,
    max_tokens: int = 800,
    db: AsyncSession = None,
) -> list[dict]:
    """
    Retrieves the most relevant AIMemory entries for the current user question.

    Strategy:
      1. Embed the user's question.
      2. Run pgvector cosine similarity search for candidate memories (top 20).
      3. Re-rank by hybrid score: semantic_similarity * 0.7 + recency_score * 0.3.
      4. Return top_k after re-ranking, trimmed to max_tokens.
    """
    query_embedding = await _embed_text(query_text)

    # Step 1: Candidate retrieval via pgvector ANN search
    candidates = await db.execute(
        text("""
            SELECT
                id, content, entry_type, date, planetary_context,
                1 - (embedding <=> :embedding) AS cosine_similarity
            FROM ai_memory
            WHERE user_id = :user_id
            ORDER BY embedding <=> :embedding
            LIMIT 20
        """),
        {"user_id": user_id, "embedding": query_embedding},
    )
    rows = candidates.fetchall()

    if not rows:
        return []

    today = date.today()

    # Step 2: Hybrid re-ranking
    scored = []
    for row in rows:
        semantic_score = float(row.cosine_similarity)
        age_days = (today - row.date).days
        recency_score = math.exp(-math.log(2) * age_days / RECENCY_HALF_LIFE_DAYS)
        hybrid_score = (SEMANTIC_WEIGHT * semantic_score) + (RECENCY_WEIGHT * recency_score)
        scored.append((hybrid_score, row))

    scored.sort(key=lambda x: x[0], reverse=True)
    top_memories = [row for _, row in scored[:top_k]]

    # Step 3: Token budget trimming (approximate; 1 token ≈ 4 characters)
    result = []
    accumulated_chars = 0
    char_budget = max_tokens * 4

    for row in top_memories:
        entry = {
            "id": str(row.id),
            "content": row.content,
            "entry_type": row.entry_type,
            "date": row.date.isoformat(),
            "planetary_context_summary": _summarize_planetary_context(row.planetary_context),
        }
        entry_chars = len(row.content) + 100  # 100 chars overhead per entry for template
        if accumulated_chars + entry_chars > char_budget:
            break
        result.append(entry)
        accumulated_chars += entry_chars

    return result


async def _embed_text(text: str) -> list[float]:
    """
    Generate an embedding for the given text.
    Uses OpenAI text-embedding-3-small (1536 dimensions).
    Switch to Gemini text-embedding-004 if OpenAI is not available.
    """
    import openai
    response = await openai.AsyncClient().embeddings.create(
        model=EMBEDDING_MODEL,
        input=text,
    )
    return response.data[0].embedding


def _summarize_planetary_context(planetary_context: dict) -> str:
    """
    Produces a 1-line human-readable summary of the planetary snapshot
    stored with the memory entry.
    Example: "Mars conjunct natal Moon; Saturn square natal Sun"
    """
    if not planetary_context or not planetary_context.get("active_transits"):
        return "No transit context recorded."
    transits = planetary_context["active_transits"][:3]  # Top 3 only for context block
    return "; ".join(
        f"{t['transit_planet']} {t['aspect_type']} natal {t['natal_point']}"
        for t in transits
    )
```

### Memory Write Path

When the AI Astrologer conversation ends (or the user explicitly tags a message as a memory), extract and store new AIMemory entries:

```python
# backend/services/memory_extractor.py

async def extract_and_store_memory(
    user_id: str,
    user_message: str,
    ai_response: "AstrologerMessageResponse",
    current_transits: list,
    db: AsyncSession,
) -> Optional[str]:
    """
    After each AI Astrologer turn, determine if the user's message contains
    a memory-worthy event, feeling, decision, or outcome.
    If yes, embed and store it.

    Memory extraction is done with a lightweight Gemini Flash call —
    NOT Claude Sonnet, to keep cost low.
    Returns the new memory ID if one was created, else None.
    """
    # Gemini Flash: "Does this message contain a personal event, feeling, decision,
    # or outcome the user wants remembered? If yes, extract it in structured form."
    # Uses MemoryExtractionResponse schema (see Section 5).
    ...
```

### Recency Weighting Rationale

A half-life of 90 days was chosen because:
- Astrological cycles (Saturn transits, Jupiter transits) operate on 1–3 year timescales.
  Memories from 6 months ago are often still cosmically relevant.
- User emotions from 3+ months ago are usually less actionable for the current question.
- The 70/30 semantic/recency split means a highly semantically relevant memory from
  18 months ago will still outrank a vaguely related memory from yesterday.

This weighting is a tunable parameter — store it in the environment config, not hardcoded:

```python
# backend/core/config.py
MEMORY_SEMANTIC_WEIGHT: float = float(os.getenv("MEMORY_SEMANTIC_WEIGHT", "0.7"))
MEMORY_RECENCY_HALF_LIFE_DAYS: int = int(os.getenv("MEMORY_RECENCY_HALF_LIFE_DAYS", "90"))
```

---

## 5. Pydantic Response Schemas

All schemas live in `backend/prompts/schemas.py`. Every AI call uses one of these as its structured output schema. No free-form text is parsed anywhere in the AI layer.

```python
# backend/prompts/schemas.py

from __future__ import annotations
from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import date


# ──────────────────────────────────────────────────────────────────────────────
# 5.1  AI Astrologer Message Response
# Model: Claude Sonnet | Prompt: assistant_v1
# ──────────────────────────────────────────────────────────────────────────────

class HighlightedPlacement(BaseModel):
    planet: str                # e.g. "Venus"
    sign: str                  # e.g. "Scorpio"
    house: int                 # e.g. 8
    degree: float              # e.g. 14.3
    relevance_note: str        # 1-sentence explanation of why this placement matters here


class TransitReference(BaseModel):
    transit_planet: str        # e.g. "Jupiter"
    aspect_type: str           # e.g. "trine"
    natal_point: str           # e.g. "natal Venus"
    is_applying: bool
    influence_summary: str     # 1-sentence description of this transit's themes


class AstrologerMessageResponse(BaseModel):
    message: str = Field(
        ...,
        description=(
            "The AI Astrologer's response in plain prose. "
            "2–5 paragraphs. No markdown headers. "
            "Emotionally attuned, specific to the user's natal chart and context."
        ),
    )
    highlighted_placements: list[HighlightedPlacement] = Field(
        default_factory=list,
        min_length=0,
        max_length=3,
        description="The 1–3 natal placements most relevant to this response.",
    )
    active_transit_references: list[TransitReference] = Field(
        default_factory=list,
        min_length=0,
        max_length=2,
        description="The 1–2 transits most central to the response.",
    )
    memory_references_used: list[str] = Field(
        default_factory=list,
        description="IDs of AIMemory entries referenced in the response.",
    )
    follow_up_questions: list[str] = Field(
        default_factory=list,
        min_length=0,
        max_length=2,
        description=(
            "Optional follow-up questions to surface to the user. "
            "Only include if genuinely useful — do not pad."
        ),
    )
    safety_flag: Optional[Literal["crisis", "medical", "legal", "financial", "harmful_belief"]] = Field(
        default=None,
        description=(
            "Set if the response triggered a safety guardrail. "
            "The frontend uses this to conditionally show resource links."
        ),
    )


# ──────────────────────────────────────────────────────────────────────────────
# 5.2  Daily Horoscope Response
# Model: Gemini 2.0 Flash | Prompt: horoscope_v1
# Generated once per sign per focus area per day (batch job).
# ──────────────────────────────────────────────────────────────────────────────

class DailyHoroscopeResponse(BaseModel):
    sign: str = Field(..., description="Zodiac sign this horoscope is for.")
    focus_area: Literal["love", "career", "wealth", "wellness", "guidance", "motivation"]
    date: date
    headline: str = Field(
        ...,
        max_length=80,
        description="A single punchy headline sentence. No more than 80 characters.",
    )
    body: str = Field(
        ...,
        description="2–3 sentences of horoscope content. Specific to sign and focus area.",
    )
    key_planet: str = Field(
        ...,
        description="The primary planet driving the energy today for this sign.",
    )
    energy_rating: int = Field(
        ...,
        ge=1,
        le=5,
        description="1–5 energy/intensity rating for this focus area today.",
    )
    lucky_word: str = Field(
        ...,
        max_length=20,
        description="A single word that captures today's theme for this sign.",
    )


# ──────────────────────────────────────────────────────────────────────────────
# 5.3  Natal Chart Interpretation Response
# Model: Claude Sonnet | Prompt: natal_chart_v1
# Generated once per user on signup; stored and served from DB.
# ──────────────────────────────────────────────────────────────────────────────

class PlanetInterpretation(BaseModel):
    planet: str
    sign: str
    house: int
    interpretation: str = Field(
        ...,
        description=(
            "2–4 sentences interpreting this planet in this sign and house. "
            "Personal, specific, NOT generic sun-sign content."
        ),
    )


class HouseTheme(BaseModel):
    house_number: int
    sign_on_cusp: str
    ruling_planet: str
    life_area: str              # e.g. "Relationships, open enemies, partnerships"
    theme_summary: str          # 1–2 sentences on what this house placement means


class NatalChartInterpretationResponse(BaseModel):
    summary: str = Field(
        ...,
        description=(
            "3–5 sentence overview of the chart as a whole. "
            "What are the dominant themes, tensions, gifts? "
            "Mention the Sun, Moon, and Ascendant sign combination explicitly."
        ),
    )
    sun_moon_ascendant_synthesis: str = Field(
        ...,
        description=(
            "2–3 sentences on how the Sun sign, Moon sign, and Ascendant "
            "interact and shape this person's overall expression and inner life."
        ),
    )
    planet_interpretations: list[PlanetInterpretation] = Field(
        ...,
        min_length=10,
        max_length=10,
        description="Interpretation for each of the 10 major planets.",
    )
    dominant_elements: dict[Literal["fire", "earth", "air", "water"], int] = Field(
        ...,
        description="Count of planets in each element.",
    )
    dominant_modalities: dict[Literal["cardinal", "fixed", "mutable"], int] = Field(
        ...,
        description="Count of planets in each modality.",
    )
    strongest_house: int = Field(
        ...,
        description="The house with the most planets (stellium or heaviest concentration).",
    )
    key_aspects: list[str] = Field(
        ...,
        max_length=5,
        description=(
            "Up to 5 most significant natal aspects, each as a 1-sentence interpretation. "
            "e.g. 'Mars square Saturn: tension between assertive action and self-restraint "
            "is a lifelong creative friction.'"
        ),
    )
    life_themes: list[str] = Field(
        ...,
        min_length=3,
        max_length=5,
        description=(
            "3–5 overarching life themes this chart points to. "
            "Stated as short phrases, e.g. 'building lasting structures', "
            "'navigating between independence and intimacy'."
        ),
    )


# ──────────────────────────────────────────────────────────────────────────────
# 5.4  Tarot + Astrology Fusion Reading
# Model: Gemini 2.0 Flash | Prompt: tarot_fusion_v1
# On-demand, user-triggered (user draws a card).
# ──────────────────────────────────────────────────────────────────────────────

class TarotCardContext(BaseModel):
    card_name: str             # e.g. "The Tower"
    position: str              # e.g. "present" for three-card; "card 1" for Celtic Cross
    reversed: bool
    traditional_meaning: str   # 1 sentence: what this card standardly means


class TarotFusionResponse(BaseModel):
    spread_type: Literal["daily", "three_card", "oracle"]
    question: Optional[str] = None
    cards: list[TarotCardContext]
    astro_synthesis: str = Field(
        ...,
        description=(
            "3–5 sentences fusing the card(s) drawn with the user's natal chart "
            "and current transits. This is the differentiating content — "
            "not a generic card reading, but one grounded in the user's sky."
        ),
    )
    core_message: str = Field(
        ...,
        max_length=150,
        description="A single punchy sentence that distills the reading's core message.",
    )
    action_suggestion: str = Field(
        ...,
        description=(
            "1–2 sentences: a concrete, actionable suggestion arising from the reading. "
            "Specific, not vague ('journal tonight' is fine; 'reflect on your journey' is not)."
        ),
    )
    planetary_resonance: str = Field(
        ...,
        description=(
            "Which natal planet or current transit most amplifies or challenges the card's "
            "message? 1 sentence."
        ),
    )


# ──────────────────────────────────────────────────────────────────────────────
# 5.5  Compatibility Report
# Model: Gemini 2.0 Flash | Prompt: compatibility_v1
# Two variants: (a) sign-pair only, (b) two full natal charts (premium synastry).
# ──────────────────────────────────────────────────────────────────────────────

class CompatibilityDimension(BaseModel):
    dimension: Literal["romantic", "friendship", "work", "communication", "long_term"]
    score: int = Field(..., ge=1, le=10)
    summary: str = Field(
        ...,
        description="2–3 sentences on compatibility in this dimension.",
    )
    strength: str = Field(
        ...,
        max_length=100,
        description="The single biggest strength in this dimension.",
    )
    watch_out: str = Field(
        ...,
        max_length=100,
        description="The single biggest friction point or growth area in this dimension.",
    )


class CompatibilityReportResponse(BaseModel):
    entity_a: str              # Sign name or user name
    entity_b: str
    overall_score: int = Field(..., ge=1, le=10)
    overall_summary: str = Field(
        ...,
        description=(
            "2–4 sentences on the overall compatibility. "
            "If two natal charts are provided, reference specific cross-chart aspects. "
            "If sign-pair only, base on sun sign dynamics."
        ),
    )
    dimensions: list[CompatibilityDimension] = Field(
        ...,
        min_length=5,
        max_length=5,
        description="Exactly 5 compatibility dimensions.",
    )
    key_synastry_aspects: Optional[list[str]] = Field(
        default=None,
        max_length=3,
        description=(
            "If two natal charts are provided: up to 3 significant cross-chart aspects "
            "as 1-sentence interpretations. Null if sign-pair-only mode."
        ),
    )
    compatibility_mode: Literal["sign_pair", "natal_synastry"]


# ──────────────────────────────────────────────────────────────────────────────
# 5.6  Weekly Mood Correlation Insight
# Model: Gemini 2.0 Flash | Prompt: mood_insight_v1
# Batch-generated weekly per active user who has mood logs.
# ──────────────────────────────────────────────────────────────────────────────

class MoodTransitCorrelation(BaseModel):
    pattern_description: str = Field(
        ...,
        description=(
            "1–2 sentences describing a correlation between a mood pattern and a transit. "
            "e.g. 'On the 3 days you rated energy 1–2, Mars was squaring your natal Moon.'"
        ),
    )
    transit_involved: str      # e.g. "Mars square natal Moon"
    mood_pattern: str          # e.g. "Low energy (score 1–2)"
    confidence: Literal["strong", "moderate", "suggestive"] = Field(
        ...,
        description=(
            "How strongly the data supports this correlation. "
            "'Strong' = 3+ occurrences with consistent pattern. "
            "'Moderate' = 2 occurrences. 'Suggestive' = single data point but notable."
        ),
    )


class WeeklyMoodInsightResponse(BaseModel):
    week_start: date
    week_end: date
    mood_summary: str = Field(
        ...,
        description=(
            "2–3 sentences summarizing the user's emotional week based on their logs. "
            "Reference specific highs/lows by day if available."
        ),
    )
    correlations: list[MoodTransitCorrelation] = Field(
        ...,
        min_length=0,
        max_length=3,
        description="Up to 3 mood-transit correlations found this week.",
    )
    coming_week_preview: str = Field(
        ...,
        description=(
            "2–3 sentences previewing the emotional/energetic terrain for the coming week "
            "based on upcoming transits to the user's natal chart."
        ),
    )
    self_care_suggestion: str = Field(
        ...,
        description=(
            "1 concrete self-care suggestion grounded in the coming transits. "
            "Specific to their chart, not generic advice."
        ),
    )
    notable_transit_this_week: Optional[str] = Field(
        default=None,
        description=(
            "If there is one standout transit happening this week that the user "
            "should know about, describe it in 1 sentence. Null if nothing notable."
        ),
    )


# ──────────────────────────────────────────────────────────────────────────────
# 5.7  Memory Extraction Response (Internal)
# Model: Gemini 2.0 Flash | Used by memory_extractor.py
# Lightweight extraction pass after each AI Astrologer turn.
# ──────────────────────────────────────────────────────────────────────────────

class MemoryExtractionResponse(BaseModel):
    contains_memory: bool = Field(
        ...,
        description=(
            "True if the user's message contains a personal event, feeling, "
            "decision, or outcome worth remembering. False otherwise."
        ),
    )
    entry_type: Optional[Literal["event", "feeling", "decision", "outcome"]] = Field(
        default=None,
        description="The type of memory, if contains_memory is True.",
    )
    extracted_content: Optional[str] = Field(
        default=None,
        description=(
            "The memory content to store, in the user's own voice, "
            "distilled to 1–3 sentences. Null if contains_memory is False."
        ),
    )
    reported_date: Optional[date] = Field(
        default=None,
        description=(
            "The date the event/feeling occurred, as reported by the user. "
            "Null if no date was mentioned (store as today's date in that case)."
        ),
    )
```

---

## 6. Model Routing Table

| Prompt Key | Model | Reasoning |
|---|---|---|
| `assistant` (AI Astrologer Q&A) | Claude Sonnet | Requires multi-step reasoning over full natal chart + transits + memory. Quality gap vs. Flash is measurable and product-critical. This is the paywall anchor feature — quality is non-negotiable. |
| `natal_chart` (full interpretation) | Claude Sonnet | One-time generation per user. Complexity of synthesizing 10 planets + houses + aspects into a coherent narrative requires Claude's depth. Cost is amortized — generated once, stored forever. |
| `horoscope` (daily batch) | Gemini 2.0 Flash | 72 calls/night (12 signs × 6 focus areas). Quality bar is "good daily horoscope content", not deep synthesis. Flash is excellent at this. Cost at scale: Sonnet would be 15–20x more expensive for identical perceived quality on this task. |
| `compatibility` (sign pair) | Gemini 2.0 Flash | 144 sign-pair combinations, generated once and cached. Moderate reasoning complexity. Flash handles this well. |
| `compatibility` (natal synastry) | Claude Sonnet | Cross-chart aspect analysis requires understanding both charts simultaneously and synthesizing cross-planet patterns. Flash produces generic output here; Sonnet provides the depth premium users pay for. |
| `tarot_fusion` | Gemini 2.0 Flash | Card + transit synthesis is a creative blending task. Flash handles creative content well, and cost matters here: tarot draws are a high-frequency user interaction. |
| `mood_insight` (weekly batch) | Gemini 2.0 Flash | Weekly batch per user, not real-time. Pattern identification from structured mood + transit data is within Flash's capability. |
| `memory_extraction` (internal) | Gemini 2.0 Flash | Lightweight binary classification + extraction task. No reasoning depth required. Sonnet here would be like using a surgeon to change a lightbulb. |

### Routing Implementation

```python
# backend/services/ai_router.py

import anthropic
import google.generativeai as genai
from backend.prompts.base import PromptDefinition, ModelTarget
from backend.prompts.schemas import BaseModel as PydanticBase
import json


async def call_ai(
    definition: PromptDefinition,
    rendered_prompt: str,
    conversation_history: list[dict] | None = None,
) -> PydanticBase:
    """
    Routes a prompt to the correct AI provider based on PromptDefinition.model_target.
    Always uses structured JSON output mode.
    Returns a validated Pydantic model instance.
    """
    if definition.model_target == ModelTarget.CLAUDE_SONNET:
        return await _call_claude(definition, rendered_prompt, conversation_history)
    elif definition.model_target == ModelTarget.GEMINI_FLASH:
        return await _call_gemini(definition, rendered_prompt)
    else:
        raise ValueError(f"Unknown model target: {definition.model_target}")


async def _call_claude(
    definition: PromptDefinition,
    rendered_prompt: str,
    conversation_history: list[dict] | None,
) -> PydanticBase:
    client = anthropic.AsyncAnthropic()

    # Build messages array: history + current turn
    messages = list(conversation_history or [])
    messages.append({"role": "user", "content": rendered_prompt})

    response = await client.messages.create(
        model=definition.model_target.value,
        max_tokens=definition.max_output_tokens,
        temperature=definition.temperature,
        system=definition.system_prompt,
        messages=messages,
        # Force structured JSON output via tool use
        tools=[{
            "name": "structured_response",
            "description": "Return the response in the required structured format.",
            "input_schema": definition.response_schema.model_json_schema(),
        }],
        tool_choice={"type": "tool", "name": "structured_response"},
    )

    # Extract tool use block
    tool_block = next(
        b for b in response.content if b.type == "tool_use"
    )
    return definition.response_schema.model_validate(tool_block.input)


async def _call_gemini(
    definition: PromptDefinition,
    rendered_prompt: str,
) -> PydanticBase:
    model = genai.GenerativeModel(
        model_name=definition.model_target.value,
        generation_config=genai.GenerationConfig(
            response_mime_type="application/json",
            response_schema=definition.response_schema.model_json_schema(),
            max_output_tokens=definition.max_output_tokens,
            temperature=definition.temperature,
        ),
        system_instruction=definition.system_prompt,
    )

    # For Gemini, system prompt is passed in model init above
    response = await model.generate_content_async(rendered_prompt)
    data = json.loads(response.text)
    return definition.response_schema.model_validate(data)
```

---

## 7. Prompt Versioning and A/B Testing

### Versioning Convention

- Each prompt file is named `{key}_v{N}.py`. Version numbers are monotonically increasing integers.
- The active version for each key is declared in `registry.py`. Changing which version is active is a one-line change + deploy.
- Old versions are never deleted. They are kept in the directory for rollback and analysis.
- `git blame` on `registry.py` is the full version history.

### Creating a New Prompt Version

1. Copy `assistant_v1.py` to `assistant_v2.py`.
2. Make changes to the system prompt or user template in `assistant_v2.py`.
3. In `registry.py`, register the new variant under a separate key for the experiment:

```python
# registry.py — during an A/B test
PROMPT_REGISTRY: dict[str, PromptDefinition] = {
    "assistant":       assistant_v1.DEFINITION,      # Control (100% traffic by default)
    "assistant_v2":    assistant_v2.DEFINITION,      # Challenger (used when experiment routes here)
    ...
}
```

4. The `PromptRouter` (below) handles traffic splitting.

### A/B Testing Infrastructure

```python
# backend/services/prompt_router.py

import random
from dataclasses import dataclass
from typing import Optional
from backend.prompts.registry import prompt_registry, PromptDefinition


@dataclass
class Experiment:
    experiment_id: str
    control_key: str                # Key in PROMPT_REGISTRY
    challenger_key: str             # Key in PROMPT_REGISTRY
    challenger_traffic_pct: float   # 0.0–1.0; e.g. 0.2 = 20% to challenger
    min_users_for_conclusion: int = 500
    active: bool = True


# Experiments are defined in code and version-controlled.
# Turn off an experiment by setting active=False — no deploy needed if using a feature flag.
ACTIVE_EXPERIMENTS: list[Experiment] = [
    # Example: testing a warmer tone in the system prompt
    # Experiment(
    #     experiment_id="assistant_warmth_v2",
    #     control_key="assistant",
    #     challenger_key="assistant_v2",
    #     challenger_traffic_pct=0.2,
    # ),
]


class PromptRouter:
    def resolve(
        self,
        task_key: str,
        user_id: str,
        experiment_override: Optional[str] = None,
    ) -> tuple[PromptDefinition, Optional[str]]:
        """
        Resolves which PromptDefinition to use for a given task and user.
        Returns (definition, experiment_id_if_in_experiment).

        Deterministic bucketing: hash(user_id + experiment_id) % 100 ensures
        the same user always gets the same variant within an experiment.
        """
        if experiment_override:
            return prompt_registry.get(experiment_override), experiment_override

        for experiment in ACTIVE_EXPERIMENTS:
            if experiment.control_key != task_key:
                continue
            if not experiment.active:
                continue

            # Deterministic bucket: same user always in same bucket
            bucket = int(hash(f"{user_id}:{experiment.experiment_id}") % 100)
            if bucket < int(experiment.challenger_traffic_pct * 100):
                return (
                    prompt_registry.get(experiment.challenger_key),
                    experiment.experiment_id,
                )

        return prompt_registry.get(task_key), None


prompt_router = PromptRouter()
```

### Logging for Quality Measurement

Every AI call logs the following to the `ai_call_log` table in PostgreSQL:

```python
# backend/database/models_ai_log.py  (add to existing models)

class AICallLog(Base):
    __tablename__ = "ai_call_log"

    id             = Column(UUID, primary_key=True, default=uuid4)
    user_id        = Column(UUID, ForeignKey("users.id"), nullable=True)  # Null for batch jobs
    prompt_key     = Column(String, nullable=False)    # e.g. "assistant"
    prompt_version = Column(Integer, nullable=False)   # e.g. 1
    experiment_id  = Column(String, nullable=True)     # Null if not in an experiment
    model_used     = Column(String, nullable=False)    # Actual model string
    input_tokens   = Column(Integer)
    output_tokens  = Column(Integer)
    latency_ms     = Column(Integer)
    response_valid = Column(Boolean)                   # Did Pydantic validation pass?
    safety_flag    = Column(String, nullable=True)     # From AstrologerMessageResponse
    created_at     = Column(DateTime, default=datetime.utcnow)
```

### Quality Metrics

For AI Astrologer responses, collect the following signals:

| Signal | How Collected | What It Measures |
|---|---|---|
| Thumbs up / thumbs down | Explicit in-app UI after each response | Direct user satisfaction |
| Follow-up question rate | Did the user ask another question? | Engagement / conversation continuation |
| Session length | How many turns per session | Depth of engagement |
| Specificity score | Automated: does the response contain planet names, degree references, house numbers? | Whether the prompt is forcing specific, non-generic output |
| Safety flag rate | From `AstrologerMessageResponse.safety_flag` | Guardrail hit frequency |
| Response latency p50/p95 | Logged in `ai_call_log` | User experience |

### Running an Experiment Analysis

```python
# backend/scripts/analyze_experiment.py
# Run manually or on a schedule once min_users_for_conclusion is reached.

import pandas as pd
from sqlalchemy import text


def analyze_experiment(experiment_id: str, db) -> dict:
    """
    Compare control vs. challenger on key quality metrics.
    Returns a dict of metric → {control, challenger, delta, significant}.
    """
    logs = pd.read_sql(
        text("""
            SELECT
                l.experiment_id,
                l.prompt_version,
                f.rating,                       -- thumbs up = 1, thumbs down = -1
                l.latency_ms,
                l.input_tokens + l.output_tokens AS total_tokens
            FROM ai_call_log l
            LEFT JOIN ai_response_feedback f ON f.call_log_id = l.id
            WHERE l.experiment_id = :eid
        """),
        db,
        params={"eid": experiment_id},
    )

    control = logs[logs["prompt_version"] == 1]
    challenger = logs[logs["prompt_version"] == 2]

    return {
        "n_control": len(control),
        "n_challenger": len(challenger),
        "satisfaction_control": control["rating"].mean(),
        "satisfaction_challenger": challenger["rating"].mean(),
        "latency_p50_control": control["latency_ms"].median(),
        "latency_p50_challenger": challenger["latency_ms"].median(),
        "token_cost_control": control["total_tokens"].mean(),
        "token_cost_challenger": challenger["total_tokens"].mean(),
    }
```

### Promotion and Rollback

- **Promotion:** Update `registry.py` to point `"assistant"` to `assistant_v2.DEFINITION`. Remove the experiment from `ACTIVE_EXPERIMENTS`. Deploy.
- **Rollback:** Revert the `registry.py` change. Deploy. Old version is always in the file — no data migration needed.
- **Emergency rollback:** Set `experiment.active = False` in `ACTIVE_EXPERIMENTS` (if using a feature flag system, no deploy needed).

---

## Appendix A: Prompt File Template

Use this as the starting point for every new prompt version:

```python
# backend/prompts/{key}_v{N}.py
# Description: [What this prompt does, in one sentence]
# Model: [Model name]
# Created: [Date]
# Changelog: [What changed from previous version]

from backend.prompts.base import PromptDefinition, ModelTarget, PromptType
from backend.prompts.schemas import YourResponseSchema

SYSTEM_PROMPT = """
[System prompt text here. For Gemini Flash prompts that do not use a separate
system turn, embed the persona and instructions at the top of the user prompt
template instead, and set this to None.]
"""

USER_PROMPT_TEMPLATE = """
[Jinja2 template for the user-turn prompt.
Reference context variables with {{ variable_name }}.
Loop with {% for item in list %} ... {% endfor %}.
]
"""

DEFINITION = PromptDefinition(
    key="{key}",
    version={N},
    prompt_type=PromptType.BATCH,           # or ON_DEMAND
    model_target=ModelTarget.GEMINI_FLASH,  # or CLAUDE_SONNET
    response_schema=YourResponseSchema,
    system_prompt=SYSTEM_PROMPT,
    user_prompt_template=USER_PROMPT_TEMPLATE,
    max_output_tokens=512,
    temperature=0.7,
    cache_ttl_seconds=86400,               # None for on-demand personalized calls
    description="[One-line description for the registry UI]",
)
```

---

## Appendix B: Environment Variables for AI Layer

```env
# AI API Keys
ANTHROPIC_API_KEY=
GEMINI_API_KEY=
OPENAI_API_KEY=              # Used only for text-embedding-3-small (memory retrieval)

# Memory Retrieval Tuning
MEMORY_SEMANTIC_WEIGHT=0.7
MEMORY_RECENCY_HALF_LIFE_DAYS=90
MEMORY_TOP_K=5
MEMORY_MAX_TOKENS=800

# Token Budgets (override defaults if needed)
ASSISTANT_MAX_INPUT_TOKENS=3550
ASSISTANT_CONVERSATION_HISTORY_TURNS=5
ASSISTANT_MAX_TRANSITS=8
ASSISTANT_MAX_MEMORIES=5

# Rate Limiting (enforced at the API gateway layer via Redis)
FREE_TIER_ASTROLOGER_MESSAGES_PER_DAY=3
PREMIUM_TIER_ASTROLOGER_MESSAGES_PER_DAY=unlimited
```
