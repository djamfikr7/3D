Write-Host "=== Debugging API Start ===" -ForegroundColor Yellow

# Set environment
$env:NO_DB = "true"
$env:STORAGE_DISABLED = "true" 
$env:NODE_ENV = "development"
$env:DISABLE_DASHBOARD_AUTH = "true"

# Try to start API directly (not as background job)
Write-Host "Changing to API directory..." -ForegroundColor Cyan
Set-Location server/api

Write-Host "Checking if node_modules exists..." -ForegroundColor Cyan
if (Test-Path node_modules) {
    Write-Host "node_modules found" -ForegroundColor Green
} else {
    Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
    npm install
}

Write-Host "Attempting to start API directly..." -ForegroundColor Cyan
Write-Host "Command: node ./src/index.js" -ForegroundColor Gray
node ./src/index.js