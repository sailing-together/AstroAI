# AstroAI Frontend (Flutter Web)

Flutter web app that calls the AstroAI FastAPI backend to display horoscopes, planetary events, and AI-guided content.

![AstroAI Preview](assets/MainSpace.png)

## Project Structure

```
lib/
├── main.dart                # App entry and navigation
├── pages.dart               # Additional routed pages
├── pages/                   # Feature pages (AI assistant, daily insights)
├── providers/               # App state and API orchestration
├── services/api_service.dart# FastAPI client
└── models/                  # Data models
```

## Run Locally

Prerequisites: Flutter SDK 3.8+, Dart SDK

```bash
cd ../../backend
fastapi dev main.py            # http://localhost:8000

cd ../frontend/flutter
flutter pub get
flutter run -d chrome          # opens the app in browser
```

The frontend calls `http://localhost:8000` by default (see `lib/services/api_service.dart`). For Android emulator, change to `http://10.0.2.2:8000`.

## Key Endpoints Consumed

- POST `/horoscope` – returns `{ sign, horoscope: { overall_horoscope, love_advice, career_advice, wealth_advice, daily_suggestion } }`
- GET `/events-today` – returns `{ date, lunar_events: [], retrogrades: [], ingresses: [] }`
- POST `/compatibility`, `/natal_chart`, `/review_event`, `/with_celebrity` – available for future pages

## Notes

- CORS is enabled in the backend for development.
- If you see empty data, make sure the backend is running and your birthdate/location are set via the Get Started dialog.

## License

MIT. See root `LICENSE`.


