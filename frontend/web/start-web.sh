#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

PYTHON_BIN="${PYTHON_BIN:-$REPO_ROOT/.venv/bin/python}"
PIP_FLAGS=()

if [[ ! -x "$PYTHON_BIN" ]]; then
  BASE_PYTHON="$(command -v python3 || command -v python)"
  if "$BASE_PYTHON" -m venv "$REPO_ROOT/.venv" >/dev/null 2>&1; then
    PYTHON_BIN="$REPO_ROOT/.venv/bin/python"
  else
    echo "python3-venv is not available; using system Python with --user installs."
    echo "For a cleaner setup, run: sudo apt install python3.10-venv"
    PYTHON_BIN="$BASE_PYTHON"
    PIP_FLAGS=(--user)
  fi
fi

if ! "$PYTHON_BIN" -m pip --version >/dev/null 2>&1; then
  BASE_PYTHON="$(command -v python3 || command -v python)"
  echo "pip is not available for $PYTHON_BIN; using system Python with --user installs."
  PYTHON_BIN="$BASE_PYTHON"
  PIP_FLAGS=(--user)
fi

find_free_port() {
  "$PYTHON_BIN" - "$1" <<'PY'
import socket
import sys

port = int(sys.argv[1])
while True:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        try:
            sock.bind(("127.0.0.1", port))
        except OSError:
            port += 1
            continue
    print(port)
    break
PY
}

BACKEND_PORT="${BACKEND_PORT:-$(find_free_port 8000)}"
WEB_PORT="${WEB_PORT:-$(find_free_port 3000)}"
API_BASE="http://127.0.0.1:$BACKEND_PORT/api/v1"

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  nvm use 22 >/dev/null
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to run the public web app."
  echo "Install Node.js 22 or run: nvm install 22 && nvm use 22"
  exit 1
fi

"$PYTHON_BIN" -m pip install "${PIP_FLAGS[@]}" \
  fastapi==0.115.13 \
  pydantic==2.11.7 \
  pydantic-settings==2.7.0 \
  sqlalchemy==2.0.30 \
  httpx==0.27.0 \
  "python-jose[cryptography]==3.3.0" \
  uvicorn==0.29.0 >/dev/null

cat > "$REPO_ROOT/.env" <<EOF
ENVIRONMENT=development
BACKEND_CORS_ORIGINS=http://localhost:$WEB_PORT,http://127.0.0.1:$WEB_PORT
GEMINI_API_KEY=test
SUPABASE_URL=https://example.supabase.co
SUPABASE_ANON_KEY=anon
SUPABASE_SERVICE_ROLE_KEY=service
SUPABASE_JWT_SECRET=secret
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/db
REDIS_URL=redis://localhost:6379/0
EOF

cat > "$SCRIPT_DIR/.env.local" <<EOF
NEXT_PUBLIC_API_BASE_URL=$API_BASE
EOF

if [[ ! -d "$SCRIPT_DIR/node_modules" ]]; then
  echo "Installing frontend dependencies..."
  (cd "$SCRIPT_DIR" && npm install)
fi

echo "Using Python: $PYTHON_BIN"
echo "Starting AstroAI backend at http://127.0.0.1:$BACKEND_PORT"
(
  cd "$REPO_ROOT"
  "$PYTHON_BIN" -m uvicorn backend.main:app --host 127.0.0.1 --port "$BACKEND_PORT"
) &
BACKEND_PID=$!

echo "Starting AstroAI public web at http://127.0.0.1:$WEB_PORT/horoscope"
(
  cd "$SCRIPT_DIR"
  NEXT_PUBLIC_API_BASE_URL="$API_BASE" npm run dev -- --hostname 127.0.0.1 --port "$WEB_PORT"
) &
WEB_PID=$!

cleanup() {
  kill "$BACKEND_PID" "$WEB_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo
echo "Open http://127.0.0.1:$WEB_PORT/horoscope"
echo "Backend API: $API_BASE"
echo "Press Ctrl+C to stop both servers."
wait
