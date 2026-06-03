import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        astro: {
          blue: "#4097FF",
          pink: "#FF92A2",
          sky: "#A5E5F9",
          purple: "#8985CF",
          blush: "#FFF3F8",
          ink: "#1A2538"
        }
      },
      fontFamily: {
        sans: ["Inter", "Raleway", "system-ui", "sans-serif"],
        display: ["Cinzel", "Georgia", "serif"]
      }
    }
  },
  plugins: []
};

export default config;
