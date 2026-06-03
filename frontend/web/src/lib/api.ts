import type { HoroscopeBundle } from "./types.ts";

const defaultApiBase = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1";
const localFallbackTimeoutMs = 900;
const singleApiTimeoutMs = 8_000;

export function normalizeApiBase(apiBase = defaultApiBase) {
  return apiBase.replace(/\/$/, "");
}

export function buildLocalApiBaseCandidates(apiBase = defaultApiBase) {
  const normalized = normalizeApiBase(apiBase);
  const url = new URL(normalized);
  if (!["localhost", "127.0.0.1"].includes(url.hostname) || url.port !== "8000") {
    return [normalized];
  }

  return Array.from({ length: 6 }, (_, index) => {
    url.port = String(8000 + index);
    return url.toString().replace(/\/$/, "");
  });
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
  const response = await fetchWithApiBaseFallback(
    apiBase,
    (base) => buildHoroscopeBundleUrl(base, sign, year),
    "horoscope bundle",
  );
  return response.json();
}

export async function getSunSignFromBirthDate(birthDate: string, apiBase = defaultApiBase): Promise<string> {
  const response = await fetchWithApiBaseFallback(apiBase, (base) => buildSunSignUrl(base, birthDate), "Sun sign");
  const payload = await response.json();
  return String(payload.sun_sign).toLowerCase();
}

async function fetchWithApiBaseFallback(apiBase: string, buildUrl: (apiBase: string) => string, label: string) {
  let lastError: unknown;
  const candidates = buildLocalApiBaseCandidates(apiBase);
  const timeoutMs = candidates.length > 1 ? localFallbackTimeoutMs : singleApiTimeoutMs;

  for (const candidate of candidates) {
    try {
      const response = await fetch(buildUrl(candidate), { signal: AbortSignal.timeout(timeoutMs) });
      if (response.ok) return response;
      lastError = new Error(`${response.status}`);
    } catch (error) {
      lastError = error;
    }
  }
  throw new Error(`Failed to load ${label}: ${String(lastError)}`);
}
