#!/bin/bash
# This script automates the setup and execution of the AstroAI backend.

# Navigate to the script's directory to ensure relative paths work.
cd "$(dirname "$0")"

VENV_NAME="astroai_venv"

# Check if the virtual environment directory exists.
if [ ! -d "$VENV_NAME" ]; then
    echo "Virtual environment '$VENV_NAME' not found. Creating one with python3.11..."
    python3.11 -m venv "$VENV_NAME"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual environment. Make sure python3.11 is installed and in your PATH." >&2
        exit 1
    fi

    echo "Installing dependencies..."
    "$VENV_NAME/bin/pip" install -r backend/requirements.txt
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install dependencies." >&2
        exit 1
    fi
fi

# Run the FastAPI server using the python from the virtual environment.

echo "Starting FastAPI server..."
echo "Access the API at http://localhost:8000"
"$VENV_NAME/bin/fastapi" dev backend/main.py
