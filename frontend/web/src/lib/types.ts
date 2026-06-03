export type HoroscopeFocus =
  | "general"
  | "love"
  | "career"
  | "money"
  | "wellness"
  | "social"
  | "family"
  | "study"
  | "mood_energy";

export type HoroscopePeriod = "daily" | "weekly" | "monthly" | "yearly";

export type HoroscopeEntry = {
  sign: string;
  target_year?: number | null;
  period: HoroscopePeriod;
  date: string;
  period_end_date?: string | null;
  focus: HoroscopeFocus | string;
  title: string;
  summary: string;
  body: string;
  lucky_numbers?: number[] | null;
  lucky_color?: string | null;
  source?: "static";
  generated_at: string;
};

export type HoroscopeBundle = {
  sign: string;
  year: number;
  yearly: HoroscopeEntry[];
  monthly: HoroscopeEntry[];
  weekly: HoroscopeEntry[];
  daily: HoroscopeEntry[];
  source: "static";
  generated_at?: string | null;
};
