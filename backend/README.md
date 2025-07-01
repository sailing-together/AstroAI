## File Structure

- **api**: Stores feature logic, cookie router, and cookie reader.
- **core**: Currently empty. Intended for cross-app global configuration (e.g., API keys, cookie settings). Not necessary now since there is only one cookie.
- **models**: Contains user input models, defining the structure of data required to call specific features.
- **services**: Contains business logic, including the prompt builder and Gemini setup for each feature.
- **main.py**: Located under `/backend`, serves as the FastAPI root. Run with `fastapi dev main.py` to access all features and cookie API endpoints. Make sure to `cd` into `/backend` before running.
- **\_\_init\_\_.py**: Empty files in each folder to mark them as Python modules for importing.

---

## Cookies

### Cookie API Endpoint

- `cookie.py` contains the `POST` API endpoint for when a user first visits the website.
- The API requires the user's birthday and location as form data.
- The endpoint:
  1. Receives form data from the frontend.
  2. Returns the same data as a cookie to the frontend (saved in the browser).

#### Example HTML Form

```html
<form method="POST" action="http://localhost:8000/save-data">
  <input type="date" name="birthday" />
  <input type="text" name="location" placeholder="Your location" />
  <button type="submit">Save</button>
</form>
```

---

### Sample JavaScript for Sending Form Data and Handling Cookies

```javascript
document.getElementById('eventForm').addEventListener('submit', async function(e) {
  e.preventDefault();

  const form = new FormData(e.target);

  const payload = {
    event: form.get("event"),
    event_date: form.get("event_date"),
    outcome: form.get("outcome") || null
  };

  const res = await fetch("http://localhost:8000/review_event", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    credentials: "include",  // IMPORTANT: this sends the cookie!
    body: JSON.stringify(payload)
  });

  const data = await res.json();
  document.getElementById("result").textContent = JSON.stringify(data, null, 2);
});
</script>

- the file also contains a get_user_info_cookie function, used to 
  read cookies that you sent together with a request to call a feature.
  Sample JS code when you want to call a feature. 
  <form id="eventForm">
  <label>Event:
    <input type="text" name="event" required>
  </label>
  <label>Event Date:
    <input type="date" name="event_date" required>
  </label>
  <label>Outcome (optional):
    <input type="text" name="outcome">
  </label>
  <button type="submit">Submit Event</button>
</form>

<pre id="result"></pre>

<script>
document.getElementById('eventForm').addEventListener('submit', async function(e) {
  e.preventDefault();

  const form = new FormData(e.target);

  const payload = {
    event: form.get("event"),
    event_date: form.get("event_date"),
    outcome: form.get("outcome") || null
  };

  const res = await fetch("http://localhost:8000/review_event", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    credentials: "include",  // IMPORTANT: this sends the cookie!
    body: JSON.stringify(payload)
  });

  const data = await res.json();
  document.getElementById("result").textContent = JSON.stringify(data, null, 2);
});
</script>

  *note: currently the form data frontend send is similar to the cookie
  in datatypes, though it is better for security, structure and consistency