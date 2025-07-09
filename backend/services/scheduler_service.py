from apscheduler.schedulers.background import BackgroundScheduler
import requests

# Define the base URL for your FastAPI application
BASE_URL = "http://localhost:8000"

def schedule_db_maintenance():
    """Function to be scheduled for database updates and cleanup."""
    print("Running scheduled database maintenance...")
    try:
        # Call the update-database endpoint
        update_response = requests.post(f"{BASE_URL}/update-database/")
        update_response.raise_for_status()  # Raise an exception for HTTP errors
        print(f"Database update successful: {update_response.json()}")

        # Call the clear-past-events endpoint
        clear_response = requests.post(f"{BASE_URL}/admin/clear-past-events/")
        clear_response.raise_for_status()  # Raise an exception for HTTP errors
        print(f"Past events clear successful: {clear_response.json()}")

    except requests.exceptions.RequestException as e:
        print(f"Scheduled database maintenance failed: {e}")

def schedule_daily_events_fetch():
    """Function to be scheduled for daily fetching of events."""
    print("Fetching daily events...")
    try:
        events_response = requests.get(f"{BASE_URL}/events-today")
        events_response.raise_for_status() # Raise an exception for HTTP errors
        daily_events = events_response.json()
        print(f"Daily events fetched: {daily_events}")
    except requests.exceptions.RequestException as e:
        print(f"Scheduled daily events fetch failed: {e}")

scheduler = BackgroundScheduler()

def start_scheduler():
    # Schedule the job to run every 30 days
    scheduler.add_job(schedule_db_maintenance, 'interval', days=30)
    # Schedule the job to run daily
    scheduler.add_job(schedule_daily_events_fetch, 'interval', days=1)
    scheduler.start()
    print("Scheduler started.")

def shutdown_scheduler():
    scheduler.shutdown()
    print("Scheduler shut down.")