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
    <div className="grid gap-2 sm:grid-cols-3" role="tablist" aria-label="Horoscope focus">
      {focusOrder.map((focus) => (
        <button
          aria-selected={focus === selectedFocus}
          className={
            focus === selectedFocus
              ? "rounded-lg bg-astro-blue px-4 py-3 text-left text-sm font-bold text-white shadow-md shadow-blue-100"
              : "rounded-lg border border-blue-100 bg-white px-4 py-3 text-left text-sm font-bold text-slate-700"
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
