import test from "node:test";
import assert from "node:assert/strict";

import {
  findDailyEntry,
  findMonthlyEntry,
  findWeeklyEntry,
  formatDisplayDate,
  formatMonthLabel,
  formatWeekRange,
  titleCaseSign
} from "../lib/horoscope.ts";
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
  },
  {
    sign: "Gemini",
    period: "monthly",
    date: "2026-06-01",
    focus: "general",
    title: "Month",
    summary: "Monthly",
    body: "Monthly body",
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

test("findMonthlyEntry returns the month containing the selected date", () => {
  assert.equal(findMonthlyEntry(entries, "2026-06-27", "general")?.title, "Month");
});

test("date labels are stable in UTC", () => {
  assert.equal(formatDisplayDate("2026-06-03"), "Jun 3, 2026");
  assert.equal(formatMonthLabel("2026-06-03"), "June 2026");
  assert.equal(formatWeekRange(entries[1]), "Jun 1, 2026 - Jun 7, 2026");
});
