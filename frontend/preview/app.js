const focusLabels = {
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

const state = {
  bundle: null,
  focus: "general"
};

const SUN_SIGN_PATH = "/api/v1/utils/sun-sign";
const HOROSCOPE_BUNDLE_PATH = "/api/v1/horoscope/bundle/";

const els = {
  apiStatus: document.getElementById("apiStatus"),
  signSelect: document.getElementById("signSelect"),
  birthDate: document.getElementById("birthDate"),
  yearInput: document.getElementById("yearInput"),
  apiBase: document.getElementById("apiBase"),
  birthDateButton: document.getElementById("birthDateButton"),
  loadButton: document.getElementById("loadButton"),
  selectedSign: document.getElementById("selectedSign"),
  bundleMeta: document.getElementById("bundleMeta"),
  focusTabs: document.getElementById("focusTabs"),
  dailyDate: document.getElementById("dailyDate"),
  dailyTitle: document.getElementById("dailyTitle"),
  dailySummary: document.getElementById("dailySummary"),
  dailyBody: document.getElementById("dailyBody"),
  luckyColor: document.getElementById("luckyColor"),
  luckyNumbers: document.getElementById("luckyNumbers"),
  yearlyList: document.getElementById("yearlyList"),
  monthlyList: document.getElementById("monthlyList"),
  weeklyList: document.getElementById("weeklyList")
};

function apiBase() {
  return els.apiBase.value.replace(/\/$/, "");
}

function setStatus(text, isError = false) {
  els.apiStatus.textContent = text;
  els.apiStatus.classList.toggle("error", isError);
}

function titleCaseSign(sign) {
  return sign.charAt(0).toUpperCase() + sign.slice(1);
}

async function fetchJson(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`${response.status} ${response.statusText}`);
  }
  return response.json();
}

async function useBirthDate() {
  const birthDate = els.birthDate.value;
  if (!birthDate) return;
  setStatus("Calculating");
  try {
    const path = SUN_SIGN_PATH.replace("/api/v1", "");
    const payload = await fetchJson(`${apiBase()}${path}?birth_date=${encodeURIComponent(birthDate)}`);
    els.signSelect.value = payload.sun_sign.toLowerCase();
    setStatus(payload.sun_sign);
    await loadBundle();
  } catch (error) {
    setStatus(error.message, true);
  }
}

async function loadBundle() {
  const sign = els.signSelect.value;
  const year = Number(els.yearInput.value || new Date().getFullYear());
  setStatus("Loading");
  setBusy(true);
  try {
    const path = HOROSCOPE_BUNDLE_PATH.replace("/api/v1", "");
    state.bundle = await fetchJson(`${apiBase()}${path}${sign}?year=${year}`);
    setStatus("Static");
    renderBundle();
  } catch (error) {
    setStatus(error.message, true);
  } finally {
    setBusy(false);
  }
}

function setBusy(isBusy) {
  els.loadButton.disabled = isBusy;
  els.birthDateButton.disabled = isBusy;
}

function renderFocusTabs() {
  els.focusTabs.innerHTML = "";
  Object.entries(focusLabels).forEach(([key, label]) => {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = label;
    button.className = key === state.focus ? "active" : "";
    button.addEventListener("click", () => {
      state.focus = key;
      renderBundle();
    });
    els.focusTabs.appendChild(button);
  });
}

function renderBundle() {
  if (!state.bundle) return;
  renderFocusTabs();
  els.selectedSign.textContent = state.bundle.sign;
  els.bundleMeta.textContent = `${state.bundle.year} ${state.bundle.source} bundle`;

  const dailyEntry = findEntryForFocus(state.bundle.daily, state.focus) || state.bundle.daily[0];
  renderDaily(dailyEntry);
  renderList(els.yearlyList, entriesForFocus(state.bundle.yearly), 1);
  renderList(els.monthlyList, entriesForFocus(state.bundle.monthly), 12);
  renderList(els.weeklyList, entriesForFocus(state.bundle.weekly), 12);
}

function entriesForFocus(entries) {
  return entries.filter((entry) => entry.focus === state.focus);
}

function findEntryForFocus(entries, focus) {
  return entries.find((entry) => entry.focus === focus);
}

function renderDaily(entry) {
  if (!entry) return;
  els.dailyDate.textContent = `${entry.period} - ${entry.date}`;
  els.dailyTitle.textContent = entry.title;
  els.dailySummary.textContent = entry.summary;
  els.dailyBody.textContent = entry.body;
  els.luckyColor.textContent = entry.lucky_color || "No color";
  els.luckyNumbers.textContent = (entry.lucky_numbers || []).join(", ") || "No numbers";
}

function renderList(container, entries, limit) {
  container.innerHTML = "";
  entries.slice(0, limit).forEach((entry) => {
    const item = document.createElement("article");
    item.className = "period-item";
    item.innerHTML = `
      <strong>${entry.date}</strong>
      <p>${entry.summary}</p>
    `;
    container.appendChild(item);
  });
}

els.birthDateButton.addEventListener("click", useBirthDate);
els.loadButton.addEventListener("click", loadBundle);
renderFocusTabs();
document.addEventListener("DOMContentLoaded", loadBundle);
