# Public Horoscope Web Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the first production-facing Next.js public horoscope experience, separate from the developer preview page.

**Architecture:** Add a new `frontend/web` Next.js app that uses the existing `/api/v1` backend contracts. The first production page should load one static horoscope bundle per sign/year, then derive daily, weekly, monthly, and yearly views on the client without showing API/debug controls.

**Tech Stack:** Next.js 14 App Router, TypeScript, Tailwind CSS, Vitest or Playwright for frontend validation, existing FastAPI `/api/v1` backend.

---

## File Structure

- Create `frontend/web/package.json`: Next.js app scripts and dependencies.
- Create `frontend/web/next.config.mjs`: Next.js config.
- Create `frontend/web/tsconfig.json`: TypeScript config.
- Create `frontend/web/tailwind.config.ts`: Tailwind theme tokens using AstroAI colors.
- Create `frontend/web/src/app/layout.tsx`: global app shell metadata.
- Create `frontend/web/src/app/globals.css`: base styles and Tailwind layers.
- Create `frontend/web/src/app/horoscope/page.tsx`: public sign/date entry page.
- Create `frontend/web/src/components/horoscope/HoroscopeExperience.tsx`: stateful public horoscope client component.
- Create `frontend/web/src/components/horoscope/FocusTabs.tsx`: dimension/focus selector.
- Create `frontend/web/src/components/horoscope/ReadingPanel.tsx`: reusable daily/weekly/month/year card.
- Create `frontend/web/src/lib/api.ts`: typed backend API helpers.
- Create `frontend/web/src/lib/horoscope.ts`: date, sign, and bundle selection helpers.
- Create `frontend/web/src/lib/types.ts`: frontend API response types.
- Create `frontend/web/src/__tests__/horoscope.test.ts`: pure helper tests.
- Create `frontend/web/src/__tests__/api-contract.test.ts`: route string and API helper tests.
- Keep `frontend/preview/*`: developer/API tester only.

## Task 1: Scaffold Next.js Web App

**Files:**
- Create: `frontend/web/package.json`
- Create: `frontend/web/next.config.mjs`
- Create: `frontend/web/tsconfig.json`
- Create: `frontend/web/tailwind.config.ts`
- Create: `frontend/web/src/app/layout.tsx`
- Create: `frontend/web/src/app/globals.css`

- [ ] **Step 1: Create scaffold files**

`frontend/web/package.json`:

```json
{
  "name": "astroai-web",
  "private": true,
  "version": "0.1.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "vitest run"
  },
  "dependencies": {
    "next": "14.2.3",
    "react": "18.3.1",
    "react-dom": "18.3.1"
  },
  "devDependencies": {
    "@testing-library/react": "15.0.7",
    "@types/node": "20.12.12",
    "@types/react": "18.3.3",
    "@types/react-dom": "18.3.0",
    "autoprefixer": "10.4.19",
    "postcss": "8.4.38",
    "tailwindcss": "3.4.3",
    "typescript": "5.4.5",
    "vitest": "1.6.0"
  }
}
```

- [ ] **Step 2: Add app shell**

`frontend/web/src/app/layout.tsx`:

```tsx
import "./globals.css";

export const metadata = {
  title: "AstroAI Horoscope",
  description: "Free yearly, monthly, weekly, and daily horoscope guidance."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

- [ ] **Step 3: Run verification**

Run:

```bash
cd frontend/web
npm install
npm run build
```

Expected: install succeeds and Next.js build completes.

- [ ] **Step 4: Commit**

```bash
git add frontend/web
git commit -m "feat: scaffold public web app"
```

## Task 2: Add Horoscope Types and Helpers

**Files:**
- Create: `frontend/web/src/lib/types.ts`
- Create: `frontend/web/src/lib/horoscope.ts`
- Create: `frontend/web/src/__tests__/horoscope.test.ts`

- [ ] **Step 1: Write helper tests**

`frontend/web/src/__tests__/horoscope.test.ts`:

```ts
import { findDailyEntry, findWeeklyEntry, titleCaseSign } from "../lib/horoscope";

const entries = [
  { sign: "Gemini", period: "daily", date: "2026-06-03", focus: "general", title: "Today", summary: "Daily", body: "Daily body", generated_at: "2026-01-01T00:00:00Z" },
  { sign: "Gemini", period: "weekly", date: "2026-06-01", focus: "general", title: "Week", summary: "Weekly", body: "Weekly body", generated_at: "2026-01-01T00:00:00Z" }
];

test("titleCaseSign formats sign slugs", () => {
  expect(titleCaseSign("gemini")).toBe("Gemini");
});

test("findDailyEntry returns the selected date and focus", () => {
  expect(findDailyEntry(entries, "2026-06-03", "general")?.title).toBe("Today");
});

test("findWeeklyEntry returns the week containing the selected date", () => {
  expect(findWeeklyEntry(entries, "2026-06-03", "general")?.title).toBe("Week");
});
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd frontend/web
npm test -- src/__tests__/horoscope.test.ts
```

Expected: FAIL because `../lib/horoscope` does not exist.

- [ ] **Step 3: Implement helpers**

`frontend/web/src/lib/horoscope.ts`:

```ts
import type { HoroscopeEntry } from "./types";

export function titleCaseSign(sign: string) {
  return sign.charAt(0).toUpperCase() + sign.slice(1);
}

export function findDailyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  return entries.find((entry) => entry.period === "daily" && entry.date === date && entry.focus === focus);
}

export function findWeeklyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  const selectedDate = new Date(`${date}T00:00:00`);
  return entries.find((entry) => {
    if (entry.period !== "weekly" || entry.focus !== focus) return false;
    const weekStart = new Date(`${entry.date}T00:00:00`);
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 6);
    return selectedDate >= weekStart && selectedDate <= weekEnd;
  });
}
```

`frontend/web/src/lib/types.ts`:

```ts
export type HoroscopeFocus =
  | "general"
  | "love"
  | "career"
  | "money"
  | "wellness"
  | "social"
  | "family"
  | "study"
  | "mood_energy";

export type HoroscopeEntry = {
  sign: string;
  period: "daily" | "weekly" | "monthly" | "yearly";
  date: string;
  focus: HoroscopeFocus | string;
  title: string;
  summary: string;
  body: string;
  lucky_numbers?: number[] | null;
  lucky_color?: string | null;
  generated_at: string;
};

export type HoroscopeBundle = {
  sign: string;
  year: number;
  yearly: HoroscopeEntry[];
  monthly: HoroscopeEntry[];
  weekly: HoroscopeEntry[];
  daily: HoroscopeEntry[];
  source: "static";
  generated_at?: string | null;
};
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
cd frontend/web
npm test -- src/__tests__/horoscope.test.ts
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add frontend/web/src/lib frontend/web/src/__tests__/horoscope.test.ts
git commit -m "feat: add horoscope view helpers"
```

## Task 3: Add Typed API Client

**Files:**
- Create: `frontend/web/src/lib/api.ts`
- Create: `frontend/web/src/__tests__/api-contract.test.ts`

- [ ] **Step 1: Write API route tests**

`frontend/web/src/__tests__/api-contract.test.ts`:

```ts
import { buildHoroscopeBundleUrl, buildSunSignUrl } from "../lib/api";

test("buildHoroscopeBundleUrl uses canonical API v1 route", () => {
  expect(buildHoroscopeBundleUrl("http://localhost:8000/api/v1", "gemini", 2026)).toBe(
    "http://localhost:8000/api/v1/horoscope/bundle/gemini?year=2026"
  );
});

test("buildSunSignUrl uses canonical API v1 utility route", () => {
  expect(buildSunSignUrl("http://localhost:8000/api/v1", "1994-06-14")).toBe(
    "http://localhost:8000/api/v1/utils/sun-sign?birth_date=1994-06-14"
  );
});
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd frontend/web
npm test -- src/__tests__/api-contract.test.ts
```

Expected: FAIL because `../lib/api` does not exist.

- [ ] **Step 3: Implement API helpers**

`frontend/web/src/lib/api.ts`:

```ts
import type { HoroscopeBundle } from "./types";

const defaultApiBase = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1";

export function normalizeApiBase(apiBase = defaultApiBase) {
  return apiBase.replace(/\/$/, "");
}

export function buildHoroscopeBundleUrl(apiBase: string, sign: string, year: number) {
  return `${normalizeApiBase(apiBase)}/horoscope/bundle/${sign}?year=${year}`;
}

export function buildSunSignUrl(apiBase: string, birthDate: string) {
  return `${normalizeApiBase(apiBase)}/utils/sun-sign?birth_date=${encodeURIComponent(birthDate)}`;
}

export async function getHoroscopeBundle(sign: string, year: number, apiBase = defaultApiBase): Promise<HoroscopeBundle> {
  const response = await fetch(buildHoroscopeBundleUrl(apiBase, sign, year));
  if (!response.ok) throw new Error(`Failed to load horoscope bundle: ${response.status}`);
  return response.json();
}

export async function getSunSignFromBirthDate(birthDate: string, apiBase = defaultApiBase): Promise<string> {
  const response = await fetch(buildSunSignUrl(apiBase, birthDate));
  if (!response.ok) throw new Error(`Failed to calculate Sun sign: ${response.status}`);
  const payload = await response.json();
  return String(payload.sun_sign).toLowerCase();
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
cd frontend/web
npm test -- src/__tests__/api-contract.test.ts
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add frontend/web/src/lib/api.ts frontend/web/src/__tests__/api-contract.test.ts
git commit -m "feat: add public horoscope api client"
```

## Task 4: Build Production Public Horoscope Page

**Files:**
- Create: `frontend/web/src/app/horoscope/page.tsx`
- Create: `frontend/web/src/components/horoscope/HoroscopeExperience.tsx`
- Create: `frontend/web/src/components/horoscope/FocusTabs.tsx`
- Create: `frontend/web/src/components/horoscope/ReadingPanel.tsx`

- [ ] **Step 1: Implement page route**

`frontend/web/src/app/horoscope/page.tsx`:

```tsx
import { HoroscopeExperience } from "../../components/horoscope/HoroscopeExperience";

export default function HoroscopePage() {
  return <HoroscopeExperience />;
}
```

- [ ] **Step 2: Implement production component boundaries**

Use these component responsibilities:

- `HoroscopeExperience`: owns selected sign, birth date, view date, selected focus, API loading, and bundle state.
- `FocusTabs`: renders the nine canonical dimensions.
- `ReadingPanel`: renders one content card for daily, weekly, monthly, or yearly reading.

Production UI must not include:

- API base URL field.
- "Load Bundle" developer button as the main action.
- Raw debug status language.
- Long weekly list.

- [ ] **Step 3: Run build**

Run:

```bash
cd frontend/web
npm run build
```

Expected: Next.js build succeeds.

- [ ] **Step 4: Commit**

```bash
git add frontend/web/src/app/horoscope frontend/web/src/components/horoscope
git commit -m "feat: add public horoscope page"
```

## Task 5: Document Execution and Keep Preview Separate

**Files:**
- Modify: `docs/FRONTEND_SPEC.md`
- Modify: `README.md`

- [ ] **Step 1: Add run instructions**

Add this to `README.md`:

````md
### Public Web App

The production-facing web app lives in `frontend/web`.

```bash
cd frontend/web
npm install
npm run dev
```

The developer API tester remains in `frontend/preview` and is not production UI.
````

- [ ] **Step 2: Verify docs do not contradict source of truth**

Run:

```bash
rg -n "frontend/preview|frontend/web|production UI|developer/API" README.md docs/FRONTEND_SPEC.md
```

Expected: `frontend/preview` is described only as a developer/API tester, and `frontend/web` is described as production-facing.

- [ ] **Step 3: Commit**

```bash
git add README.md docs/FRONTEND_SPEC.md
git commit -m "docs: document public web app entrypoint"
```

## Verification

Run after completing all tasks:

```bash
cd frontend/web
npm test
npm run build
```

Run backend tests from repo root:

```bash
python -m pytest tests/backend tests/frontend -v
```

Expected: all frontend tests pass, Next.js builds, and existing backend/preview tests still pass.

## Self-Review

- The plan keeps `frontend/preview` as a developer/API tester.
- The plan creates a separate `frontend/web` production-facing app.
- The plan reuses `/api/v1/horoscope/bundle/{sign}` and `/api/v1/utils/sun-sign`.
- The plan avoids long weekly lists in production UI.
- The plan does not add auth, natal chart, AI chat, Stripe, or SEO pages yet; those remain later phases.
