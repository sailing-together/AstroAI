import type { HoroscopeBundle } from "./types.ts";

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

export async function getHoroscopeBundle(
  sign: string,
  year: number,
  apiBase = defaultApiBase,
): Promise<HoroscopeBundle> {
  const response = await fetch(buildHoroscopeBundleUrl(apiBase, sign, year));
  if (!response.ok) {
    throw new Error(`Failed to load horoscope bundle: ${response.status}`);
  }
  return response.json();
}

export async function getSunSignFromBirthDate(birthDate: string, apiBase = defaultApiBase): Promise<string> {
  const response = await fetch(buildSunSignUrl(apiBase, birthDate));
  if (!response.ok) {
    throw new Error(`Failed to calculate Sun sign: ${response.status}`);
  }
  const payload = await response.json();
  return String(payload.sun_sign).toLowerCase();
}
