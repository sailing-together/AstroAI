import test from "node:test";
import assert from "node:assert/strict";

import {
  ACTIVE_HOROSCOPE_YEAR,
  defaultViewDateForToday,
  findDailyEntry,
  findMonthlyEntry,
  findWeeklyEntry,
  formatDisplayDate,
  formatMonthLabel,
  formatWeekRange,
  normalizeViewDateForActiveYear,
  resolveReadingSign,
  selectDailyEntry,
  selectMonthlyEntry,
  selectWeeklyEntry,
  todayReadingState,
  titleCaseSign,
  zodiacSignForDate
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

test("view dates stay inside the active static horoscope year", () => {
  assert.equal(ACTIVE_HOROSCOPE_YEAR, 2026);
  assert.equal(normalizeViewDateForActiveYear("2025-12-31"), "2026-01-01");
  assert.equal(normalizeViewDateForActiveYear("2026-06-03"), "2026-06-03");
  assert.equal(normalizeViewDateForActiveYear("2027-01-01"), "2026-12-31");
  assert.equal(normalizeViewDateForActiveYear("not-a-date"), "2026-01-01");
});

test("default view date uses today when today is inside the active year", () => {
  assert.equal(defaultViewDateForToday(new Date("2026-06-10T03:00:00Z")), "2026-06-10");
  assert.equal(defaultViewDateForToday(new Date("2025-06-10T03:00:00Z")), "2026-06-10");
  assert.equal(defaultViewDateForToday(new Date("2027-07-15T00:00:00Z")), "2026-07-15");
});

test("todayReadingState returns active-year date and matching sign", () => {
  assert.deepEqual(todayReadingState(new Date("2026-06-11T02:00:00Z")), {
    date: "2026-06-11",
    sign: "gemini"
  });
  assert.deepEqual(todayReadingState(new Date("2027-07-15T00:00:00Z")), {
    date: "2026-07-15",
    sign: "cancer"
  });
});

test("zodiacSignForDate returns the sign season for the selected date", () => {
  assert.equal(zodiacSignForDate("2026-06-10"), "gemini");
  assert.equal(zodiacSignForDate("2026-07-15"), "cancer");
  assert.equal(zodiacSignForDate("2026-12-25"), "capricorn");
  assert.equal(zodiacSignForDate("2026-03-21"), "aries");
});

test("resolveReadingSign follows date season mode or personal sign mode", () => {
  assert.equal(resolveReadingSign("date_season", "gemini", "2026-07-15"), "cancer");
  assert.equal(resolveReadingSign("personal_sign", "gemini", "2026-07-15"), "gemini");
});

test("selected readings do not fall back to stale dates", () => {
  assert.equal(selectDailyEntry(entries, "2026-06-04", "general"), undefined);
  assert.equal(selectWeeklyEntry(entries, "2026-06-09", "general"), undefined);
  assert.equal(selectMonthlyEntry(entries, "2026-07-01", "general"), undefined);
});
