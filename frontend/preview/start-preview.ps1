param(
    [string]$PythonPath = ""
)

$PreviewRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $PreviewRoot "..\..")

if (-not $PythonPath) {
    $Candidate = Join-Path $RepoRoot ".venv\Scripts\python.exe"
    if (Test-Path $Candidate) {
        $PythonPath = $Candidate
    } else {
        $PythonPath = "python"
    }
}

$EnvPath = Join-Path $RepoRoot ".env"
if (-not (Test-Path $EnvPath)) {
    @(
        "ENVIRONMENT=development",
        "BACKEND_CORS_ORIGINS=http://localhost:3000",
        "GEMINI_API_KEY=test",
        "SUPABASE_URL=https://example.supabase.co",
        "SUPABASE_ANON_KEY=anon",
        "SUPABASE_SERVICE_ROLE_KEY=service",
        "SUPABASE_JWT_SECRET=secret",
        "DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/db",
        "REDIS_URL=redis://localhost:6379/0"
    ) | Set-Content -Encoding utf8 $EnvPath
}

Start-Process -WindowStyle Hidden -FilePath $PythonPath -ArgumentList @(
    "-m",
    "uvicorn",
    "backend.main:app",
    "--host",
    "127.0.0.1",
    "--port",
    "8000"
) -WorkingDirectory $RepoRoot

Start-Process -WindowStyle Hidden -FilePath $PythonPath -ArgumentList @(
    "-m",
    "http.server",
    "3000"
) -WorkingDirectory $PreviewRoot

Write-Host "AstroAI backend: http://127.0.0.1:8000/api/v1/health"
Write-Host "AstroAI preview: http://127.0.0.1:3000/"
