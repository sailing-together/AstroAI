param(
    [string]$PythonPath = "",
    [int]$BackendPort = 0,
    [int]$PreviewPort = 0
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

function Find-FreePort {
    param([int]$StartPort)

    $Port = $StartPort
    while ($true) {
        $Listener = $null
        try {
            $Listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Parse("127.0.0.1"), $Port)
            $Listener.Start()
            return $Port
        } catch {
            $Port += 1
        } finally {
            if ($Listener) {
                $Listener.Stop()
            }
        }
    }
}

if ($BackendPort -eq 0) {
    $BackendPort = Find-FreePort 8000
}

if ($PreviewPort -eq 0) {
    $PreviewPort = Find-FreePort 3000
}

$ApiBase = "http://127.0.0.1:$BackendPort/api/v1"

@(
    "ENVIRONMENT=development",
    "BACKEND_CORS_ORIGINS=http://localhost:$PreviewPort,http://127.0.0.1:$PreviewPort",
    "GEMINI_API_KEY=test",
    "SUPABASE_URL=https://example.supabase.co",
    "SUPABASE_ANON_KEY=anon",
    "SUPABASE_SERVICE_ROLE_KEY=service",
    "SUPABASE_JWT_SECRET=secret",
    "DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/db",
    "REDIS_URL=redis://localhost:6379/0"
) | Set-Content -Encoding utf8 $EnvPath

"window.ASTROAI_API_BASE = `"$ApiBase`";" | Set-Content -Encoding utf8 (Join-Path $PreviewRoot "runtime-config.js")

Start-Process -WindowStyle Hidden -FilePath $PythonPath -ArgumentList @(
    "-m",
    "uvicorn",
    "backend.main:app",
    "--host",
    "127.0.0.1",
    "--port",
    "$BackendPort"
) -WorkingDirectory $RepoRoot

Start-Process -WindowStyle Hidden -FilePath $PythonPath -ArgumentList @(
    "-m",
    "http.server",
    "$PreviewPort"
) -WorkingDirectory $PreviewRoot

Write-Host "AstroAI backend: http://127.0.0.1:$BackendPort/api/v1/health"
Write-Host "AstroAI preview: http://127.0.0.1:$PreviewPort/"
