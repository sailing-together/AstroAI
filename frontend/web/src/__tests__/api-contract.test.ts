import test from "node:test";
import assert from "node:assert/strict";

import { buildHoroscopeBundleUrl, buildLocalApiBaseCandidates, buildSunSignUrl } from "../lib/api.ts";

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

test("buildLocalApiBaseCandidates tries nearby local backend ports", () => {
  assert.deepEqual(buildLocalApiBaseCandidates("http://localhost:8000/api/v1"), [
    "http://localhost:8000/api/v1",
    "http://localhost:8001/api/v1",
    "http://localhost:8002/api/v1",
    "http://localhost:8003/api/v1",
    "http://localhost:8004/api/v1",
    "http://localhost:8005/api/v1"
  ]);
});
