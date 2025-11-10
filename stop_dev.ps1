Write-Host "=== Stopping Capture3D Services ===" -ForegroundColor Yellow

# Kill node processes (API)
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    Write-Host "Stopping API (node processes)..." -ForegroundColor Cyan
    $nodeProcesses | Stop-Process -Force
    Write-Host "Stopped $($nodeProcesses.Count) node process(es)" -ForegroundColor Green
} else {
    Write-Host "No node processes found" -ForegroundColor Gray
}

# Kill python processes (Worker) - be careful with this
$pythonProcesses = Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "python" }
if ($pythonProcesses) {
    Write-Host "Stopping Worker (python processes)..." -ForegroundColor Cyan
    Write-Host "Found $($pythonProcesses.Count) python process(es) - stopping carefully..." -ForegroundColor Yellow
    $pythonProcesses | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force
            Write-Host "  Stopped python process $($_.Id)" -ForegroundColor Green
        } catch {
            Write-Host "  Could not stop python process $($_.Id)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No python processes found" -ForegroundColor Gray
}

Write-Host "Services stopped" -ForegroundColor Green