#!/usr/bin/env bash
set -euo pipefail
if ! command -v docker-compose >/dev/null 2>&1; then
  echo "docker-compose is required"; exit 1
fi
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
docker-compose up --build
