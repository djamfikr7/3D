#!/usr/bin/env bash
set -euo pipefail
cd server/api
[ -d node_modules ] || npm install
npx openapi-typescript openapi.yaml -o src/types/api.d.ts
echo "Generated TypeScript types at server/api/src/types/api.d.ts"