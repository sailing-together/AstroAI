import test from "node:test";
import assert from "node:assert/strict";

import { buildHoroscopeBundleUrl, buildSunSignUrl } from "../lib/api.ts";

test("buildHoroscopeBundleUrl uses canonical API v1 route", () => {
  assert.equal(
    buildHoroscopeBundleUrl("http://localhost:8000/api/v1", "gemini", 2026),
    "http://localhost:8000/api/v1/horoscope/bundle/gemini?year=2026"
  );
});

test("buildSunSignUrl uses canonical API v1 utility route", () => {
  assert.equal(
    buildSunSignUrl("http://localhost:8000/api/v1", "1994-06-14"),
    "http://localhost:8000/api/v1/utils/sun-sign?birth_date=1994-06-14"
  );
});
