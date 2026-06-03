import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AstroAI Horoscope",
  description: "Free yearly, monthly, weekly, and daily horoscope guidance."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
