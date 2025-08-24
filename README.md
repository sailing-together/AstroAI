# AstroAI

AI-powered astrology demo combining a Flutter web frontend with a FastAPI backend that integrates Google's Gemini for astro features.

## Monorepo Layout

```
backend/   # FastAPI app (Gemini-powered endpoints, SQLite, APScheduler)
frontend/  # Flutter web app (UI, calls FastAPI)
```

## Quick Start

### 1) Backend (FastAPI)

```bash
cd backend
python -m venv .venv && source .venv/bin/activate  # optional but recommended
pip install -r requirements.txt
fastapi dev main.py
# API will run at http://localhost:8000
```

Endpoints exposed (high level):
- POST `/horoscope`
- POST `/compatibility`
- POST `/natal_chart`
- POST `/review_event`
- POST `/with_celebrity`
- GET  `/events-today`
- POST `/update-database/`
- POST `/admin/clear-past-events/`

For details and request/response shapes, see `backend/README.md`.

### 2) Frontend (Flutter Web)

```bash
cd frontend/flutter
flutter pub get
flutter run -d chrome
# App will open in the browser (default port printed by Flutter)
```

The frontend calls the backend at `http://localhost:8000` (see `lib/services/api_service.dart`). If you run on an Android emulator, change the base URL to `http://10.0.2.2:8000`.

## How It Works

- Flutter UI collects basic user info (birth date, location) and stores it in app state.
- UI pages call FastAPI endpoints to fetch daily horoscope and today's events.
- The AI Assistant page uses the horoscope endpoint to provide a quick demo answer flow.

## Troubleshooting

- CORS: CORS is enabled in `backend/main.py` for all origins. Lock it down as needed for production.
- Ports: Ensure the backend is running on `8000` and accessible from the browser/device you test with.
- Gemini API: The demo services use `google-generativeai`; ensure outbound internet access is available.

## License

MIT. See `LICENSE`.
