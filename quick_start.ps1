param([switch]$Help)

if ($Help) {
    Write-Host "Quick Start - runs API and Worker directly (no background jobs)"
    Write-Host "Usage: .\quick_start.ps1"
    exit 0
}

$ErrorActionPreference = 'Continue'  # Don't stop on warnings
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Write-Host "=== Quick Start: Capture3D Local Dev ===" -ForegroundColor Green

# Configure environment
$env:NO_DB = "true"
$env:STORAGE_DISABLED = "true"
$env:NODE_ENV = "development"
$env:DISABLE_DASHBOARD_AUTH = "true"
$env:API_BASE = "http://localhost:8080"
$env:QUEUE_IMPL = "dev"

Write-Host "1. Setting up API..." -ForegroundColor Cyan
Set-Location server/api

Write-Host "   Installing dependencies..." -ForegroundColor Gray
npm install --silent 2>$null

Write-Host "   Starting API on :8080..." -ForegroundColor Gray
$apiProcess = Start-Process -FilePath "node" -ArgumentList "src/index.js" -PassThru -WindowStyle Hidden

# Wait a moment for API to start
Start-Sleep 3

# Check if API is responding
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -TimeoutSec 5
    Write-Host "   API started successfully!" -ForegroundColor Green
} catch {
    Write-Host "   API may still be starting... continuing..." -ForegroundColor Yellow
}

Write-Host "2. Setting up Worker..." -ForegroundColor Cyan
Set-Location ..\..\workers\recon

if (-not (Test-Path .venv)) {
    Write-Host "   Creating Python virtual environment..." -ForegroundColor Gray
    python -m venv .venv
}

Write-Host "   Activating virtual environment..." -ForegroundColor Gray
.\.venv\Scripts\Activate.ps1

Write-Host "   Installing Python dependencies..." -ForegroundColor Gray
pip install -r requirements.txt --quiet

Write-Host "   Starting Worker..." -ForegroundColor Gray
$workerProcess = Start-Process -FilePath ".venv/Scripts/python.exe" -ArgumentList "worker.py" -PassThru -WindowStyle Hidden

Start-Sleep 2
Set-Location ..\..

Write-Host ""
Write-Host "=== Services Started ===" -ForegroundColor Green
Write-Host "API PID: $($apiProcess.Id)" -ForegroundColor Gray
Write-Host "Worker PID: $($workerProcess.Id)" -ForegroundColor Gray
Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  Health: http://localhost:8080/health"
Write-Host "  Dashboard: http://localhost:8080/public/dashboard.html"
Write-Host "  Job Detail: http://localhost:8080/public/job.html"
Write-Host "  3D Viewer: http://localhost:8080/public/viewer.html"
Write-Host ""

# Test health
Write-Host "3. Testing health endpoint..." -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/health" -TimeoutSec 10
    if ($health.ok) {
        Write-Host "   Health check passed!" -ForegroundColor Green
    } else {
        Write-Host "   Health check failed" -ForegroundColor Red
    }
} catch {
    Write-Host "   Health endpoint not responding yet" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "4. Opening dashboard..." -ForegroundColor Cyan
Start-Process "http://localhost:8080/public/dashboard.html"

Write-Host ""
Write-Host "=== Test Commands ===" -ForegroundColor Yellow
Write-Host "Create a job:"
Write-Host 'Invoke-RestMethod -Uri "http://localhost:8080/process" -Method Post -ContentType "application/json" -Body ''{"project_id":"p1","images_manifest":["img1.jpg"],"preset":"ecommerce"}'''
Write-Host ""
Write-Host "View jobs:"
Write-Host 'Invoke-RestMethod -Uri "http://localhost:8080/jobs"'
Write-Host ""
Write-Host "=== Stop Services ===" -ForegroundColor Yellow
Write-Host "To stop, run: Stop-Process -Id $($apiProcess.Id), $($workerProcess.Id)"
Write-Host "Or use Task Manager to end 'node.exe' and 'python.exe' processes"
Write-Host ""
Write-Host "Script complete. Services are running in background." -ForegroundColor Green