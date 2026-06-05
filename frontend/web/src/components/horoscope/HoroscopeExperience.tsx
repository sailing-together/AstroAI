"use client";

import { useEffect, useMemo, useState } from "react";

import { getHoroscopeBundle, getSunSignFromBirthDate } from "../../lib/api";
import {
  findDailyEntry,
  findMonthlyEntry,
  findWeeklyEntry,
  formatDisplayDate,
  formatMonthLabel,
  formatWeekRange,
  titleCaseSign
} from "../../lib/horoscope";
import type { HoroscopeBundle, HoroscopeFocus } from "../../lib/types";
import { FocusTabs } from "./FocusTabs";
import { ReadingPanel } from "./ReadingPanel";

const signs = [
  "aries",
  "taurus",
  "gemini",
  "cancer",
  "leo",
  "virgo",
  "libra",
  "scorpio",
  "sagittarius",
  "capricorn",
  "aquarius",
  "pisces"
];

const defaultDate = "2026-01-01";

export function HoroscopeExperience() {
  const [sign, setSign] = useState("gemini");
  const [birthDate, setBirthDate] = useState("1994-06-14");
  const [viewDate, setViewDate] = useState(defaultDate);
  const [focus, setFocus] = useState<HoroscopeFocus>("general");
  const [bundle, setBundle] = useState<HoroscopeBundle | null>(null);
  const [message, setMessage] = useState("Free daily guidance");
  const [connectionError, setConnectionError] = useState(false);

  const year = Number(viewDate.slice(0, 4));
  const signLabel = titleCaseSign(sign);
  const viewDateLabel = formatDisplayDate(viewDate);
  const monthLabel = formatMonthLabel(viewDate);

  useEffect(() => {
    let isMounted = true;
    retryLoadBundle({ isMounted });
    return () => {
      isMounted = false;
    };
  }, [sign, year]); // eslint-disable-line react-hooks/exhaustive-deps

  function retryLoadBundle(options?: { isMounted?: boolean }) {
    const isMounted = options?.isMounted ?? true;
    setMessage("Preparing your reading");
    setConnectionError(false);
    getHoroscopeBundle(sign, year)
      .then((payload) => {
        if (!isMounted) return;
        setBundle(payload);
        setMessage(`${payload.sign} ${payload.year} guidance is ready`);
      })
      .catch(() => {
        if (!isMounted) return;
        setBundle(null);
        setConnectionError(true);
        setMessage("Guidance is temporarily unavailable");
      });
  }

  const dailyEntry = useMemo(() => {
    if (!bundle) return undefined;
    return findDailyEntry(bundle.daily, viewDate, focus) ?? bundle.daily.find((entry) => entry.focus === focus);
  }, [bundle, focus, viewDate]);

  const weeklyEntry = useMemo(() => {
    if (!bundle) return undefined;
    return findWeeklyEntry(bundle.weekly, viewDate, focus) ?? bundle.weekly.find((entry) => entry.focus === focus);
  }, [bundle, focus, viewDate]);

  const yearlyEntry = useMemo(() => bundle?.yearly.find((entry) => entry.focus === focus), [bundle, focus]);
  const monthlyEntry = useMemo(() => {
    if (!bundle) return undefined;
    return findMonthlyEntry(bundle.monthly, viewDate, focus) ?? bundle.monthly.find((entry) => entry.focus === focus);
  }, [bundle, focus, viewDate]);

  async function useBirthDate() {
    if (!birthDate) return;
    setMessage("Finding your Sun sign");
    try {
      const nextSign = await getSunSignFromBirthDate(birthDate);
      setSign(nextSign);
      setMessage(`${titleCaseSign(nextSign)} selected`);
    } catch {
      setConnectionError(true);
      setMessage("We could not read that birth date yet");
    }
  }

  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#ffffff_0%,#f7fbff_48%,#fff7fb_100%)]">
      <header className="border-b border-blue-100 bg-white/95">
        <div className="mx-auto flex w-full max-w-6xl flex-wrap items-center justify-between gap-4 px-5 py-4 sm:px-8">
          <a className="flex items-center gap-3" href="/">
            <div className="grid h-11 w-11 place-items-center rounded-lg bg-gradient-to-br from-astro-blue to-astro-pink font-black text-white shadow-lg shadow-blue-100">
              A
            </div>
            <div>
              <p className="text-xs font-black uppercase tracking-wide text-astro-blue">AstroAI</p>
              <p className="font-bold text-slate-600">Public horoscope</p>
            </div>
          </a>
          <nav className="hidden items-center gap-5 text-sm font-bold text-slate-600 md:flex">
            <a className="text-astro-ink" href="/horoscope">
              Horoscope
            </a>
            <a href="#zodiac">Zodiac</a>
            <a href="#compatibility">Compatibility</a>
          </nav>
          <div className="flex items-center gap-3">
            <a className="hidden font-bold text-slate-600 sm:inline" href="#signin">
              Sign in
            </a>
            <a className="rounded-lg bg-astro-blue px-4 py-2 font-black text-white shadow-md shadow-blue-100" href="#chart">
              Create chart
            </a>
          </div>
        </div>
      </header>

      <section className="border-b border-blue-100 bg-white/70">
        <div className="mx-auto grid w-full max-w-6xl gap-8 px-5 py-8 sm:px-8 lg:grid-cols-[minmax(0,1fr)_360px] lg:py-12">
          <div className="space-y-6">
            <div>
              <p className="text-sm font-black uppercase tracking-wide text-astro-purple">Free horoscope</p>
              <h1 className="mt-4 max-w-3xl font-display text-4xl leading-tight text-astro-ink sm:text-5xl">
                {signLabel} guidance for {viewDateLabel}
              </h1>
              <p className="mt-5 max-w-2xl text-lg leading-8 text-slate-600">
                Choose a sign or enter a birthday, then read the selected day with its matching week, month,
                and year outlook.
              </p>
              <p className="mt-4 font-bold text-astro-blue">{message}</p>
            </div>

            {connectionError ? (
              <div className="rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm leading-7 text-rose-900">
                <p className="font-black">Guidance is temporarily unavailable</p>
                <p>Try again in a moment. Your sign and date choices will stay here.</p>
                <button
                  className="mt-3 rounded-lg bg-rose-600 px-4 py-2 font-black text-white"
                  onClick={() => retryLoadBundle()}
                  type="button"
                >
                  Try again
                </button>
              </div>
            ) : null}

            <ReadingPanel entry={dailyEntry} eyebrow={`Daily reading - ${viewDateLabel}`} variant="primary" />
          </div>

          <aside className="space-y-4">
            <form className="grid gap-4 rounded-xl border border-blue-100 bg-white p-5 shadow-xl shadow-blue-100/40">
              <label className="grid gap-2 text-sm font-bold text-slate-700">
                Sign
                <select
                  className="rounded-lg border border-blue-100 bg-white px-3 py-3"
                  onChange={(event) => setSign(event.target.value)}
                  value={sign}
                >
                  {signs.map((item) => (
                    <option key={item} value={item}>
                      {titleCaseSign(item)}
                    </option>
                  ))}
                </select>
              </label>

              <label className="grid gap-2 text-sm font-bold text-slate-700">
                Birth date
                <input
                  className="rounded-lg border border-blue-100 bg-white px-3 py-3"
                  onChange={(event) => setBirthDate(event.target.value)}
                  type="date"
                  value={birthDate}
                />
              </label>

              <label className="grid gap-2 text-sm font-bold text-slate-700">
                View date
                <input
                  className="rounded-lg border border-blue-100 bg-white px-3 py-3"
                  max={`${year}-12-31`}
                  min={`${year}-01-01`}
                  onChange={(event) => setViewDate(event.target.value)}
                  type="date"
                  value={viewDate}
                />
              </label>

              <button
                className="rounded-lg bg-astro-blue px-4 py-3 font-black text-white shadow-lg shadow-blue-100"
                onClick={useBirthDate}
                type="button"
              >
                Use birth date
              </button>
            </form>

            <div className="rounded-xl border border-blue-100 bg-white/85 p-5">
              <p className="text-xs font-black uppercase tracking-wide text-astro-purple">Next</p>
              <h2 className="mt-2 text-xl font-black text-astro-ink">Personal chart readings</h2>
              <p className="mt-3 leading-7 text-slate-600">
                Birth time, birth place, and personalized prediction flows will sit behind sign-in.
              </p>
            </div>
          </aside>
        </div>
      </section>

      <section className="mx-auto grid w-full max-w-6xl gap-5 px-5 py-8 sm:px-8">
        <div>
          <p className="mb-3 text-sm font-black uppercase tracking-wide text-astro-purple">Focus</p>
          <FocusTabs onChange={setFocus} selectedFocus={focus} />
        </div>
        <div className="grid gap-5 lg:grid-cols-2">
          <ReadingPanel
            entry={weeklyEntry}
            eyebrow={weeklyEntry ? `Week of ${formatWeekRange(weeklyEntry)}` : "This week"}
          />
          <ReadingPanel entry={monthlyEntry} eyebrow={`${monthLabel} outlook`} />
        </div>
        <ReadingPanel entry={yearlyEntry} eyebrow={`${year} overview`} />
      </section>
    </main>
  );
}
