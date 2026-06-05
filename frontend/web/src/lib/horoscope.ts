import type { HoroscopeEntry } from "./types.ts";

export function titleCaseSign(sign: string) {
  return sign.charAt(0).toUpperCase() + sign.slice(1);
}

export function findDailyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  return entries.find((entry) => entry.period === "daily" && entry.date === date && entry.focus === focus);
}

export function findWeeklyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  return entries.find((entry) => {
    if (entry.period !== "weekly" || entry.focus !== focus) return false;
    const weekEnd = entry.period_end_date ?? addDaysIso(entry.date, 6);
    return entry.date <= date && date <= weekEnd;
  });
}

export function findMonthlyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  const selectedMonth = date.slice(0, 7);
  return entries.find(
    (entry) => entry.period === "monthly" && entry.focus === focus && entry.date.slice(0, 7) === selectedMonth,
  );
}

export function formatDisplayDate(dateText: string) {
  return new Intl.DateTimeFormat("en", {
    day: "numeric",
    month: "short",
    timeZone: "UTC",
    year: "numeric"
  }).format(new Date(`${dateText}T00:00:00Z`));
}

export function formatMonthLabel(dateText: string) {
  return new Intl.DateTimeFormat("en", {
    month: "long",
    timeZone: "UTC",
    year: "numeric"
  }).format(new Date(`${dateText}T00:00:00Z`));
}

export function formatWeekRange(entry: HoroscopeEntry) {
  const weekEnd = entry.period_end_date ?? addDaysIso(entry.date, 6);
  return `${formatDisplayDate(entry.date)} - ${formatDisplayDate(weekEnd)}`;
}

function addDaysIso(dateText: string, days: number) {
  const date = new Date(`${dateText}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}
