param()
$ErrorActionPreference = 'Stop'
Push-Location server/api
if (-not (Test-Path node_modules)) { npm install }
$env:STORAGE_DISABLED = "true"
$env:NODE_ENV = "development"
node ./src/db/migrate.js
node ./src/index.js
Pop-Location
