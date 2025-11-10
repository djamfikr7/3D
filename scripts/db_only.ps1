param([switch]$Stop)
$ErrorActionPreference = 'Stop'
if ($Stop) {
  docker rm -f capture3d-postgres 2>$null | Out-Null
  Write-Host "Stopped dev Postgres"
  exit 0
}
$running = docker ps --filter "name=capture3d-postgres" --format "{{.ID}}"
if ($running) { Write-Host "Postgres already running"; exit 0 }
$exists = docker ps -a --filter "name=capture3d-postgres" --format "{{.ID}}"
if ($exists) { docker rm -f capture3d-postgres | Out-Null }
docker run -d --name capture3d-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=capture3d -p 5432:5432 postgres:16-alpine | Out-Null
Write-Host "Started Postgres at localhost:5432 (user postgres / pass postgres / db capture3d)"