import type { HoroscopeEntry } from "../../lib/types";

type ReadingPanelProps = {
  eyebrow: string;
  entry?: HoroscopeEntry;
  isUnavailable?: boolean;
  variant?: "primary" | "secondary";
};

export function ReadingPanel({ eyebrow, entry, isUnavailable = false, variant = "secondary" }: ReadingPanelProps) {
  const isPrimary = variant === "primary";
  const fallbackTitle = isUnavailable ? "Reading unavailable" : "Reading is preparing";
  const fallbackSummary = isUnavailable
    ? "Choose another sign or date while this guidance is being prepared."
    : "Choose a sign and date to begin.";

  return (
    <article
      className={
        isPrimary
          ? "rounded-xl border border-blue-100 bg-white p-6 shadow-xl shadow-blue-100/50 sm:p-8"
          : "rounded-xl border border-blue-100 bg-white/90 p-6 shadow-sm"
      }
    >
      <p className="text-xs font-black uppercase tracking-wide text-astro-purple">{eyebrow}</p>
      <h2 className={isPrimary ? "mt-3 text-3xl font-black leading-tight text-astro-ink" : "mt-2 text-2xl font-black text-astro-ink"}>
        {entry?.title ?? fallbackTitle}
      </h2>
      <p className={isPrimary ? "mt-5 text-xl leading-9 text-astro-purple" : "mt-4 text-lg leading-8 text-astro-purple"}>
        {entry?.summary ?? fallbackSummary}
      </p>
      <p className="mt-4 leading-8 text-slate-600">{entry?.body ?? ""}</p>
      {entry?.lucky_color || entry?.lucky_numbers?.length ? (
        <div className="mt-5 flex flex-wrap gap-2 text-sm font-bold text-slate-600">
          {entry.lucky_color ? (
            <span className="rounded-full bg-astro-blush px-3 py-1">Color: {entry.lucky_color}</span>
          ) : null}
          {entry.lucky_numbers?.length ? (
            <span className="rounded-full bg-blue-50 px-3 py-1">Numbers: {entry.lucky_numbers.join(", ")}</span>
          ) : null}
        </div>
      ) : null}
    </article>
  );
}
