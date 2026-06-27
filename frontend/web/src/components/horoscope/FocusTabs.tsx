import type { HoroscopeFocus } from "../../lib/types";

export const focusLabels: Record<HoroscopeFocus, string> = {
  general: "General",
  love: "Love",
  career: "Career",
  money: "Money",
  wellness: "Wellness",
  social: "Social",
  family: "Family",
  study: "Study",
  mood_energy: "Mood Energy"
};

const focusOrder = Object.keys(focusLabels) as HoroscopeFocus[];

type FocusTabsProps = {
  selectedFocus: HoroscopeFocus;
  onChange: (focus: HoroscopeFocus) => void;
};

export function FocusTabs({ selectedFocus, onChange }: FocusTabsProps) {
  return (
    <div
      className="flex gap-2 overflow-x-auto rounded-lg border border-blue-100 bg-white p-2 shadow-sm"
      role="tablist"
      aria-label="Horoscope focus"
    >
      {focusOrder.map((focus) => (
        <button
          aria-selected={focus === selectedFocus}
          className={
            focus === selectedFocus
              ? "min-w-fit rounded-md bg-astro-ink px-4 py-2.5 text-sm font-bold text-white shadow-md shadow-blue-100"
              : "min-w-fit rounded-md px-4 py-2.5 text-sm font-bold text-slate-600 hover:bg-blue-50 hover:text-astro-ink"
          }
          key={focus}
          onClick={() => onChange(focus)}
          role="tab"
          type="button"
        >
          {focusLabels[focus]}
        </button>
      ))}
    </div>
  );
}
