file structure:
- api stores the feature logics and cookie router + cookie reader
- core is empty, should store cross-app global configuration setting, 
  e.g. API keys and cookie settings but since we currently only have 
  one cookie, its not neccessary 
- models store the userinput models, i.e. what structure of info needs
  to be passed in to call a specific feature
- services store the business logic, which includes the promptbuilder
  and gemini setup for each feature
- an overall main.py under /backend is the single fastapi root, run this
  file using "fastapi dev main.py" to see all the features and cookie 
  api endpoints. *must cd to current dir of /backend to run the dev
- the init files in each folder are empty, tell python to treat the
  folders as modules, for importing 

all about cookies
- the cookie.py file contains the "post" api endpoint, this is for 
  when a user first opens our website, and the api requires birthday
  and location of the user with form data (you have to ask them), 
  the endpoint will 
  1. take form data from frontend
  2. return the same data as a cookie to the frontend (as cookie is 
     saved in frontend browser)
  frontend example with JS for sending form data
  <form method="POST" action="http://localhost:8000/save-data">
    <input type="date" name="birthday" />
    <input type="text" name="location" placeholder="Your location" />
    <button type="submit">Save</button>
  </form>
  sample JS for getting cookie
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