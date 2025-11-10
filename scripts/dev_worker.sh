#!/usr/bin/env bash
set -euo pipefail
cd workers/recon
python -m venv .venv || true
source .venv/bin/activate
pip install -r requirements.txt
export API_BASE=http://localhost:8080
export QUEUE_IMPL=dev
python worker.py
