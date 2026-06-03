import type { HoroscopeEntry } from "./types.ts";

export function titleCaseSign(sign: string) {
  return sign.charAt(0).toUpperCase() + sign.slice(1);
}

export function findDailyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  return entries.find((entry) => entry.period === "daily" && entry.date === date && entry.focus === focus);
}

export function findWeeklyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  const selectedDate = parseDate(date);
  return entries.find((entry) => {
    if (entry.period !== "weekly" || entry.focus !== focus) return false;
    const weekStart = parseDate(entry.date);
    const weekEnd = addDays(weekStart, 6);
    return selectedDate >= weekStart && selectedDate <= weekEnd;
  });
}

function parseDate(value: string) {
  return new Date(`${value}T00:00:00`);
}

function addDays(value: Date, days: number) {
  const result = new Date(value);
  result.setDate(result.getDate() + days);
  return result;
}
