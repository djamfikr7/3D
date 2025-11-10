param()

$ErrorActionPreference = 'Continue'
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Write-Host "=== Debug Visible: Starting Services ===" -ForegroundColor Green

# Configure environment
$env:NO_DB = "true"
$env:STORAGE_DISABLED = "true"
$env:NODE_ENV = "development"
$env:DISABLE_DASHBOARD_AUTH = "true"
$env:API_BASE = "http://localhost:8080"
$env:QUEUE_IMPL = "dev"

Write-Host "Environment set:" -ForegroundColor Gray
Write-Host "  NO_DB = $env:NO_DB"
Write-Host "  STORAGE_DISABLED = $env:STORAGE_DISABLED"
Write-Host "  NODE_ENV = $env:NODE_ENV"

Write-Host ""
Write-Host "=== Step 1: API Setup ===" -ForegroundColor Cyan
Set-Location server/api

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray
Write-Host "Checking for package.json..." -ForegroundColor Gray
if (Test-Path "package.json") {
    Write-Host "package.json found" -ForegroundColor Green
} else {
    Write-Host "package.json NOT found!" -ForegroundColor Red
    Write-Host "Files in directory:"
    Get-ChildItem | Select-Object Name | Format-Table
}

Write-Host "Installing dependencies with verbose output..." -ForegroundColor Gray
npm install

Write-Host "Checking if src/index.js exists..." -ForegroundColor Gray
if (Test-Path "src/index.js") {
    Write-Host "src/index.js found" -ForegroundColor Green
} else {
    Write-Host "src/index.js NOT found!" -ForegroundColor Red
    Write-Host "Files in src/:"
    Get-ChildItem src | Select-Object Name | Format-Table
}

Write-Host ""
Write-Host "=== Step 2: Starting API (VISIBLE) ===" -ForegroundColor Cyan
Write-Host "Command: node src/index.js" -ForegroundColor Gray
Write-Host "This will show any errors..." -ForegroundColor Yellow

# Start API in foreground so we can see errors
node src/index.js