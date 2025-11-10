param()
$ErrorActionPreference = 'Stop'
Push-Location workers/recon
if (-not (Test-Path .venv)) { python -m venv .venv }
. .venv/Scripts/Activate.ps1
pip install -r requirements.txt
$env:API_BASE = "http://localhost:8080"
$env:QUEUE_IMPL = "dev"
python worker.py
Pop-Location
