param()
$ErrorActionPreference = 'Stop'
$compose = (Get-Command docker-compose -ErrorAction SilentlyContinue)
if (-not $compose) { Write-Error "docker-compose is required" }
$env:COMPOSE_DOCKER_CLI_BUILD = 1
$env:DOCKER_BUILDKIT = 1
docker-compose up --build
