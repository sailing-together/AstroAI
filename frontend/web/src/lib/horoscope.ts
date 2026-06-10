import type { HoroscopeEntry } from "./types.ts";

export const ACTIVE_HOROSCOPE_YEAR = 2026;
export const ACTIVE_HOROSCOPE_YEAR_START = `${ACTIVE_HOROSCOPE_YEAR}-01-01`;
export const ACTIVE_HOROSCOPE_YEAR_END = `${ACTIVE_HOROSCOPE_YEAR}-12-31`;

export function titleCaseSign(sign: string) {
  return sign.charAt(0).toUpperCase() + sign.slice(1);
}

export function normalizeViewDateForActiveYear(dateText: string) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateText)) return ACTIVE_HOROSCOPE_YEAR_START;
  if (dateText < ACTIVE_HOROSCOPE_YEAR_START) return ACTIVE_HOROSCOPE_YEAR_START;
  if (dateText > ACTIVE_HOROSCOPE_YEAR_END) return ACTIVE_HOROSCOPE_YEAR_END;
  return dateText;
}

export function defaultViewDateForToday(today = new Date()) {
  return normalizeViewDateForActiveYear(`${ACTIVE_HOROSCOPE_YEAR}-${today.toISOString().slice(5, 10)}`);
}

export function zodiacSignForDate(dateText: string) {
  const monthDay = normalizeViewDateForActiveYear(dateText).slice(5, 10);
  if (monthDay >= "03-21" && monthDay <= "04-19") return "aries";
  if (monthDay >= "04-20" && monthDay <= "05-20") return "taurus";
  if (monthDay >= "05-21" && monthDay <= "06-20") return "gemini";
  if (monthDay >= "06-21" && monthDay <= "07-22") return "cancer";
  if (monthDay >= "07-23" && monthDay <= "08-22") return "leo";
  if (monthDay >= "08-23" && monthDay <= "09-22") return "virgo";
  if (monthDay >= "09-23" && monthDay <= "10-22") return "libra";
  if (monthDay >= "10-23" && monthDay <= "11-21") return "scorpio";
  if (monthDay >= "11-22" && monthDay <= "12-21") return "sagittarius";
  if (monthDay >= "01-20" && monthDay <= "02-18") return "aquarius";
  if (monthDay >= "02-19" && monthDay <= "03-20") return "pisces";
  return "capricorn";
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

export function selectDailyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  return findDailyEntry(entries, date, focus);
}

export function selectWeeklyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  return findWeeklyEntry(entries, date, focus);
}

export function selectMonthlyEntry(entries: HoroscopeEntry[], date: string, focus: string) {
  return findMonthlyEntry(entries, date, focus);
}

export function selectYearlyEntry(entries: HoroscopeEntry[], focus: string) {
  return entries.find((entry) => entry.period === "yearly" && entry.focus === focus);
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
