import type { HoroscopeEntry } from "../../lib/types";

type ReadingPanelProps = {
  eyebrow: string;
  entry?: HoroscopeEntry;
};

export function ReadingPanel({ eyebrow, entry }: ReadingPanelProps) {
  return (
    <article className="rounded-xl border border-blue-100 bg-white/85 p-6 shadow-sm">
      <p className="text-xs font-black uppercase tracking-wide text-astro-purple">{eyebrow}</p>
      <h2 className="mt-2 text-2xl font-black text-astro-ink">{entry?.title ?? "Guidance is loading"}</h2>
      <p className="mt-4 text-lg leading-8 text-astro-purple">{entry?.summary ?? "Choose a sign and date."}</p>
      <p className="mt-4 leading-8 text-slate-600">{entry?.body ?? ""}</p>
      {entry?.lucky_color || entry?.lucky_numbers?.length ? (
        <div className="mt-5 flex flex-wrap gap-2 text-sm font-bold text-slate-600">
          {entry.lucky_color ? <span className="rounded-full bg-astro-blush px-3 py-1">{entry.lucky_color}</span> : null}
          {entry.lucky_numbers?.length ? (
            <span className="rounded-full bg-blue-50 px-3 py-1">{entry.lucky_numbers.join(", ")}</span>
          ) : null}
        </div>
      ) : null}
    </article>
  );
}
