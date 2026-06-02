# AstroAI Frontend Specification Source of Truth

> Status: Canonical frontend specification for redevelopment.
> Last updated: 2026-06-02

## Frontend Target

The web MVP uses Next.js 14 App Router, TypeScript, Tailwind CSS, and Supabase Auth.

The existing Flutter app remains temporarily. React Native/Expo is future work and is not part of MVP.

## Product Experience

The first screen after authentication should move the user into the product, not a marketing landing page. The core web app should prioritize:

- Fast onboarding.
- Beautiful chart reveal.
- Clear AI Astrologer entry point.
- Scannable daily guidance.
- Public SEO pages for acquisition.

## Routes

### Public Routes

| Route | Purpose |
|---|---|
| `/` | Public home or direct app entry depending auth state |
| `/horoscope/[sign]` | Daily horoscope page |
| `/zodiac/[sign]` | Sign profile page |
| `/compatibility/[signA]/[signB]` | Sign-pair compatibility page |
| `/login` | Sign in |
| `/signup` | Sign up |

### Protected Routes

| Route | Purpose |
|---|---|
| `/onboarding` | Birth data onboarding |
| `/dashboard` | Personalized home |
| `/chart` | Natal chart summary |
| `/chat` | AI Astrologer |
| `/mood` | Mood logging |
| `/tarot` | Tarot hub |
| `/settings` | Profile, subscription, privacy |

## Environment

Frontend environment variables:

```env
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api/v1
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

Do not include server secrets in frontend environment variables. In particular, do not expose Gemini keys, Supabase service role keys, Stripe secret keys, Google Places server keys, or FCM server keys.

## API Client Contract

The frontend API client must call the canonical backend routes from `API_SPEC.md`.

Minimum API client methods:

```ts
type Sign =
  | "aries"
  | "taurus"
  | "gemini"
  | "cancer"
  | "leo"
  | "virgo"
  | "libra"
  | "scorpio"
  | "sagittarius"
  | "capricorn"
  | "aquarius"
  | "pisces";

type UserTier = "free" | "premium";

export async function getCurrentUser() {
  return api.get("/users/me");
}

export async function getNatalChart() {
  return api.get("/users/me/natal-chart");
}

export async function saveNatalChart(payload: BirthDataInput) {
  return api.post("/users/me/natal-chart", payload);
}

export async function getDailyHoroscope(sign: Sign, params?: { date?: string; focus?: string }) {
  return api.get(`/horoscope/daily/${sign}`, { params });
}

export async function sendChatMessage(payload: { message: string; conversation_id?: string | null }) {
  return api.post("/chat", payload);
}

export async function getCompatibility(signA: Sign, signB: Sign) {
  return api.get(`/compatibility/${signA}/${signB}`);
}
```

Do not use legacy routes such as `/natal-chart/calculate`, `/natal-chart/me`, `/natal-chart/save`, or `/compatibility?signA=...`.

## Onboarding Flow

Required steps:

1. Birth date.
2. Birth time, with "I do not know my birth time" option.
3. Birthplace.
4. Consent and privacy note.
5. Chart calculation.
6. Chart reveal.

Birthplace lookup should call a backend endpoint or backend-controlled service. The frontend must not expose a Google Places server key.

If birth time is unknown:

- Explain that Ascendant and houses may be unavailable.
- Still allow onboarding completion.
- Show Sun sign and other reliable placements.

## Dashboard

Dashboard should include:

- Today's personalized or sign-based guidance.
- Natal chart summary.
- AI Astrologer entry point.
- Remaining AI message quota.
- Suggested prompts.
- Links to horoscope, compatibility, mood, and tarot areas.

Quota display uses backend response data:

```ts
type AiUsage = {
  tier: UserTier;
  used_today: number;
  daily_limit: number;
};
```

## AI Astrologer

The chat UI must:

- Require authentication.
- Prompt the user to complete onboarding if no natal chart exists.
- Show daily quota.
- Disable send while a message is pending.
- Preserve conversation history.
- Handle rate-limit errors clearly.
- Avoid implying the AI remembers unavailable context.

The backend owns prompt construction. The frontend sends only the user message and optional conversation id.

## Public SEO Pages

Public pages must be server-rendered or statically generated where possible.

Required SEO pages:

- 12 daily horoscope pages.
- 12 sign profile pages.
- 144 sign-pair compatibility pages.

Each public page should include:

- Stable canonical URL.
- Metadata title and description.
- JSON-LD where appropriate.
- Internal links to related signs and compatibility pages.
- Clear login/signup path into the personalized product.

Public page views must not trigger live Gemini calls.

## Design Direction

AstroAI should feel mystical but usable. Avoid making the app a decorative landing page when the user needs a tool.

UI principles:

- Rich, calm, high-contrast surfaces.
- Compact cards for repeated content only.
- Clear buttons and form states.
- Icons for common actions.
- No in-app instructional walls.
- No text overlap on mobile.
- No single-hue purple-only palette.
- Accessible contrast and keyboard states.

## Frontend Build Order

1. Project scaffold.
2. Design tokens and app shell.
3. Supabase auth.
4. Protected-route middleware.
5. Onboarding.
6. Natal chart reveal.
7. Dashboard.
8. AI Astrologer.
9. Public SEO pages.
10. Mood, tarot, and settings.

