"use client";

import { useEffect, useMemo, useState } from "react";

import { StaticHoroscopeNotReadyError, getHoroscopeBundle, getSunSignFromBirthDate } from "../../lib/api";
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
import { FocusTabs, focusLabels } from "./FocusTabs";
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

const publicPromises = [
  "Static public readings",
  "No sign-in required",
  "Natal chart personalization later"
];

export function HoroscopeExperience() {
  const [sign, setSign] = useState("gemini");
  const [birthDate, setBirthDate] = useState("1994-06-14");
  const [viewDate, setViewDate] = useState(defaultDate);
  const [focus, setFocus] = useState<HoroscopeFocus>("general");
  const [bundle, setBundle] = useState<HoroscopeBundle | null>(null);
  const [message, setMessage] = useState("Free daily guidance");
  const [connectionError, setConnectionError] = useState(false);
  const [notReadyError, setNotReadyError] = useState(false);

  const year = Number(viewDate.slice(0, 4));
  const signLabel = titleCaseSign(sign);
  const viewDateLabel = formatDisplayDate(viewDate);
  const monthLabel = formatMonthLabel(viewDate);
  const isReadingUnavailable = connectionError || notReadyError;
  const activeFocusLabel = focusLabels[focus];

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
    setNotReadyError(false);
    getHoroscopeBundle(sign, year)
      .then((payload) => {
        if (!isMounted) return;
        setBundle(payload);
        setMessage(`${payload.sign} ${payload.year} guidance is ready`);
      })
      .catch((error) => {
        if (!isMounted) return;
        setBundle(null);
        if (error instanceof StaticHoroscopeNotReadyError) {
          setNotReadyError(true);
          setMessage(`${titleCaseSign(error.sign)} ${error.year} guidance is being prepared`);
        } else {
          setConnectionError(true);
          setMessage("Guidance is temporarily unavailable");
        }
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
      setNotReadyError(false);
      setConnectionError(true);
      setMessage("We could not read that birth date yet");
    }
  }

  return (
    <main className="min-h-screen bg-[#fbfdff]">
      <header className="border-b border-blue-100 bg-white/95">
        <div className="mx-auto flex w-full max-w-7xl flex-wrap items-center justify-between gap-4 px-5 py-4 sm:px-8">
          <a className="flex items-center gap-3" href="/">
            <div className="grid h-11 w-11 place-items-center rounded-lg bg-gradient-to-br from-astro-blue to-astro-pink font-black text-white shadow-lg shadow-blue-100">
              A
            </div>
            <div>
              <p className="text-xs font-black uppercase tracking-wide text-astro-blue">AstroAI</p>
              <p className="font-bold text-slate-600">Personal cosmic companion</p>
            </div>
          </a>
          <nav className="hidden items-center gap-6 text-sm font-bold text-slate-600 md:flex">
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
            <a className="rounded-lg bg-astro-ink px-4 py-2.5 font-black text-white shadow-md shadow-blue-100" href="#chart">
              Create chart
            </a>
          </div>
        </div>
      </header>

      <section className="border-b border-blue-100 bg-[linear-gradient(180deg,#ffffff_0%,#f7fbff_100%)]">
        <div className="mx-auto grid w-full max-w-7xl gap-8 px-5 py-8 sm:px-8 lg:grid-cols-[minmax(0,1fr)_390px] lg:py-12">
          <div className="space-y-6">
            <div className="max-w-4xl">
              <p className="text-sm font-black uppercase tracking-wide text-astro-purple">Free static guidance</p>
              <h1 className="mt-4 max-w-4xl font-display text-4xl leading-tight text-astro-ink sm:text-5xl lg:text-6xl">
                {signLabel} horoscope for {viewDateLabel}
              </h1>
              <p className="mt-5 max-w-3xl text-lg leading-8 text-slate-600">
                A calm daily reading room for sign-based guidance, with a clear bridge into saved natal chart
                personalization when you are ready.
              </p>
              <div className="mt-5 flex flex-wrap gap-2">
                {publicPromises.map((promise) => (
                  <span className="rounded-full border border-blue-100 bg-white px-4 py-2 text-sm font-bold text-slate-600" key={promise}>
                    {promise}
                  </span>
                ))}
              </div>
            </div>

            {connectionError ? (
              <div className="rounded-lg border border-rose-200 bg-rose-50 p-4 text-sm leading-7 text-rose-900">
                <p className="font-black">Guidance is temporarily unavailable</p>
                <p>Try again in a moment. Your sign and date choices will stay here.</p>
                <button
                  className="mt-3 rounded-lg bg-rose-600 px-4 py-2.5 font-black text-white"
                  onClick={() => retryLoadBundle()}
                  type="button"
                >
                  Try again
                </button>
              </div>
            ) : null}

            {notReadyError ? (
              <div className="rounded-lg border border-amber-200 bg-amber-50 p-4 text-sm leading-7 text-amber-950">
                <p className="font-black">This year&apos;s guidance is being prepared</p>
                <p>Try another sign or date, or check back once the annual readings have finished loading.</p>
              </div>
            ) : null}

            <ReadingPanel
              entry={dailyEntry}
              eyebrow={`Daily reading - ${activeFocusLabel}`}
              isUnavailable={isReadingUnavailable}
              meta={viewDateLabel}
              variant="primary"
            />
          </div>

          <aside className="space-y-4">
            <form className="grid gap-4 rounded-lg border border-blue-100 bg-white p-5 shadow-xl shadow-blue-100/35">
              <div>
                <p className="text-xs font-black uppercase tracking-wide text-astro-purple">Reading settings</p>
                <h2 className="mt-1 text-2xl font-black text-astro-ink">Your sky today</h2>
                <p className="mt-2 text-sm leading-6 text-slate-500">{message}</p>
              </div>
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

              <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-1">
                <button
                  className="rounded-lg bg-astro-blue px-4 py-3 font-black text-white shadow-lg shadow-blue-100"
                  onClick={useBirthDate}
                  type="button"
                >
                  Use birth date
                </button>
                <a
                  className="rounded-lg border border-blue-100 px-4 py-3 text-center font-black text-astro-ink hover:bg-blue-50"
                  href="#chart"
                >
                  Create chart
                </a>
              </div>
            </form>

            <div className="rounded-lg border border-blue-100 bg-[#fff8fb] p-5">
              <p className="text-xs font-black uppercase tracking-wide text-astro-purple">Chart-grounded later</p>
              <h2 className="mt-2 text-xl font-black text-astro-ink">Free now, personal after signup</h2>
              <p className="mt-3 leading-7 text-slate-600">
                Public readings stay fast and free. Saved birth time, birthplace, and AI interpretation belong in
                the registered natal chart experience.
              </p>
            </div>
          </aside>
        </div>
      </section>

      <section className="mx-auto grid w-full max-w-7xl gap-6 px-5 py-8 sm:px-8 lg:py-10">
        <div className="grid gap-3">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-sm font-black uppercase tracking-wide text-astro-purple">Reading focus</p>
              <h2 className="mt-2 text-2xl font-black text-astro-ink">Tune the guidance</h2>
            </div>
            <p className="max-w-xl leading-7 text-slate-600">
              {activeFocusLabel} is shown across the day, matching week, month, and year.
            </p>
          </div>
          <FocusTabs onChange={setFocus} selectedFocus={focus} />
        </div>

        <div className="grid gap-5 lg:grid-cols-2">
          <ReadingPanel
            entry={weeklyEntry}
            eyebrow={weeklyEntry ? `Week of ${formatWeekRange(weeklyEntry)}` : "This week"}
            isUnavailable={isReadingUnavailable}
            meta={activeFocusLabel}
          />
          <ReadingPanel
            entry={monthlyEntry}
            eyebrow={`${monthLabel} outlook`}
            isUnavailable={isReadingUnavailable}
            meta={activeFocusLabel}
          />
        </div>
        <ReadingPanel
          entry={yearlyEntry}
          eyebrow={`${year} overview`}
          isUnavailable={isReadingUnavailable}
          meta={activeFocusLabel}
        />
      </section>

      <section className="border-t border-blue-100 bg-white" id="chart">
        <div className="mx-auto grid w-full max-w-7xl gap-8 px-5 py-10 sm:px-8 lg:grid-cols-[minmax(0,0.95fr)_minmax(320px,0.55fr)]">
          <div>
            <p className="text-sm font-black uppercase tracking-wide text-astro-purple">Next product layer</p>
            <h2 className="mt-3 max-w-3xl text-3xl font-black leading-tight text-astro-ink sm:text-4xl">
              Turn this daily ritual into a chart-grounded companion.
            </h2>
            <p className="mt-4 max-w-3xl text-lg leading-8 text-slate-600">
              AstroAI becomes personal when the user saves birth details, generates a natal chart, and returns
              to ask the AI Astrologer questions with real context.
            </p>
          </div>
          <div className="rounded-lg border border-blue-100 bg-[#f7fbff] p-5">
            <p className="font-black text-astro-ink">Registered experience path</p>
            <div className="mt-4 grid gap-3 text-sm font-bold text-slate-600">
              <p className="rounded-md bg-white px-4 py-3">1. Birth data onboarding</p>
              <p className="rounded-md bg-white px-4 py-3">2. Deterministic natal chart</p>
              <p className="rounded-md bg-white px-4 py-3">3. AI Astrologer with daily limits</p>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
