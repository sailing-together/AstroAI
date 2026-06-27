import type { HoroscopeEntry } from "../../lib/types";

type ReadingPanelProps = {
  eyebrow: string;
  entry?: HoroscopeEntry;
  isUnavailable?: boolean;
  meta?: string;
  variant?: "primary" | "secondary";
};

export function ReadingPanel({ eyebrow, entry, isUnavailable = false, meta, variant = "secondary" }: ReadingPanelProps) {
  const isPrimary = variant === "primary";
  const fallbackTitle = isUnavailable ? "Reading unavailable" : "Reading is preparing";
  const fallbackSummary = isUnavailable
    ? "Choose another sign or date while this guidance is being prepared."
    : "Choose a sign and date to begin.";

  return (
    <article
      className={
        isPrimary
          ? "overflow-hidden rounded-lg border border-blue-100 bg-white shadow-xl shadow-blue-100/45"
          : "rounded-lg border border-blue-100 bg-white/95 p-5 shadow-sm sm:p-6"
      }
    >
      <div className={isPrimary ? "border-b border-blue-100 bg-[#f7fbff] px-6 py-5 sm:px-8" : ""}>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-xs font-black uppercase tracking-wide text-astro-purple">{eyebrow}</p>
          {meta ? <p className="text-sm font-bold text-slate-500">{meta}</p> : null}
        </div>
      </div>
      <div className={isPrimary ? "p-6 sm:p-8" : ""}>
        <h2
          className={
            isPrimary
              ? "max-w-3xl text-3xl font-black leading-tight text-astro-ink sm:text-4xl"
              : "text-2xl font-black leading-tight text-astro-ink"
          }
        >
          {entry?.title ?? fallbackTitle}
        </h2>
        <p
          className={
            isPrimary
              ? "mt-5 max-w-3xl text-xl leading-9 text-astro-purple"
              : "mt-4 text-lg leading-8 text-astro-purple"
          }
        >
          {entry?.summary ?? fallbackSummary}
        </p>
        <p className="mt-4 max-w-4xl leading-8 text-slate-600">{entry?.body ?? ""}</p>
      </div>
      {entry?.lucky_color || entry?.lucky_numbers?.length ? (
        <div className={isPrimary ? "flex flex-wrap gap-2 px-6 pb-6 text-sm font-bold text-slate-600 sm:px-8 sm:pb-8" : "mt-5 flex flex-wrap gap-2 text-sm font-bold text-slate-600"}>
          {entry.lucky_color ? (
            <span className="rounded-full bg-astro-blush px-3 py-1.5">Color: {entry.lucky_color}</span>
          ) : null}
          {entry.lucky_numbers?.length ? (
            <span className="rounded-full bg-blue-50 px-3 py-1.5">Numbers: {entry.lucky_numbers.join(", ")}</span>
          ) : null}
        </div>
      ) : null}
    </article>
  );
}
