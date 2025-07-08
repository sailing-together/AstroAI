import os
from backend.database.models import Base
from backend.database.config import engine, DB_PATH

print("Initializing database...")

# Check if the database file exists at the correct path
if not os.path.exists(DB_PATH):
    print(f"Database file not found at {DB_PATH}. Creating tables...")
    Base.metadata.create_all(bind=engine)
    print("✅ Tables created.")
else:
    print(f"Database file found at {DB_PATH}. Tables should already exist.")