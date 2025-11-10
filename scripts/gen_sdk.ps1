param()
$ErrorActionPreference = 'Stop'
Push-Location server/api
if (-not (Test-Path node_modules)) { npm install }
npx openapi-typescript openapi.yaml -o src/types/api.d.ts
Pop-Location
Write-Host "Generated TypeScript types at server/api/src/types/api.d.ts"