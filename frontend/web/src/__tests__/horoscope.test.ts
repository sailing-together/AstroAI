import test from "node:test";
import assert from "node:assert/strict";

import { findDailyEntry, findWeeklyEntry, titleCaseSign } from "../lib/horoscope.ts";
import type { HoroscopeEntry } from "../lib/types.ts";

const entries: HoroscopeEntry[] = [
  {
    sign: "Gemini",
    period: "daily",
    date: "2026-06-03",
    focus: "general",
    title: "Today",
    summary: "Daily",
    body: "Daily body",
    generated_at: "2026-01-01T00:00:00Z"
  },
  {
    sign: "Gemini",
    period: "weekly",
    date: "2026-06-01",
    focus: "general",
    title: "Week",
    summary: "Weekly",
    body: "Weekly body",
    generated_at: "2026-01-01T00:00:00Z"
  }
];

test("titleCaseSign formats sign slugs", () => {
  assert.equal(titleCaseSign("gemini"), "Gemini");
});

test("findDailyEntry returns the selected date and focus", () => {
  assert.equal(findDailyEntry(entries, "2026-06-03", "general")?.title, "Today");
});

test("findWeeklyEntry returns the week containing the selected date", () => {
  assert.equal(findWeeklyEntry(entries, "2026-06-03", "general")?.title, "Week");
});

test("findWeeklyEntry respects explicit period_end_date", () => {
  const customWeek: HoroscopeEntry[] = [
    {
      sign: "Gemini",
      period: "weekly",
      date: "2026-01-01",
      period_end_date: "2026-01-04",
      focus: "general",
      title: "Short Week",
      summary: "Weekly",
      body: "Weekly body",
      generated_at: "2026-01-01T00:00:00Z"
    }
  ];

  assert.equal(findWeeklyEntry(customWeek, "2026-01-04", "general")?.title, "Short Week");
  assert.equal(findWeeklyEntry(customWeek, "2026-01-05", "general"), undefined);
});
