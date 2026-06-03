"use client";

import { useEffect, useMemo, useState } from "react";

import { getHoroscopeBundle, getSunSignFromBirthDate } from "../../lib/api";
import { findDailyEntry, findWeeklyEntry, titleCaseSign } from "../../lib/horoscope";
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
const apiBaseLabel = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1";

export function HoroscopeExperience() {
  const [sign, setSign] = useState("gemini");
  const [birthDate, setBirthDate] = useState("1994-06-14");
  const [viewDate, setViewDate] = useState(defaultDate);
  const [focus, setFocus] = useState<HoroscopeFocus>("general");
  const [bundle, setBundle] = useState<HoroscopeBundle | null>(null);
  const [message, setMessage] = useState("Free static horoscope guidance");
  const [connectionError, setConnectionError] = useState(false);

  const year = Number(viewDate.slice(0, 4));

  useEffect(() => {
    let isMounted = true;
    retryLoadBundle({ isMounted });
    return () => {
      isMounted = false;
    };
  }, [sign, year]); // eslint-disable-line react-hooks/exhaustive-deps

  function retryLoadBundle(options?: { isMounted?: boolean }) {
    const isMounted = options?.isMounted ?? true;
    setMessage("Loading guidance");
    setConnectionError(false);
    getHoroscopeBundle(sign, year)
      .then((payload) => {
        if (!isMounted) return;
        setBundle(payload);
        setMessage(`${payload.sign} ${payload.year} static guidance`);
      })
      .catch(() => {
        if (!isMounted) return;
        setBundle(null);
        setConnectionError(true);
        setMessage("Backend connection needed");
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
  const monthlyEntries = useMemo(
    () => bundle?.monthly.filter((entry) => entry.focus === focus).slice(0, 12) ?? [],
    [bundle, focus],
  );

  async function useBirthDate() {
    if (!birthDate) return;
    setMessage("Finding your Sun sign");
    try {
      const nextSign = await getSunSignFromBirthDate(birthDate);
      setSign(nextSign);
      setMessage(`${titleCaseSign(nextSign)} selected`);
    } catch {
      setConnectionError(true);
      setMessage("Backend connection needed");
    }
  }

  return (
    <main className="min-h-screen">
      <header className="mx-auto flex w-full max-w-6xl flex-wrap items-center justify-between gap-4 px-5 py-5 sm:px-8">
        <div className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-lg bg-gradient-to-br from-astro-blue to-astro-pink font-black text-white shadow-lg shadow-blue-100">
            A
          </div>
          <div>
            <p className="text-xs font-black uppercase tracking-wide text-astro-blue">AstroAI</p>
            <p className="font-bold text-slate-600">Public horoscope</p>
          </div>
        </div>
        <a className="rounded-lg border border-blue-100 bg-white px-4 py-2 font-bold text-slate-700" href="/">
          Home
        </a>
      </header>

      <section className="border-y border-blue-100 bg-white/65">
        <div className="mx-auto grid w-full max-w-6xl gap-8 px-5 py-10 sm:px-8 lg:grid-cols-[1.2fr_0.8fr]">
        <div>
          <p className="text-sm font-black uppercase tracking-wide text-astro-purple">Free static guidance</p>
          <h1 className="mt-4 max-w-3xl font-display text-5xl leading-tight text-astro-ink">
            Your {year} {titleCaseSign(sign)} horoscope
          </h1>
          <p className="mt-5 max-w-2xl text-lg leading-8 text-slate-600">
            Choose a sign or use a birth date, then browse the selected day, matching week, month,
            and year from one pre-generated static bundle.
          </p>
          <p className="mt-4 font-bold text-astro-blue">{message}</p>
          {connectionError ? (
            <div className="mt-6 rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm leading-7 text-rose-900">
              <p className="font-black">Backend connection needed</p>
              <p>
                Start the FastAPI backend at <strong>{apiBaseLabel}</strong>, then retry this page.
              </p>
              <button
                className="mt-3 rounded-lg bg-rose-600 px-4 py-2 font-black text-white"
                onClick={() => retryLoadBundle()}
                type="button"
              >
                Retry connection
              </button>
            </div>
          ) : null}
        </div>

        <form className="grid gap-4 rounded-xl border border-blue-100 bg-white/90 p-5 shadow-xl shadow-blue-100/40">
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
        </div>
      </section>

      <section className="mx-auto grid w-full max-w-6xl gap-5 px-5 py-8 sm:px-8">
        <div className="rounded-xl border border-blue-100 bg-white/80 p-4">
          <FocusTabs onChange={setFocus} selectedFocus={focus} />
        </div>
        <div className="grid gap-5 lg:grid-cols-2">
          <ReadingPanel entry={dailyEntry} eyebrow={`Daily - ${viewDate}`} />
          <ReadingPanel entry={weeklyEntry} eyebrow="This week" />
        </div>
        <ReadingPanel entry={yearlyEntry} eyebrow={`${year} overview`} />
      </section>

      <section className="mx-auto w-full max-w-6xl px-5 py-10 sm:px-8">
        <h2 className="text-3xl font-black text-astro-ink">Months</h2>
        <div className="mt-5 grid gap-4 md:grid-cols-2">
          {monthlyEntries.map((entry) => (
            <ReadingPanel entry={entry} eyebrow={entry.date} key={`${entry.date}-${entry.focus}`} />
          ))}
        </div>
      </section>
    </main>
  );
}
