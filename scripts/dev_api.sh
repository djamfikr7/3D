#!/usr/bin/env bash
set -euo pipefail
cd server/api
[ -d node_modules ] || npm install
export STORAGE_DISABLED=true
export NODE_ENV=development
node ./src/db/migrate.js
node ./src/index.js
