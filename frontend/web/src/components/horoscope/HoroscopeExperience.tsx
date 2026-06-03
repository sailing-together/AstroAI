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

export function HoroscopeExperience() {
  const [sign, setSign] = useState("gemini");
  const [birthDate, setBirthDate] = useState("1994-06-14");
  const [viewDate, setViewDate] = useState(defaultDate);
  const [focus, setFocus] = useState<HoroscopeFocus>("general");
  const [bundle, setBundle] = useState<HoroscopeBundle | null>(null);
  const [message, setMessage] = useState("Free static horoscope guidance");

  const year = Number(viewDate.slice(0, 4));

  useEffect(() => {
    let isMounted = true;
    setMessage("Loading guidance");
    getHoroscopeBundle(sign, year)
      .then((payload) => {
        if (!isMounted) return;
        setBundle(payload);
        setMessage(`${payload.sign} ${payload.year} static guidance`);
      })
      .catch(() => {
        if (!isMounted) return;
        setBundle(null);
        setMessage("Guidance is temporarily unavailable");
      });
    return () => {
      isMounted = false;
    };
  }, [sign, year]);

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
      setMessage("Birth date lookup is temporarily unavailable");
    }
  }

  return (
    <main className="mx-auto min-h-screen w-full max-w-6xl px-5 py-8 sm:px-8">
      <header className="flex flex-wrap items-center justify-between gap-4 border-b border-blue-100 pb-5">
        <div className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-lg bg-gradient-to-br from-astro-blue to-astro-pink font-black text-white">
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

      <section className="grid gap-8 py-10 lg:grid-cols-[1.05fr_0.95fr]">
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
        </div>

        <form className="grid gap-4 rounded-xl border border-blue-100 bg-white/85 p-5 shadow-sm">
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
      </section>

      <section className="grid gap-5">
        <FocusTabs onChange={setFocus} selectedFocus={focus} />
        <div className="grid gap-5 lg:grid-cols-2">
          <ReadingPanel entry={dailyEntry} eyebrow={`Daily - ${viewDate}`} />
          <ReadingPanel entry={weeklyEntry} eyebrow="This week" />
        </div>
        <ReadingPanel entry={yearlyEntry} eyebrow={`${year} overview`} />
      </section>

      <section className="py-10">
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
