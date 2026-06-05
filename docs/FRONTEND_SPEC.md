# AstroAI Frontend Specification Source of Truth

> Status: Canonical frontend specification for redevelopment.
> Last updated: 2026-06-05

For the public web page-level UX consolidation, use `docs/superpowers/specs/2026-06-05-public-web-ux-design.md`.

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

The public first screen should work before authentication: users can choose a sign or enter a birth date, then load the selected sign's current-year horoscope bundle in one API request.

`frontend/preview/` is a developer/API validation page only. It may expose controls such as API base URL, manual bundle loading, and raw static bundle inspection. It is not the final public product UI and must not be used as the visual or interaction model for production horoscope pages.

## Routes

### Public Routes

| Route | Purpose |
|---|---|
| `/` | Public home or direct app entry depending auth state |
| `/horoscope` | Sign picker and birth-date-to-Sun-sign entry |
| `/horoscope/[sign]` | Daily horoscope page |
| `/horoscope/[sign]/weekly` | Weekly horoscope page |
| `/horoscope/[sign]/monthly` | Monthly horoscope page |
| `/horoscope/[sign]/yearly` | Yearly horoscope page |
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

export async function getHoroscopeBundle(sign: Sign, params?: { year?: number }) {
  return api.get(`/horoscope/bundle/${sign}`, { params });
}

export async function getSunSignFromBirthDate(birthDate: string) {
  return api.get("/utils/sun-sign", { params: { birth_date: birthDate } });
}

export async function getWeeklyHoroscope(sign: Sign, params?: { week?: string; focus?: string }) {
  return api.get(`/horoscope/weekly/${sign}`, { params });
}

export async function getMonthlyHoroscope(sign: Sign, params?: { month?: string; focus?: string }) {
  return api.get(`/horoscope/monthly/${sign}`, { params });
}

export async function getYearlyHoroscope(sign: Sign, params?: { year?: string; focus?: string }) {
  return api.get(`/horoscope/yearly/${sign}`, { params });
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

Public pre-onboarding flow:

1. User chooses a sign manually, or enters a birth date.
2. If the user enters a birth date, frontend calls `/utils/sun-sign`.
3. Frontend calls `/horoscope/bundle/{sign}?year=currentYear`.
4. Frontend displays yearly, monthly, weekly, and daily horoscope sections from the returned static bundle.
5. Frontend prompts the user to register only when they want to save a natal chart or receive AI personalization.

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
- 12 weekly horoscope pages.
- 12 monthly horoscope pages.
- 12 yearly horoscope pages.
- 12 sign profile pages.
- 144 sign-pair compatibility pages.

Each public page should include:

- Stable canonical URL.
- Metadata title and description.
- JSON-LD where appropriate.
- Internal links to related signs and compatibility pages.
- Clear login/signup path into the personalized product.

Public page views must not trigger live Gemini calls.

Public horoscope bundle loading should use one backend request per selected sign/year. Client-side navigation between year, month, week, and day views should reuse the loaded bundle where practical instead of repeatedly fetching individual period endpoints.

For the production public horoscope experience, weekly content should be date-driven rather than shown as a long list. The user chooses or lands on a date, the page shows that date's daily horoscope, and the frontend derives the corresponding weekly horoscope from the loaded bundle. Month and year content can remain browsable because they are compact and useful for planning.

Public horoscope pages should display these dimensions when available:

- General
- Love and relationships
- Career and work
- Wealth and money
- Health and wellness
- Social life
- Family and home
- Study and personal growth
- Mood and energy

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

### Legacy Flutter Design Decisions

The existing Flutter frontend is a legacy/demo implementation, but its visual direction is useful input for the redeveloped web experience.

Keep these design assets and patterns:

- The AstroAI brand palette: blue `#4097FF`, pink `#FF92A2`, light blue `#A5E5F9`, purple `#8985CF`, and light pink `#FFF3F8`.
- The white fixed header pattern with AstroAI branding on the left and simple navigation on the right.
- The blue-to-pink gradient brand mark direction.
- Poppins/Inter-style readable typography from the current Flutter theme.
- Optional decorative display headings for brand moments and page titles.
- Friendly rounded cards for horoscope dimensions, zodiac choices, daily insights, and chart summaries.
- Zodiac grouping by element as a useful public browsing pattern.
- The daily-insights information structure: greeting/date/sign context, guidance cards, lucky numbers, and lucky colors.
- The natal-chart wheel/visual reveal direction for later registered-user features.

Change these parts during redevelopment:

- Do not keep legacy API routes. New frontend code must use `/api/v1` contracts only.
- Do not make the public horoscope first screen a marketing-only hero. It must be usable immediately: choose sign or enter birth date, then load the static horoscope bundle.
- Use gradients as brand accents or contained header bands, not as the default surface for every page.
- Reduce feature sprawl in MVP. ASMR, celebrity matching, and other legacy demo features stay parked until core public horoscope, auth, natal chart, and AI Astrologer flows work.
- Fix corrupted zodiac symbols or emoji output before reusing those assets in production UI.
- Simplify typography where needed: decorative display type for key moments, practical sans-serif text for dense horoscope content.

Future Next.js public pages should keep the Flutter brand skin but rebuild the user flow around the new static horoscope product. The developer preview can borrow brand colors for readability, but it remains a backend/API tester.

1. AstroAI header.
2. Simple sign or birth-date entry, without API/debug controls.
3. Today's selected-sign guidance as the main content.
4. Focus tabs.
5. Date selector that changes daily guidance and the matching weekly guidance.
6. Month and year sections loaded from the same static bundle.
7. Clear path to registration only when users want saved charts or AI personalization.

Production public pages must avoid these preview-only patterns:

- Visible API base URL fields.
- Manual "Load Bundle" developer controls.
- Debug/status language that exposes implementation details.
- Long weekly lists as the default browsing pattern.
- Page titles that make the experience look like a single-sign test page.

### Production Horoscope Page Layout

The `/horoscope` and `/horoscope/[sign]` production experience should be an immediately usable reading surface, not a developer console and not a marketing-only landing page.

Required first screen:

1. Fixed or stable AstroAI header with brand mark and simple navigation.
2. Compact sign selector and birth-date input.
3. Date selector defaulting to today, constrained to the loaded bundle year when browsing static annual data.
4. Main reading area showing the selected date's daily reading for the active focus.
5. Matching weekly reading derived from the selected date and `period_end_date`.
6. Clear month and year summary sections from the same loaded bundle.
7. Register/sign-in prompt only for saved natal charts, AI personalization, and history.

Required interaction:

- Choosing a sign loads one bundle for that sign/year.
- Entering a birth date calls `/utils/sun-sign`, sets the sign, then loads the bundle.
- Changing the view date must not refetch individual daily/weekly/monthly endpoints when the bundle is already loaded.
- Focus tabs switch the active dimension across daily, weekly, monthly, and yearly readings.
- Weekly content is never displayed as the default long list.
- The page must handle loading, API unavailable, missing data, and invalid date states with user-facing copy that does not mention implementation details.

Visual acceptance:

- Use the Flutter-derived AstroAI palette as accents, not as a full-page purple-only treatment.
- Use cards for individual repeated readings only; avoid cards inside cards.
- Keep content readable on mobile without overlap or clipped button text.
- Avoid visible API base URL fields, manual load controls, debug labels, provider names, or raw JSON.
- The public page should feel like a polished horoscope product even before authentication.

## Frontend Build Order

1. Project scaffold.
2. Design tokens and app shell.
3. Public sign picker and birth-date-to-Sun-sign flow.
4. Public horoscope bundle view.
5. Public SEO pages.
6. Supabase auth.
7. Protected-route middleware.
8. Registered onboarding.
9. Natal chart reveal.
10. Dashboard.
11. AI Astrologer.
12. Mood, tarot, and settings.
