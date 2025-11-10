param([switch]$WithDB, [switch]$Help)

if ($Help) {
    Write-Host "Usage: .\start_dev.ps1 [-WithDB]"
    Write-Host "  -WithDB: Use local Postgres (requires postgres://postgres:postgres@localhost:5432/capture3d)"
    Write-Host "  Default: No-DB mode (pure in-memory)"
    exit 0
}

$ErrorActionPreference = 'Stop'
Write-Host "=== Starting Capture3D Dev Stack ===" -ForegroundColor Green

# Set execution policy for this session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Check prerequisites
$node = Get-Command node -ErrorAction SilentlyContinue
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $node) { Write-Error "Node.js not found. Install from https://nodejs.org" }
if (-not $python) { Write-Error "Python not found. Install from https://python.org" }

Write-Host "✓ Prerequisites found" -ForegroundColor Green

# Configure environment
$env:STORAGE_DISABLED = "true"
$env:NODE_ENV = "development"
$env:DISABLE_DASHBOARD_AUTH = "true"
$env:API_BASE = "http://localhost:8080"
$env:QUEUE_IMPL = "dev"

if ($WithDB) {
    Write-Host "Mode: With Postgres" -ForegroundColor Yellow
    if (-not $env:DATABASE_URL) { 
        $env:DATABASE_URL = "postgres://postgres:postgres@localhost:5432/capture3d" 
    }
    # Try to create DB (ignore if exists)
    try {
        $null = psql -U postgres -c "CREATE DATABASE capture3d;" 2>$null
        Write-Host "✓ Database ready" -ForegroundColor Green
    } catch {
        Write-Host "! Database creation failed (may already exist)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Mode: No-DB (in-memory)" -ForegroundColor Yellow
    $env:NO_DB = "true"
}

# Start API in background
Write-Host "Starting API..." -ForegroundColor Cyan
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location server/api
    if (-not (Test-Path node_modules)) { npm install }
    if ($using:WithDB -and (-not $using:env:NO_DB)) {
        node ./src/db/migrate.js
    }
    node ./src/index.js
} -Name "API"

# Start Worker in background
Write-Host "Starting Worker..." -ForegroundColor Cyan
$workerJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location workers/recon
    if (-not (Test-Path .venv)) { python -m venv .venv }
    .\.venv\Scripts\Activate.ps1
    pip install -r requirements.txt
    $env:API_BASE = $using:env:API_BASE
    $env:QUEUE_IMPL = $using:env:QUEUE_IMPL
    python worker.py
} -Name "Worker"

# Wait for API health
Write-Host "Waiting for API to be ready..." -ForegroundColor Cyan
$timeout = 30
$elapsed = 0
do {
    Start-Sleep 2
    $elapsed += 2
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:8080/health" -TimeoutSec 3
        if ($health.ok) {
            Write-Host "✓ API is ready!" -ForegroundColor Green
            break
        }
    } catch {}
    if ($elapsed -ge $timeout) {
        Write-Host "✗ API failed to start within ${timeout}s" -ForegroundColor Red
        Write-Host "API logs:" -ForegroundColor Yellow
        Receive-Job $apiJob
        Stop-Job $apiJob, $workerJob
        exit 1
    }
} while ($true)

# Open dashboard
Write-Host "Opening dashboard..." -ForegroundColor Cyan
Start-Process "http://localhost:8080/public/dashboard.html"

Write-Host ""
Write-Host "=== Capture3D Dev Stack Running ===" -ForegroundColor Green
Write-Host "API: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Dashboard: http://localhost:8080/public/dashboard.html" -ForegroundColor Cyan
Write-Host "Job Detail: http://localhost:8080/public/job.html" -ForegroundColor Cyan
Write-Host "Upload UI: http://localhost:8080/public/upload.html" -ForegroundColor Cyan
Write-Host "3D Viewer: http://localhost:8080/public/viewer.html" -ForegroundColor Cyan
Write-Host "Metrics: http://localhost:8080/metrics" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test job creation:" -ForegroundColor Yellow
Write-Host 'curl -X POST http://localhost:8080/process -H "Content-Type: application/json" -d "{\"project_id\":\"p1\",\"images_manifest\":[\"img1.jpg\"],\"preset\":\"ecommerce\"}"'
Write-Host ""
Write-Host "Press Ctrl+C to stop all services"

try {
    while ($true) {
        Start-Sleep 5
        # Check if jobs are still running
        if ($apiJob.State -ne 'Running' -or $workerJob.State -ne 'Running') {
            Write-Host "A service stopped unexpectedly" -ForegroundColor Red
            if ($apiJob.State -ne 'Running') {
                Write-Host "API logs:" -ForegroundColor Yellow
                Receive-Job $apiJob
            }
            if ($workerJob.State -ne 'Running') {
                Write-Host "Worker logs:" -ForegroundColor Yellow
                Receive-Job $workerJob
            }
            break
        }
    }
} finally {
    Write-Host "Stopping services..." -ForegroundColor Yellow
    Stop-Job $apiJob, $workerJob -ErrorAction SilentlyContinue
    Remove-Job $apiJob, $workerJob -ErrorAction SilentlyContinue
    Write-Host "Services stopped" -ForegroundColor Green
}