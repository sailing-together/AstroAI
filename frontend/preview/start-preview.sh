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

"$PYTHON_BIN" -m pip install "${PIP_FLAGS[@]}" \
  fastapi==0.115.13 \
  pydantic==2.11.7 \
  pydantic-settings==2.7.0 \
  sqlalchemy==2.0.30 \
  httpx==0.27.0 \
  "python-jose[cryptography]==3.3.0" \
  uvicorn==0.29.0 >/dev/null

cat > "$REPO_ROOT/.env" <<'EOF'
ENVIRONMENT=development
BACKEND_CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
GEMINI_API_KEY=test
SUPABASE_URL=https://example.supabase.co
SUPABASE_ANON_KEY=anon
SUPABASE_SERVICE_ROLE_KEY=service
SUPABASE_JWT_SECRET=secret
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/db
REDIS_URL=redis://localhost:6379/0
EOF

echo "Using Python: $PYTHON_BIN"
echo "Starting AstroAI backend at http://127.0.0.1:8000"
(
  cd "$REPO_ROOT"
  "$PYTHON_BIN" -m uvicorn backend.main:app --host 127.0.0.1 --port 8000
) &
BACKEND_PID=$!

echo "Starting AstroAI preview at http://127.0.0.1:3000"
(
  cd "$SCRIPT_DIR"
  "$PYTHON_BIN" -m http.server 3000
) &
PREVIEW_PID=$!

cleanup() {
  kill "$BACKEND_PID" "$PREVIEW_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo
echo "Open http://127.0.0.1:3000/"
echo "Press Ctrl+C to stop both servers."
wait
