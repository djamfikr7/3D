#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "stop" ]]; then
  docker rm -f capture3d-postgres >/dev/null 2>&1 || true
  echo "Stopped dev Postgres"; exit 0
fi
if docker ps --format '{{.Names}}' | grep -qx 'capture3d-postgres'; then
  echo "Postgres already running"; exit 0
fi
docker rm -f capture3d-postgres >/dev/null 2>&1 || true
docker run -d --name capture3d-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=capture3d -p 5432:5432 postgres:16-alpine >/dev/null
echo "Started Postgres at localhost:5432 (user postgres / pass postgres / db capture3d)"