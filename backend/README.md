## File Structure

- **api**: Stores feature logic, cookie router, and cookie reader.
- **core**: Currently empty. Intended for cross-app global configuration (e.g., API keys, cookie settings). Not necessary now since there is only one cookie.
- **models**: Contains user input models, defining the structure of data required to call specific features.
- **services**: Contains business logic, including the prompt builder and Gemini setup for each feature.
- **main.py**: Serves as the FastAPI root.
- **\_\_init\_\_.py**: Empty files in each folder to mark them as Python modules for importing.

---

## Running the Backend

1.  **Navigate to the `backend` directory:**
    ```bash
    cd backend
    ```
2.  **Install Python dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Run the FastAPI development server:**
    ```bash
    fastapi dev main.py
    ```
    The API will be accessible at `http://localhost:8000`.

---

## Scheduled Tasks

This backend includes scheduled tasks for database maintenance:

-   **Database Update (`/update-database/`)**: Runs every 30 days to fetch and insert new astrological event data.
-   **Clear Past Events (`/admin/clear-past-events/`)**: Runs every 30 days to remove outdated astrological event data.
-   **Daily Events Fetch (`/events-today`)**: Runs daily to fetch and log today's astrological events.

These tasks are managed by `APScheduler` and run in the background as long as the FastAPI server is active.

---

## Database

The backend uses an SQLite database named `planetary_notification_data.sqlite3` located in the `backend/database/` directory.

### Checking Database Contents

You can inspect the database directly using the `sqlite3` command-line tool.

1.  **Navigate to the `backend` directory:**
    ```bash
    cd backend
    ```
2.  **Connect to the database:**
    ```bash
    sqlite3 database/planetary_notification_data.sqlite3
    ```
3.  **Once connected, you can run SQL commands or SQLite-specific commands:**
    *   **List tables:**
        ```sqlite
        .tables
        ```
    *   **Count rows in a table (e.g., `lunar_events`):**
        ```sqlite
        SELECT COUNT(*) FROM lunar_events;
        ```
    *   **Exit `sqlite3`:**
        ```sqlite
        .quit
        ```

---

## API Endpoints

Below are the API endpoints provided by the backend, along with their expected input requirements.

### `POST /compatibility`

Analyzes astrological compatibility between two signs.

**Request Body (JSON):**

```json
{
  "sign_1": "<string>",  // The first zodiac sign (e.g., "Aries")
  "sign_2": "<string>"   // The second zodiac sign (e.g., "Libra")
}
```

### `POST /horoscope`

Generates a horoscope based on the user's birthdate (and optionally sign).

**Request Body (JSON):**

```json
{
  "birthdate": "<string>", // User's birthdate in YYYY-MM-DD format (e.g., "1990-05-15")
  "sign": "<string>"     // Optional: The zodiac sign (e.g., "Taurus"). If not provided, it will be derived from birthdate.
}
```

### `POST /natal_chart`

Calculates simplified natal chart data for a given birth date, time, and location.

**Request Body (JSON):**

```json
{
  "birth_date": "<string>",     // User's birth date in YYYY-MM-DD format (e.g., "1990-05-15")
  "birth_time": "<string>",     // User's birth time in HH:MM format (e.g., "14:30"). Do not adjust for timezone.
  "birth_location": "<string>"  // User's birth location (city, country) (e.g., "London, UK")
}
```
*Note: `birth_timezone`, `birth_longitude`, and `birth_latitude` are automatically determined from `birth_location` if not provided.*

### `POST /review_event`

Provides astrological insights for a past event or predicts the outcome of a future event.

**Request Body (JSON):**

```json
{
  "event": "<string>",       // What event is being reviewed (e.g., "job interview")
  "event_date": "<string>",  // What date the event occurred in YYYY-MM-DD format (e.g., "2024-07-01")
  "birthdate": "<string>",   // The user's birthdate in YYYY-MM-DD format (e.g., "1990-05-15")
  "location": "<string>",    // The user's location (city, country) (e.g., "London, UK")
  "outcome": "<string>"      // Optional: Required if event_date is in the past. What was the outcome? (e.g., "got the job")
}
```

### `POST /with_celebrity`

Analyzes astrological compatibility with a celebrity.

**Request Body (JSON):**

```json
{
  "birthdate": "<string>",      // Birthdate of the user in YYYY-MM-DD format (e.g., "1990-05-15")
  "sign": "<string>",          // Optional: The zodiac sign (e.g., "Taurus"). If not provided, it will be derived from birthdate.
  "celebrity_name": "<string>" // Optional: Name of the celebrity. If not provided, top 3 compatible celebrities will be selected.
}
```

### `POST /save-data`

Saves user's birthday and location as a cookie in the browser.

**Request Body (Form Data):**

```
Content-Type: application/x-www-form-urlencoded

birthday=<string>&location=<string>
```

*   `birthday`: User's birthday in YYYY-MM-DD format (e.g., `1990-05-15`)
*   `location`: User's location (city, country) (e.g., `London, UK`)

### `POST /update-database/`

Manually triggers an update of the astrological event database. No request body required.

### `POST /admin/clear-past-events/`

Manually triggers the cleanup of past astrological events from the database. No request body required.

### `GET /events-today`

Retrieves today's astrological events (lunar events, retrogrades, ingresses). No request parameters required.

---

## Database

The backend uses an SQLite database named `planetary_notification_data.sqlite3` located in the `backend/database/` directory.

### Checking Database Contents

You can inspect the database directly using the `sqlite3` command-line tool.

1.  **Navigate to the `backend` directory:**
    ```bash
    cd backend
    ```
2.  **Connect to the database:**
    ```bash
    sqlite3 database/planetary_notification_data.sqlite3
    ```
3.  **Once connected, you can run SQL commands or SQLite-specific commands:**
    *   **List tables:**
        ```sqlite
        .tables
        ```
    *   **Count rows in a table (e.g., `lunar_events`):**
        ```sqlite
        SELECT COUNT(*) FROM lunar_events;
        ```
    *   **Exit `sqlite3`:**
        ```sqlite
        .quit
        ```